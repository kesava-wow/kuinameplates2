--[[
--  Provides class power icons on nameplates for combo points, shards, etc.

    Icon container is created as addon.ClassPowersFrame after layout
    initialisation.

    Messages
    ========

    ClassPowers_IconsCreated
        After icons are created.

    ClassPowers_PowerUpdate
        After icons are set to active or inactive.

    ClassPowers_RuneUpdate
        After updating rune icon cooldown frames for death knights.

    Callbacks
    =========

    layout.ClassPowers_PositionIcons
        Can be used to replace the built in icon positioning function.

    layout.ClassPowers_CreateIcon
        Can be used to replace the built in function which creates each
        individual power icon.

    layout.ClassPowers_PostCreateIcon(icon)
        Called after a power icon is created by the built in CreateIcon
        function.

]]
-- TODO sometimes hides during combat (or just every so often)
local addon = KuiNameplates
local ele = addon:NewElement('ClassPowers')
local class, power_type, power_type_tag, cpf
local on_target
-- power types by class/spec
local powers = {
    DEATHKNIGHT = SPELL_POWER_RUNES,
    DRUID       = { [2] = SPELL_POWER_COMBO_POINTS },
    PALADIN     = { [3] = SPELL_POWER_HOLY_POWER },
    ROGUE       = SPELL_POWER_COMBO_POINTS,
    MAGE        = { [1] = SPELL_POWER_ARCANE_CHARGES },
    MONK        = { [3] = SPELL_POWER_CHI },
    WARLOCK     = SPELL_POWER_SOUL_SHARDS,
}
-- tags returned by the UNIT_POWER and UNIT_MAXPOWER events
local power_tags = {
    [SPELL_POWER_RUNES]          = 'RUNES',
    [SPELL_POWER_COMBO_POINTS]   = 'COMBO_POINTS',
    [SPELL_POWER_HOLY_POWER]     = 'HOLY_POWER',
    [SPELL_POWER_ARCANE_CHARGES] = 'ARCANE_CHARGES',
    [SPELL_POWER_CHI]            = 'CHI',
    [SPELL_POWER_SOUL_SHARDS]    = 'SOUL_SHARDS'
}
-- callback functions
local cb_PositionIcons, cb_CreateIcon, cb_PostCreateIcon
-- icon config
local colours = {
    DEATHKNIGHT = { 1, .2, .3 },
    DRUID       = { 1, 1, .1 },
    PALADIN     = { 1, 1, .1 },
    ROGUE       = { 1, 1, .1 },
    MAGE        = { .5, .5, 1 },
    MONK        = { .3, 1, .9 },
    WARLOCK     = { 1, .5, 1 },
}
local ICON_SIZE
local ICON_TEXTURE
local ICON_GLOW_TEXTURE
local CD_TEXTURE
local FRAME_POINT
-- local functions #############################################################
local function PositionIcons()
    -- position icons in the powers container frame
    if cb_PositionIcons then
        cb_PositionIcons()
        return
    end

    local pv
    local full_size = (ICON_SIZE * #cpf.icons) + (1 * (#cpf.icons - 1))
    cpf:SetWidth(full_size)

    for i,icon in ipairs(cpf.icons) do
        icon:ClearAllPoints()

        if i == 1 then
            icon:SetPoint('LEFT')
        elseif i > 1 then
            icon:SetPoint('LEFT',pv,'RIGHT',1,0)
        end

        pv = icon
    end
end
local function CreateIcon()
    -- create individual icon
    if cb_CreateIcon then
        return cb_CreateIcon()
    end

    local icon = cpf:CreateTexture(nil,'ARTWORK',nil,1)
    icon:SetTexture(ICON_TEXTURE)
    icon:SetSize(ICON_SIZE,ICON_SIZE)

    -- TODO glow should probably just be a layout thing
    local ig = cpf:CreateTexture(nil,'ARTWORK',nil,0)
    ig:SetTexture(ICON_GLOW_TEXTURE)
    ig:SetSize(ICON_SIZE+10,ICON_SIZE+10)
    ig:SetPoint('CENTER',icon)
    ig:SetAlpha(.8)

    icon.glow = ig

    icon:SetVertexColor(unpack(colours[class]))
    ig:SetVertexColor(unpack(colours[class]))

    if class == 'DEATHKNIGHT' then
        -- also create a cooldown frame for runes
        local cd = CreateFrame('Cooldown',nil,cpf,'CooldownFrameTemplate')
        cd:SetSwipeTexture(CD_TEXTURE)
        cd:SetAllPoints(icon)
        cd:SetDrawEdge(false)
        cd:SetHideCountdownNumbers(true)
        icon.cd = cd
    else
        icon.Active = function(self)
            self:SetAlpha(1)
            self.glow:Show()
        end
        icon.Inactive = function(self)
            self:SetAlpha(.5)
            self.glow:Hide()
        end
    end

    if cb_PostCreateIcon then
        cb_PostCreateIcon(icon)
    end

    return icon
end
local function CreateIcons()
    -- create/destroy icons based on player_power_max
    local powermax = UnitPowerMax('player',power_type)

    if cpf.icons then
        if #cpf.icons > powermax then
            -- destroy overflowing icons if powermax has decreased
            for i,icon in ipairs(cpf.icons) do
                if i > powermax then
                    icon:Hide()
                    cpf.icons[i] = nil
                end
            end
        elseif #cpf.icons < powermax then
            -- create new icons
            for i=#cpf.icons+1,powermax do
                cpf.icons[i] = CreateIcon()
            end
        end
    else
        -- create initial icons
        cpf.icons = {}
        for i=1,powermax do
            cpf.icons[i] = CreateIcon()
        end
    end

    PositionIcons()

    -- TODO should be a callback
    addon:DispatchMessage('ClassPowers_IconsCreated')
end
local function PowerUpdate()
    -- toggle icons based on current power
    local cur = UnitPower('player',power_type)
    for i,icon in ipairs(cpf.icons) do
        if i <= cur then
            icon:Active()
        else
            icon:Inactive()
        end
    end

    -- TODO should be a callback
    addon:DispatchMessage('ClassPowers_PowerUpdate')
end
local function SetPosition()
    local frame

    if on_target then
        if UnitIsPlayer('target') or UnitCanAttack('player','target') then
            frame = C_NamePlate.GetNamePlateForUnit('target')

            if frame and frame.kui.state.reaction <= 4 then
                frame = frame.kui
            else
                frame = nil
            end
        end
    else
        frame = C_NamePlate.GetNamePlateForUnit('player')
        frame = frame and frame.kui or nil
    end

    if not frame then
        cpf:Hide()
        return
    end

    local parent = frame[FRAME_POINT[2]]

    if parent then
        cpf:ClearAllPoints()
        cpf:SetParent(frame)
        cpf:SetFrameLevel(frame:GetFrameLevel()+1)
        cpf:SetPoint(
            FRAME_POINT[1],
            parent,
            FRAME_POINT[3],
            FRAME_POINT[4],
            FRAME_POINT[5]
        )
        cpf:Show()
    else
        cpf:Hide()
    end
end
-- messages ####################################################################
function ele:TargetUpdate(f)
    SetPosition()
end
-- events ######################################################################
function ele:PLAYER_ENTERING_WORLD()
    -- update icons upon zoning. just in case.
    PowerUpdate()
end
function ele:CVAR_UPDATE()
    on_target = GetCVarBool('nameplateResourceOnTarget')

    if on_target then
        self:RegisterMessage('GainedTarget','TargetUpdate')
        self:RegisterMessage('LostTarget','TargetUpdate')
    else
        self:UnregisterMessage('TargetGained')
        self:UnregisterMessage('TargetLost')
    end
end
function ele:PowerInit()
    -- get current power type, register events
    if type(powers[class]) == 'table' then
        local spec = GetSpecialization()
        power_type = powers[class][spec]
    else
        power_type = powers[class]
    end

    if power_type then
        power_type_tag = power_tags[power_type]

        if class == 'DEATHKNIGHT' then
            self:RegisterEvent('RUNE_POWER_UPDATE','RuneUpdate')
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('UNIT_MAXPOWER','PowerEvent')
            self:RegisterEvent('UNIT_POWER','PowerEvent')
        end

        self:RegisterMessage('Show','TargetUpdate')
        self:RegisterMessage('HealthColourChange','TargetUpdate')

        -- for nameplateResourceOnTarget
        self:RegisterEvent('CVAR_UPDATE')
        self:CVAR_UPDATE()

        CreateIcons()
    else
        self:UnregisterEvent('PLAYER_ENTERING_WORLD')
        self:UnregisterEvent('UNIT_MAXPOWER')
        self:UnregisterEvent('UNIT_POWER')
        self:UnregisterEvent('CVAR_UPDATE')
        self:UnregisterEvent('RUNE_POWER_UPDATE')

        self:UnregisterMessage('Show')
        self:UnregisterMessage('TargetGained')
        self:UnregisterMessage('TargetLost')
        self:UnregisterMessage('HealthColourChange')
    end
end
function ele:RuneUpdate(event,rune_id,energise)
    -- set cooldown on rune icons
    local startTime, duration, charged = GetRuneCooldown(rune_id)
    local icon = cpf.icons[rune_id]

    if charged or energise then
        icon.cd:Hide()
        icon.glow:Show()
    else
        icon.cd:SetCooldown(startTime, duration)
        icon.cd:Show()
        icon.glow:Hide()
    end

    -- TODO should be a callback
    addon:DispatchMessage('ClassPowers_RuneUpdate')
end
function ele:PowerEvent(event,unit,power_type_rcv)
    -- validate power events + passthrough to PowerUpdate
    if unit ~= 'player' then return end
    if power_type_rcv ~= power_type_tag then return end

    if event == 'UNIT_MAXPOWER' then
        CreateIcons()
    end

    PowerUpdate()
end
-- register ####################################################################
function ele:Initialised()
    if not addon.layout.ClassPowers then return end

    class = select(2,UnitClass('player'))
    if not powers[class] then return end

    -- TODO move these to callback helper (auras)
    -- populate callbacks
    if type(addon.layout.ClassPowers_PositionIcons) == 'function' then
        cb_PositionIcons = addon.layout.ClassPowers_PositionIcons
    end
    if type(addon.layout.ClassPowers_CreateIcon) == 'function' then
        cb_CreateIcon = addon.layout.ClassPowers_CreateIcon
    end
    if type(addon.layout.ClassPowers_PostCreateIcon) == 'function' then
        cb_PostCreateIcon = addon.layout.ClassPowers_PostCreateIcon
    end

    -- TODO add to documentation
    if type(addon.layout.ClassPowers) == 'table' then
        -- get config from layout
        ICON_SIZE         = addon.layout.ClassPowers.icon_size
        ICON_TEXTURE      = addon.layout.ClassPowers.icon_texture
        ICON_GLOW_TEXTURE = addon.layout.ClassPowers.glow_texture
        CD_TEXTURE        = addon.layout.ClassPowers.cd_texture
        FRAME_POINT       = addon.layout.ClassPowers.point

        if type(addon.layout.ClassPowers.colours) == 'table' and
           addon.layout.ClassPowers.colours[class]
        then
            colours[class] = addon.layout.ClassPowers.colours[class]
        end
    end

    ICON_SIZE = ICON_SIZE * addon.uiscale

    -- icon frame container
    cpf = CreateFrame('Frame')
    cpf:SetHeight(ICON_SIZE)
    cpf:SetPoint('CENTER')
    cpf:Hide()

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    self:PowerInit()

    addon.ClassPowersFrame = cpf
end

ele:RegisterMessage('Initialised')
