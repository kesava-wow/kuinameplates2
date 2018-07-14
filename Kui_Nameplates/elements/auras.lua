--[[
    Provides aura frames to the layout based on table configuration.

    In layout initialise
    ====================

    self.Auras = {
        font = path to font to use for aura countdown and stack count
        font_size_cd = size of font used for aura countdown
        font_size_count = size of font used for aura stack count
        font_flags = additional font flags (OUTLINE, et al)
    }
        Configuration table. Can be an empty table.
        Element will not initialise if this is missing.

    Creating aura frames
    ====================

    Aura frames can be created with the function:
        frame.handler:CreateAuraFrame(frame_def)

    frame_def is a table which may contain the following values:
    frame_def = {
        id = key for this frame in the [nameplate].Auras.frames table
        size = icon size
        squareness = icon width/height ratio
        point = {
            [1] = point to place first aura icon in auras frame
            [2] = point of icon to attach to previous icon in a row
            [3] = point of previous icon on to which the next will be attached
        }
        x_spacing = horizontal spacing between icons
        y_spacing = vertical spacing between icons
        max = maximum number of auras to display
        rows = maximum number of rows
        row_growth = direction in which rows will grow ('UP' or 'DOWN')
        sort = aura sorting function, or index in sort_lookup
        filter = filter used in UnitAura calls
        num_per_row = number of icons per row;
                      if left nil, calculates as max / rows
        whitelist = a table of spellids to to show in the aura frame
        pulsate = whether or not to pulsate icons with low time remaining
        timer_threshold = threshold below which to show timer text
        centred = centre visible auras in the frame
    }

    Callbacks
    =========

    ArrangeButtons(auraframe)
        Used to replace the built in ArrangeButtons function which arranges the
        aura buttons in the aura frame whenever they are updated.
        If false (or nil) is returned, the built-in ArrangeButtons function will
        still be run.

    CreateAuraButton(auraframe)
        Used to replace the built in CreateAuraButton function. Button functions
        will be mixed-in to the returned frame which can then be edited via the
        PostCreateAuraButton callback.

    PostCreateAuraButton(auraframe,button)
        Called after an aura button is created.

    PostCreateAuraFrame(auraframe)
        Called after an aura frame is created.

    PostUpdateAuraFrame(auraframe)
        Called after a shown aura frame is updated (buttons arranged, etc).

    DisplayAura(auraframe,name,spellid,duration)
        Can be used to arbitrarily filter auras.
        Can return:
            1 (CB_HIDE): forcibly HIDE this aura
            2 (CB_SHOW): forcibly SHOW this aura
            Else:        process as normal (whitelist & nameplate filter)

]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('Auras')

local strlower,tinsert,tsort,     pairs,ipairs =
      strlower,tinsert,table.sort,pairs,ipairs

local FONT,FONT_SIZE_CD,FONT_SIZE_COUNT,FONT_FLAGS

-- DisplayAura callback return behaviour enums
local CB_HIDE,CB_SHOW = 1,2

-- time below which to show decimal places
local DECIMAL_THRESHOLD = 1
-- row growth lookup table
local row_growth_points = {
    UP = {'BOTTOM','TOP'},
    DOWN = {'TOP','BOTTOM'}
}
-- aura sorting functions ######################################################
local index_sort = function(a,b)
    -- sort by aura index
    return a.index < b.index
end
local time_sort = function(a,b)
    -- sort by time remaining ( shorter > longer > timeless )
    if a.expiration and b.expiration then
        if a.expiration == b.expiration then
            return index_sort(a,b)
        else
            return a.expiration < b.expiration
        end
    elseif not a.expiration and not b.expiration then
        return index_sort(a,b)
    else
        return a.expiration and not b.expiration
    end
end
local auras_sort = function(a,b)
    -- sort template; sort unused buttons
    if not a.index and not b.index then
        return
    elseif a.index and not b.index then
        return true
    elseif not a.index and b.index then
        return
    end

    -- and call the frame's desired sort function
    return a.parent.sort(a,b)
end

local sort_lookup = {
    index_sort,
    time_sort,
}
-- aura button functions #######################################################
local function button_OnUpdate(self,elapsed)
    self.cd_elap = (self.cd_elap or 0) - elapsed
    if self.cd_elap <= 0 then
        local remaining = self.expiration - GetTime()

        if self.parent.pulsate and remaining <= 5 then
            self:StartPulsate()
        else
            self:StopPulsate()
        end

        if remaining <= 0 then
            -- timers can get below 0 due to latency
            self.cd:SetText(0)
            self:SetScript('OnUpdate',nil)
            return
        elseif self.parent.timer_threshold and
               remaining > self.parent.timer_threshold
        then
            -- don't show a timer above threshold
            self.cd_elap = 1
            self.cd:SetText('')
            return
        end

        if remaining <= DECIMAL_THRESHOLD+1 then
            -- faster updates in the last 2 seconds
            self.cd_elap = .05
        else
            self.cd_elap = .5
        end

        if remaining <= 5 then
            self.cd:SetTextColor(1,0,0)
        elseif remaining <= 20 then
            self.cd:SetTextColor(1,1,0)
        else
            self.cd:SetTextColor(1,1,1)
        end

        if remaining <= DECIMAL_THRESHOLD then
            -- decimal places in the last second
            remaining = format("%.1f", remaining)
        else
            remaining = format("%.f", remaining)
        end

        self.cd:SetText(remaining)
    end
end
local function button_UpdateCooldown(self,duration,expiration)
    if expiration and expiration > 0 then
        self.expiration = expiration
        self.cd_elap = 0
        self:SetScript('OnUpdate',button_OnUpdate)
        self.cd:Show()
    else
        self.expiration = nil
        self:SetScript('OnUpdate',nil)
        self.cd:Hide()
    end
end
local function button_SetTexture(self,texture)
    self.icon:SetTexture(texture)
end
local button_StartPulsate, button_StopPulsate
do
    -- button pulsate functions
    local DoPulsateButton
    local function OnFadeOutFinished(button)
        button.fading = nil
        button.faded = true
        DoPulsateButton(button)
    end
    local function OnFadeInFinished(button)
        button.fading = nil
        button.faded = nil
        DoPulsateButton(button)
    end

    function DoPulsateButton(button)
        if button.fading or not button.pulsating then return end
        button.fading = true

        if button.faded then
            -- fade in
            kui.frameFade(button, {
                startAlpha = .5,
                timeToFade = .5,
                finishedFunc = OnFadeInFinished
            })
        else
            -- fade out
            kui.frameFade(button, {
                mode = 'OUT',
                endAlpha = .5,
                timeToFade = .5,
                finishedFunc = OnFadeOutFinished
            })
        end
    end

    function button_StartPulsate(self)
        if self.pulsating then return end

        self.pulsating = true
        DoPulsateButton(self)
    end
    function button_StopPulsate(self)
        if not self.pulsating then return end

        kui.frameFadeRemoveFrame(self)
        self.pulsating = nil
        self.fading = nil
        self.faded = nil
        self:SetAlpha(1)
    end
end
-- button creation #############################################################
local button_meta = {
    UpdateCooldown = button_UpdateCooldown,
    SetTexture = button_SetTexture,
    StartPulsate = button_StartPulsate,
    StopPulsate = button_StopPulsate
}
local function CreateAuraButton(parent)
    local button = ele:RunCallback('CreateAuraButton',parent)

    if not button then
        button = CreateFrame('Frame',nil,parent)
        button:SetWidth(parent.size)
        button:SetHeight(parent.icon_height)

        local icon = button:CreateTexture(nil, 'ARTWORK', nil, 1)
        icon:SetTexCoord(.1,.9,.1+parent.icon_ratio,.9-parent.icon_ratio)

        local bg = button:CreateTexture(nil, 'ARTWORK', nil, 0)
        bg:SetTexture('interface/buttons/white8x8')
        bg:SetVertexColor(0,0,0,1)
        bg:SetAllPoints(button)

        icon:SetPoint('TOPLEFT',bg,'TOPLEFT',1,-1)
        icon:SetPoint('BOTTOMRIGHT',bg,'BOTTOMRIGHT',-1,1)

        local cd = button:CreateFontString(nil,'OVERLAY')
        cd:SetFont(FONT, FONT_SIZE_CD, FONT_FLAGS)
        cd:SetPoint('TOPLEFT',-2,2)

        local count = button:CreateFontString(nil,'OVERLAY')
        count:SetFont(FONT, FONT_SIZE_COUNT, FONT_FLAGS)
        count:SetPoint('BOTTOMRIGHT',4,-2)
        count:Hide()

        button.icon   = icon
        button.cd     = cd
        button.count  = count
    end

    button.parent = parent

    -- mixin prototype
    for k,v in pairs(button_meta) do
        button[k] = v
    end

    ele:RunCallback('PostCreateAuraButton',parent,button)

    return button
end
-- aura frame functions ########################################################
local function AuraFrame_Enable(self,force_update)
    if not self.__DISABLED then return end

    self.__DISABLED = nil

    if force_update or self.parent:IsShown() then
        self:FactionUpdate()
        self:Update()
    end
end
local function AuraFrame_Disable(self)
    if self.__DISABLED then return end

    self:Hide()
    self.__DISABLED = true
end
local function AuraFrame_Update(self)
    if self.__DISABLED then return end

    self:FactionUpdate() -- XXX workaround for #1
    self:GetAuras()

    for _,button in ipairs(self.buttons) do
        if button.spellid and not button.used then
            self:HideButton(button)
        end

        button.used = nil
    end

    self:ArrangeButtons()

    if self.visible and self.visible > 0 then
        self:Show()
        ele:RunCallback('PostUpdateAuraFrame',self)
    else
        self:Hide()
    end
end
local function AuraFrame_FactionUpdate(self)
    if self.__DISABLED then return end

    if self.dynamic and self.parent.unit then
        -- update filter on faction change if dynamic
        if UnitCanAttack('player',self.parent.unit) then
            self.filter = 'HARMFUL'
        else
            self.filter = 'HELPFUL'
        end
    end

    if addon.debug then
        assert(self.filter ~= nil)
    end
end
local function AuraFrame_GetAuras(self)
    for i=1,40 do
        -- nps_ = NamePlateShow...
        local name,icon,count,_,duration,expiration,caster,_,
              nps_own,spellid,_,_,_,nps_all =
              UnitAura(self.parent.unit,i,self.filter)

        if not name then break end
        if name and spellid and
           self:ShouldShowAura(spellid,strlower(name),duration,caster,nps_own,nps_all)
        then
            self:DisplayButton(spellid,name,icon,count,duration,expiration,i)
        end
    end
end
local function AuraFrame_GetButton(self,spellid)
    if self.spellids[spellid] then
        -- use existing button with this spellid
        return self.spellids[spellid]
    end

    for _,button in ipairs(self.buttons) do
        if not button:IsShown() and not button.spellid then
            -- use unused button
            return button
        end
    end

    -- create new button
    local button = CreateAuraButton(self)

    tinsert(self.buttons, button)
    return button
end
local function AuraFrame_ShouldShowAura(self,spellid,name,duration,caster,nps_own,nps_all)
    if not name or not spellid then return end

    local cbr = ele:RunCallback('DisplayAura',self,name,spellid,duration,caster)
    if cbr then
        -- forcibly hidden
        if cbr == CB_HIDE then return end
        -- forcibly shown
        if cbr == CB_SHOW then return true end
        -- or continue processing
    end

    if self.whitelist then
        -- only obey whitelist
        return self.whitelist[spellid] or self.whitelist[name]
    else
        -- fallback to API's nameplate filter
        return nps_all or (nps_own and
               (caster == 'player' or caster == 'pet' or caster == 'vehicle'))
    end
end
local function AuraFrame_DisplayButton(self,spellid,name,icon,count,duration,expiration,index)
    local button = self:GetButton(spellid)

    button:SetTexture(icon)
    button.used = true
    button.spellid = spellid
    button.index = index

    if count > 1 then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end

    button:UpdateCooldown(duration,expiration)

    self.spellids[spellid] = button
end
local function AuraFrame_HideButton(self,button)
    if button.spellid then
        self.spellids[button.spellid] = nil
    end

    -- hide cooldown
    button:UpdateCooldown()

    -- reset pulsating
    button:StopPulsate()

    button.duration   = nil
    button.expiration = nil
    button.cd_elap    = nil
    button.spellid    = nil
    button.index      = nil

    button:Hide()
end
local function AuraFrame_HideAllButtons(self)
    for _,button in ipairs(self.buttons) do
        self:HideButton(button)
    end

    self.visible = nil
    self:Hide()
end
local function AuraFrame_ArrangeButtons(self)
    if ele:RunCallback('ArrangeButtons',self) then
        return
    end

    tsort(self.buttons, auras_sort)

    local prev,prev_row
    self.visible = 0

    for _,button in ipairs(self.buttons) do
        if button.spellid then
            if not self.max or self.visible < self.max then
                self.visible = self.visible + 1
                button:ClearAllPoints()

                -- if centred, we just need to count the number of buttons
                -- visible to position them more efficiently later.
                -- otherwise, set position in 1 iteration:
                if not self.centred then
                    if not prev then
                        button:SetPoint(self.point[1])
                        prev_row = button
                    else
                        if  self.rows and self.rows > 1 and
                            (self.visible - 1) % self.num_per_row == 0
                        then
                            button:SetPoint(
                                self.row_point[1], prev_row, self.row_point[2],
                                0, self.y_spacing
                            )
                            prev_row = button
                        else
                            button:SetPoint(
                                self.point[2], prev, self.point[3],
                                self.x_spacing, 0
                            )
                        end
                    end
                    prev = button
                end

                button:Show()
            else
                button:Hide()
            end
        end
    end

    if self.centred and self.visible > 0 then
        -- align buttons from centre of frame
        local i = 0
        local row_i = 0
        local rows = ceil(self.visible / self.num_per_row)-1
        for _,button in ipairs(self.buttons) do
            if button.spellid and button:IsShown() then
                if not prev or (i % self.num_per_row) == 0 then
                    -- start of row
                    local visible_in_row =
                        row_i < rows and
                        self.num_per_row or
                        self.visible - (self.num_per_row * rows)

                    local row_width =
                        (visible_in_row * self.size) +
                        (self.x_spacing * (visible_in_row - 1))

                    local row_x =
                        floor((self:GetWidth() - row_width) / 2) + 1

                    local row_y =
                        (self.icon_height * row_i) +
                        (self.y_spacing * row_i)

                    if self.row_growth == 'DOWN' then
                        row_y = -row_y
                    end

                    button:SetPoint(self.point[1],row_x,row_y)

                    row_i = row_i + 1
                else
                    -- subsequent button in row
                    button:SetPoint(
                        self.point[2], prev, self.point[3],
                        self.x_spacing, 0
                    )
                end

                prev = button
                i = i + 1
            end
        end
    end
end
local function AuraFrame_SetIconSize(self,size)
    -- set icon size and related variables, update buttons
    if not size then
        size = self.size or 24
    end

    self.size = size
    self.icon_height = floor(size * self.squareness)
    self.icon_ratio = (1 - (self.icon_height / size)) / 2

    if type(self.buttons) == 'table' then
        -- update existing buttons
        for k,button in ipairs(self.buttons) do
            button:SetWidth(size)
            button:SetHeight(self.icon_height)
            button.icon:SetTexCoord(.1,.9,.1+self.icon_ratio,.9-self.icon_ratio)
        end

        if self.visible and self.visible > 0 then
            -- re-arrange visible buttons
            self:ArrangeButtons()
        end
    end
end
local function AuraFrame_SetSort(self,sort_f)
    if type(sort_f) == 'number' then
        -- get sorting function from index
        if type(sort_lookup[sort_f]) == 'function' then
            self.sort = sort_lookup[sort_f]
        else
            self.sort = nil
        end
    elseif type(sort_f) == 'function' then
        self.sort = sort_f
    end

    if not self.sort then
        -- or set default
        self.sort = index_sort
    end
end
local function AuraFrame_OnHide(self)
    -- hide all buttons
    if self.parent.IGNORE_VISIBILITY_BUBBLE then return end
    self:HideAllButtons()
end
-- external aura frame functions ###############################################
local function ExternalAuraFrame_UpdateVisibility(self)
    -- show/frame based on visible auras
    -- (_Update does this for standard frames)
    if self.visible and self.visible > 0 then
        self:Show()
    else
        self:Hide()
    end
end
local function ExternalAuraFrame_AddAura(self,uid,icon,count,duration,expiration)
    if not icon then return end
    if not count then count = 1 end
    if not uid then uid = icon end

    if duration and not expiration then
        -- imply expiration
        expiration = GetTime() + duration
    end

    self:DisplayButton(uid,nil,icon,count,duration,expiration)
    self:ArrangeButtons()
    self:UpdateVisibility()

    return self.spellids[uid]
end
local function ExternalAuraFrame_RemoveAura(self,uid,icon)
    if not icon then return end
    if not uid then uid = icon end

    if self.spellids[uid] then
        self:HideButton(self.spellids[uid])
        self:ArrangeButtons()
        self:UpdateVisibility()
    end
end
-- aura frame creation #########################################################
-- aura frame metatable
local aura_meta = {
    squareness = .7,
    x_spacing  = 0,
    y_spacing  = 0,
    pulsate    = true,

    Enable         = AuraFrame_Enable,
    Disable        = AuraFrame_Disable,
    Update         = AuraFrame_Update,
    FactionUpdate  = AuraFrame_FactionUpdate,
    GetAuras       = AuraFrame_GetAuras,
    GetButton      = AuraFrame_GetButton,
    DisplayButton  = AuraFrame_DisplayButton,
    HideButton     = AuraFrame_HideButton,
    HideAllButtons = AuraFrame_HideAllButtons,
    ArrangeButtons = AuraFrame_ArrangeButtons,
    SetIconSize    = AuraFrame_SetIconSize,
    SetSort        = AuraFrame_SetSort,
    ShouldShowAura = AuraFrame_ShouldShowAura,
}
local function CreateAuraFrame(parent)
    local auraframe = CreateFrame('Frame',nil,parent)

    -- mixin prototype (can't actually setmeta on a frame)
    for k,v in pairs(aura_meta) do
        auraframe[k] = v
    end

    auraframe:SetScript('OnHide', AuraFrame_OnHide)

    auraframe.parent = parent
    auraframe.buttons = {}
    auraframe.spellids = {}

    if addon.draw_frames then
        auraframe:SetBackdrop({
            bgFile='interface/buttons/white8x8'
        })
        auraframe:SetBackdropColor(1,1,1,.5)
    end

    return auraframe
end
-- prototype additions #########################################################
function addon.Nameplate.CreateAuraFrame(f,frame_def)
    f = f.parent
    local new_frame = CreateAuraFrame(f)

    -- mixin configuration
    for k,v in pairs(frame_def) do
        new_frame[k] = v
    end

    -- dynamic: buffs on friends, debuffs on enemies, player-cast only
    new_frame.dynamic = not new_frame.filter

    -- set defaults
    if not new_frame.max then
        new_frame.max = 12
    end
    if not new_frame.rows then
        new_frame.rows = 2
    end
    if not new_frame.num_per_row then
        new_frame.num_per_row = floor(new_frame.max / new_frame.rows)
    end
    if not new_frame.row_growth then
        new_frame.row_growth = 'UP'
    end

    if type(new_frame.sort) ~= 'function' then
        new_frame:SetSort(new_frame.sort)
    end

    new_frame.row_point = row_growth_points[new_frame.row_growth]

    new_frame:SetIconSize()

    if not f.Auras then
        f.Auras = {}
    end

    if new_frame.external then
        -- mixin external-only functions
        new_frame.UpdateVisibility = ExternalAuraFrame_UpdateVisibility
        new_frame.AddAura = ExternalAuraFrame_AddAura
        new_frame.RemoveAura = ExternalAuraFrame_RemoveAura

        -- insert into list of external frames
        if not f.Auras.external_frames then
            f.Auras.external_frames = {}
        end

        new_frame.id = new_frame.id or #f.Auras.external_frames+1
        f.Auras.external_frames[new_frame.id] = new_frame
    else
        -- insert into frame list
        if not f.Auras or not f.Auras.frames then
            f.Auras = { frames = {} }
        end

        new_frame.id = new_frame.id or #f.Auras.frames+1
        f.Auras.frames[new_frame.id] = new_frame
    end

    ele:RunCallback('PostCreateAuraFrame',new_frame)

    return new_frame
end
-- messages ####################################################################
function ele:Show(f)
    self:UNIT_FACTION(nil,f)
end
function ele:Hide(f)
    if not f.Auras then return end
    for i,frame in pairs(f.Auras.frames) do
        frame:Hide()
    end
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    -- update each aura frame on this nameplate
    if not f.Auras then return end
    for _,auras_frame in pairs(f.Auras.frames) do
        auras_frame:FactionUpdate()
        auras_frame:Update()
    end
end
function ele:UNIT_AURA(event,f)
    -- update each aura frame on this nameplate
    if not f.Auras then return end
    for _,auras_frame in pairs(f.Auras.frames) do
        auras_frame:Update()
    end
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')

    self:RegisterUnitEvent('UNIT_AURA')
    self:RegisterUnitEvent('UNIT_FACTION')
end
function ele:Initialised()
    if not addon.layout.Auras then
        self:Disable()
        return
    end

    FONT = addon.layout.Auras.font or 'Fonts\\FRIZQT__.TTF'
    FONT_SIZE_CD = addon.layout.Auras.font_size_cd or 12
    FONT_SIZE_COUNT = addon.layout.Auras.font_size_count or 10
    FONT_FLAGS = addon.layout.Auras.font_flags or 'OUTLINE'
end
function ele:Initialise()
    -- register callbacks
    self:RegisterCallback('ArrangeButtons',true)
    self:RegisterCallback('CreateAuraButton',true)
    self:RegisterCallback('PostCreateAuraButton')
    self:RegisterCallback('PostCreateAuraFrame')
    self:RegisterCallback('PostUpdateAuraFrame')
    self:RegisterCallback('DisplayAura',true)
end
