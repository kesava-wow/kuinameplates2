--[[
    Provides aura frames to the layout based on table configuration.

    Aura frames are created on each nameplate when the Create message is
    dispatched. They are listed in the table: frame.Auras.frames

    In layout initialise
    ====================

    self.Auras = {}
        Table of frame definitions. Must have numeric index.
        Element will not run if this is missing or empty.

    Frame definition values
    =======================

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

    Callbacks
    =========

    layout.Auras_ArrangeButtons(auraframe)
        Used to replace the built in auraframe:ArrangeButtons function which
        arranges the aura buttons whenever they are updated.

    layout.Auras_CreateAuraButton(auraframe)
        Used to replace the built in CreateAuraButton function. Should return
        a 100% compatible frame.

    layout.Auras_PostCreateAuraButton(button)
        Called after a button is created by the built in CreateAuraButton
        function.

]]
local addon = KuiNameplates
local ele = addon:NewElement('auras')
-- row growth lookup table
local row_growth_points = {
    UP = {'BOTTOM','TOP'},
    DOWN = {'TOP','BOTTOM'}
}
-- callback functions
local cb_CreateAuraButton, cb_PostCreateAuraButton, cb_ArrangeButtons
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
    self.cd_elap = (self.cd_elap or 1) + elapsed
    if self.cd_elap > (self.cd_period or .1) then
        local remaining = self.expiration - GetTime()

        if remaining > 20 then
            self.cd_period = 1
            self.cd:SetText('')
            return
        end

        if remaining <= 2 then
            self.cd_period = .05
        else
            self.cd_period = .5
        end

        if remaining <= 5 then
            self.cd:SetTextColor(1,0,0)
        else
            self.cd:SetTextColor(1,1,0)
        end

        if remaining <= 0 then
            remaining = 0
        elseif remaining <= 1 then
            remaining = format("%.1f", remaining)
        else
            remaining = format("%.f", remaining)
        end

        self.cd:SetText(remaining)
        self.cd_elap = 0
    end
end
local function button_UpdateCooldown(self,duration,expiration)
    if expiration and expiration > 0 then
        self.expiration = expiration
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
-- button creation #############################################################
local function CreateAuraButton(parent)
    if cb_CreateAuraButton then
        return cb_CreateAuraButton(parent)
    end

    local button = CreateFrame('Frame',nil,parent)
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

    -- TODO CooldownFrames don't like being moved ?

    local cd = button:CreateFontString(nil,'OVERLAY')
    cd:SetFont('Fonts\\FRIZQT__.TTF', 12, 'OUTLINE')
    cd:SetPoint('CENTER')

    button.parent = parent
    button.icon   = icon
    button.cd     = cd

    button.UpdateCooldown = button_UpdateCooldown
    button.SetTexture     = button_SetTexture

    if cb_PostCreateAuraButton then
        cb_PostCreateAuraButton(button)
    end

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

    if self.visible > 0 then
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
local function AuraFrame_GetButton(self)
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
    local button = self:GetButton(spellid)

    button:SetTexture(icon)
    button.used = true
    button.spellid = spellid
    button.index = index

    button:UpdateCooldown(duration,expiration)

    self.spellids[spellid] = button
end
local function AuraFrame_HideButton(self,button)
    if button.spellid then
        self.spellids[button.spellid] = nil
    end

    -- hide cooldown
    button:UpdateCooldown()

    button.duration   = nil
    button.expiration = nil
    button.cd_elap    = nil
    button.cd_period  = nil
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
    if cb_ArrangeButtons then
        cb_ArrangeButtons(self)
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
    if self.parent.MOVING then return end
    -- hide all buttons
    self:HideAllButtons()
end
-- aura frame metatable
local aura_meta = {
    size       = 24,
    squareness = .7,
    x_spacing  = 0,
    y_spacing  = 0,
    sort       = time_sort,

    Update         = AuraFrame_Update,
    GetAuras       = AuraFrame_GetAuras,
    GetButton      = AuraFrame_GetButton,
    DisplayButton  = AuraFrame_DisplayButton,
    HideButton     = AuraFrame_HideButton,
    HideAllButtons = AuraFrame_HideAllButtons,
    ArrangeButtons = AuraFrame_ArrangeButtons,
}
-- aura frame creation #########################################################
local function CreateAuraFrame(parent)
    local auraframe = CreateFrame('Frame',nil,parent)

    -- mixin prototype (can't actually setmeta on a frame)
    for k,v in pairs(aura_meta) do
        auraframe[k] = v
    end

    auraframe:SetScript('OnHide', AuraFrame_OnHide)

    -- dynamic: buffs on friends, debuffs on enemies, player-cast only
    auraframe.dynamic = not auraframe.filter

    auraframe.parent = parent
    auraframe.buttons = {}
    auraframe.spellids = {}

    return auraframe
end
-- messages ####################################################################
function ele.Create(f)
    f.Auras = { frames = {} }

    for i,frame_def in ipairs(addon.layout.Auras) do
        local new_frame = CreateAuraFrame(f)

        -- mixin configuration
        for k,v in pairs(frame_def) do
            new_frame[k] = v
        end

        new_frame.max = new_frame.max or 12

        new_frame.icon_height = new_frame.size * new_frame.squareness
        new_frame.icon_ratio = (1 - (new_frame.icon_height / new_frame.size)) / 2

        -- positioning stuff
        if new_frame.rows then
            if not new_frame.num_per_row then
                new_frame.num_per_row = floor(new_frame.max / new_frame.rows)
            end

            if not new_frame.row_growth then
                new_frame.row_growth = 'UP'
            end

            new_frame.row_point = row_growth_points[new_frame.row_growth]
        end

        f.Auras.frames[i] = new_frame
    end
end
function ele.Show(f)
    ele:UNIT_FACTION(nil,f)
end
function ele.Hide(f)
    for i,frame in ipairs(f.Auras.frames) do
        frame:Hide()
    end
end
function ele.Initialised()
    if type(addon.layout.Auras) ~= 'table' or #addon.layout.Auras == 0 then
        -- no frame definitions
        return
    end

    -- populate callbacks
    if type(addon.layout.Auras_ArrangeButtons) == 'function' then
        cb_ArrangeButtons = addon.layout.Auras_ArrangeButtons
    end
    if type(addon.layout.Auras_CreateAuraButton) == 'function' then
        cb_CreateAuraButton = addon.layout.Auras_CreateAuraButton
    end
    if type(addon.layout.Auras_PostCreateAuraButton) == 'function' then
        cb_PostCreateAuraButton = addon.layout.Auras_PostCreateAuraButton
    end

    ele:RegisterMessage('Create')
    ele:RegisterMessage('Show')
    ele:RegisterMessage('Hide')

    ele:RegisterUnitEvent('UNIT_AURA')
    ele:RegisterUnitEvent('UNIT_FACTION')
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    for _,auras_frame in ipairs(f.Auras.frames) do
        if auras_frame.dynamic then
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
    for _,auras_frame in ipairs(f.Auras.frames) do
        auras_frame:Update()
    end
end
-- register ####################################################################
ele:RegisterMessage('Initialised')
