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
        sort = aura sorting function
        filter = filter used in UnitAura calls
        num_per_row = number of icons per row;
                      if left nil, calculates as max / rows
        whitelist = a table of spellids to to show in the aura frame
        kui_whitelist = use the whitelist provided by KuiSpellList
    }

    Callbacks
    =========

    ArrangeButtons(auraframe)
        Used to replace the built in ArrangeButtons function which arranges the
        aura buttons in the aura frame whenever they are updated.

    CreateAuraButton(auraframe)
        Used to replace the built in CreateAuraButton function. Button functions
        will be mixed-in to the returned frame which can then be edited via the
        PostCreateAuraButton callback.

    PostCreateAuraButton(button)
        Called after an aura button is created.

    PostCreateAuraFrame(auraframe)
        Called after an aura frame is created.

    DisplayAura(name,spellid,duration)
        Can be used to arbitrarily filter auras.

]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('Auras')

local FONT,FONT_SIZE_CD,FONT_SIZE_COUNT,FONT_FLAGS

local spelllist,whitelist

local class
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

        if remaining <= 2 then
            -- faster updates in the last 2 seconds
            self.cd_elap = .05
        else
            self.cd_elap = .5
        end

        if remaining <= 5 then
            self.cd:SetTextColor(1,0,0)
        else
            self.cd:SetTextColor(1,1,0)
        end

        if remaining <= 1 then
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
        cd:SetPoint('CENTER')

        local count = button:CreateFontString(nil,'OVERLAY')
        count:SetFont(FONT, FONT_SIZE_COUNT, FONT_FLAGS)
        count:SetPoint('BOTTOMRIGHT', 2, -2)
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

    ele:RunCallback('PostCreateAuraButton',button)

    return button
end
-- aura frame functions ########################################################
local function AuraFrame_Update(self)
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
    else
        self:Hide()
    end
end
local function AuraFrame_GetAuras(self)
    for i=1,40 do
        local name,_,icon,count,_,duration,expiration,_,_,_,spellid =
            UnitAura(self.parent.unit, i, self.filter)
--            'test',nil,'interface/icons/inv_dhmount',0,0,100,GetTime()+100,nil,nil,nil,math.random(1,100000)
        if not name then break end

        self:DisplayButton(name,icon,spellid,count,duration,expiration,i)
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
local function AuraFrame_DisplayButton(self,name,icon,spellid,count,duration,expiration,index)
    if  self.kui_whitelist and whitelist and
        not whitelist[spellid] and not whitelist[strlower(name)]
    then
        -- not in kui whitelist
        return
    elseif self.whitelist and
           not self.whitelist[spellid] and not self.whitelist[strlower(name)]
    then
        -- not in provided whitelist
        return
    end

    if ele:RunCallback('DisplayAura',name,spellid,duration) == false then
        -- blocked by callback
        return
    end

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
end
local function AuraFrame_ArrangeButtons(self)
    if ele:RunCallback('ArrangeButtons',self) then
        return
    end

    table.sort(self.buttons, auras_sort)

    local prev,prev_row
    self.visible = 0

    for _,button in ipairs(self.buttons) do
        if button.spellid then
            if not self.max or self.visible < self.max then
                self.visible = self.visible + 1
                button:ClearAllPoints()

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
                button:Show()
            else
                button:Hide()
            end
        end
    end
end
local function AuraFrame_OnHide(self)
    -- hide all buttons
    self:HideAllButtons()
end
-- aura frame creation #########################################################
-- aura frame metatable
local aura_meta = {
    size       = 24,
    squareness = .7,
    x_spacing  = 0,
    y_spacing  = 0,
    sort       = time_sort,
    pulsate    = true,
    timer_threshold = 20,

    Update         = AuraFrame_Update,
    GetAuras       = AuraFrame_GetAuras,
    GetButton      = AuraFrame_GetButton,
    DisplayButton  = AuraFrame_DisplayButton,
    HideButton     = AuraFrame_HideButton,
    HideAllButtons = AuraFrame_HideAllButtons,
    ArrangeButtons = AuraFrame_ArrangeButtons,
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

    ele:RunCallback('PostCreateAuraFrame',auraframe)

    return auraframe
end
-- whitelist ###################################################################
function ele:WhitelistChanged()
    whitelist = spelllist.GetImportantSpells(class)
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

    new_frame.row_point = row_growth_points[new_frame.row_growth]

    new_frame.icon_height = floor(new_frame.size * new_frame.squareness)
    new_frame.icon_ratio = (1 - (new_frame.icon_height / new_frame.size)) / 2

    if new_frame.kui_whitelist and not whitelist then
        -- initialise KuiSpellList whitelist
        spelllist = LibStub('KuiSpellList-1.0')
        spelllist.RegisterChanged(ele,'WhitelistChanged')
        ele:WhitelistChanged()
    end

    -- insert into frame list
    if not f.Auras or not f.Auras.frames then
        f.Auras = { frames = {} }
    end
    tinsert(f.Auras.frames,new_frame)

    return new_frame
end
-- messages ####################################################################
function ele:Show(f)
    self:UNIT_FACTION(nil,f)
end
function ele:Hide(f)
    if not f.Auras then return end
    for i,frame in ipairs(f.Auras.frames) do
        frame:Hide()
    end
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    -- update each aura frame on this nameplate
    if not f.Auras then return end
    for _,auras_frame in ipairs(f.Auras.frames) do
        if auras_frame.dynamic then
            -- update filter on faction change if dynamic
            if UnitIsFriend('player',f.unit) then
                auras_frame.filter = 'PLAYER HELPFUL'
            else
                auras_frame.filter = 'PLAYER HARMFUL'
            end
        end

        auras_frame:Update()
    end
end
function ele:UNIT_AURA(event,f)
    -- update each aura frame on this nameplate
    if not f.Auras then return end
    for _,auras_frame in ipairs(f.Auras.frames) do
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

    class = select(2,UnitClass('player'))
end
function ele:Initialise()
    -- register callbacks
    self:RegisterCallback('ArrangeButtons')
    self:RegisterCallback('CreateAuraButton',true)
    self:RegisterCallback('PostCreateAuraButton')
    self:RegisterCallback('PostCreateAuraFrame')
    self:RegisterCallback('DisplayAura',true)

    self:RegisterMessage('Initialised')
end
