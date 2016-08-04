--[[
    Provides class power icons on nameplates for combo points, shards, etc.

    Icon container is created as addon.ClassPowersFrame after layout
    initialisation.

    In layout initialise
    ====================

    self.ClassPowers = {
        icon_size = size of class power icons
        icon_spacing = space between icons
        icon_texture = texture of class power icons
        icon_glow_texture = texture of class power glow
        cd_texture = cooldown spiral texture
        frame_point = {
            position of the class powers container frame
            1 = point
            2 = relative point frame
            3 = relative point
            4 = x offset
            5 = y offset
        }
        colours = {
            custom class colours for power icons
            [class name] = {
                1 = red,
                2 = green,
                3 = blue
            }
            ...
        }
    }
        Configuration table. Must not be empty.
        Element will not initialise if this is missing or not a table.

    Callbacks
    =========

    PositionIcons
        Can be used to replace the built in icon positioning function.

    CreateIcon
        Can be used to replace the built in function which creates each
        individual power icon.

    PostCreateIcon(icon)
        Called after a power icon is created by the built in CreateIcon
        function.

    PostIconsCreated
        Called after icons are created.

    PostPowerUpdate
        Called after icons are set to active or inactive.

    PostRuneUpdate
        Called after updating rune icon cooldown frames for death knights.

    PostPositionFrame(cpf,parent)
        Called after positioning the icon container frame.

]]
local addon = KuiNameplates
local ele = addon:NewElement('ClassPowers')
local class, power_type, power_type_tag, cpf, initialised
local on_target
local orig_SetVertexColor
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
-- icon config
local colours = {
    DEATHKNIGHT = { 1, .2, .3 },
    DRUID       = { 1, 1, .1 },
    PALADIN     = { 1, 1, .1 },
    ROGUE       = { 1, 1, .1 },
    MAGE        = { .5, .5, 1 },
    MONK        = { .3, 1, .9 },
    WARLOCK     = { 1, .5, 1 },
    overflow    = { 1, .3, .3 },
}

local ICON_SIZE
local ICON_SPACING
local ICON_TEXTURE
local ICON_GLOW_TEXTURE
local CD_TEXTURE
local FRAME_POINT

local ANTICIPATION_TALENT_ID=19240
-- local functions #############################################################
local function IsTalentKnown(id)
    return select(10,GetTalentInfoByID(id))
end
local function PositionIcons()
    -- position icons in the powers container frame
    if ele:RunCallback('PositionIcons') then
        return
    end

    local pv
    local full_size = (ICON_SIZE * #cpf.icons) + (ICON_SPACING * (#cpf.icons - 1))
    cpf:SetWidth(full_size)

    for i,icon in ipairs(cpf.icons) do
        icon:ClearAllPoints()

        if i == 1 then
            icon:SetPoint('LEFT')
        elseif i > 1 then
            icon:SetPoint('LEFT',pv,'RIGHT',ICON_SPACING,0)
        end

        pv = icon
    end
end
local function Icon_SetVertexColor(icon,...)
    -- also set glow colour
    icon.glow:SetVertexColor(...)
    orig_SetVertexColor(icon,...)
end
local function CreateIcon()
    -- create individual icon
    local icon = ele:RunCallback('CreateIcon')

    if not icon then
        icon = cpf:CreateTexture(nil,'ARTWORK',nil,1)
        icon:SetTexture(ICON_TEXTURE)
        icon:SetSize(ICON_SIZE,ICON_SIZE)

        -- TODO glow should probably just be a layout thing
        local ig = cpf:CreateTexture(nil,'ARTWORK',nil,0)
        ig:SetTexture(ICON_GLOW_TEXTURE)
        ig:SetSize(ICON_SIZE+10,ICON_SIZE+10)
        ig:SetPoint('CENTER',icon)
        ig:SetAlpha(.8)

        icon.glow = ig

        if not orig_SetVertexColor then
            orig_SetVertexColor = icon.SetVertexColor
        end
        icon.SetVertexColor = Icon_SetVertexColor

        icon:SetVertexColor(unpack(colours[class]))

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
                self:SetVertexColor(unpack(colours[class]))
                self:SetAlpha(1)
                self.glow:Show()
            end
            icon.Inactive = function(self)
                self:SetVertexColor(unpack(colours[class]))
                self:SetAlpha(.5)
                self.glow:Hide()
            end
            icon.ActiveOverflow = function(self)
                self:SetVertexColor(unpack(colours.overflow))
                self:SetAlpha(1)
                self.glow:Show()
            end
        end
    end

    ele:RunCallback('PostCreateIcon',icon)

    return icon
end
local function CreateIcons()
    -- create/destroy icons based on player power max
    local power_max

    if class == 'ROGUE' and IsTalentKnown(ANTICIPATION_TALENT_ID) then
        power_max = 5
    else
        power_max = UnitPowerMax('player',power_type)
    end

    if cpf.icons then
        if #cpf.icons > power_max then
            -- destroy overflowing icons if powermax has decreased
            for i,icon in ipairs(cpf.icons) do
                if i > power_max then
                    icon:Hide()
                    cpf.icons[i] = nil
                end
            end
        elseif #cpf.icons < power_max then
            -- create new icons
            for i=#cpf.icons+1,power_max do
                cpf.icons[i] = CreateIcon()
            end
        end
    else
        -- create initial icons
        cpf.icons = {}
        for i=1,power_max do
            cpf.icons[i] = CreateIcon()
        end
    end

    PositionIcons()

    ele:RunCallback('PostIconsCreated')
end
local function PowerUpdate()
    -- toggle icons based on current power
    local cur = UnitPower('player',power_type)

    if cur > #cpf.icons then
        -- colour with overflow
        cur = cur - #cpf.icons
        for i,icon in ipairs(cpf.icons) do
            if i <= cur then
                icon:ActiveOverflow()
            else
                icon:Active()
            end
        end
    else
        for i,icon in ipairs(cpf.icons) do
            if i <= cur then
                icon:Active()
            else
                icon:Inactive()
            end
        end
    end

    ele:RunCallback('PostPowerUpdate')
end
local function PositionFrame()
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

    ele:RunCallback('PostPositionFrame',cpf,frame)
end
-- mod functions ###############################################################
function ele:UpdateConfig()
    -- get config from layout
    if not self.enabled then return end
    if type(addon.layout.ClassPowers) ~= 'table' then
        return
    end

    on_target         = addon.layout.ClassPowers.on_target
    ICON_SIZE         = addon.layout.ClassPowers.icon_size or 10
    ICON_SPACING      = addon.layout.ClassPowers.icon_spacing or 1
    ICON_TEXTURE      = addon.layout.ClassPowers.icon_texture
    ICON_GLOW_TEXTURE = addon.layout.ClassPowers.glow_texture
    CD_TEXTURE        = addon.layout.ClassPowers.cd_texture
    FRAME_POINT       = addon.layout.ClassPowers.point

    if on_target then
        self:RegisterMessage('GainedTarget','TargetUpdate')
        self:RegisterMessage('LostTarget','TargetUpdate')
    else
        self:UnregisterMessage('GainedTarget')
        self:UnregisterMessage('LostTarget')
    end

    if type(addon.layout.ClassPowers.colours) == 'table' then
        if addon.layout.ClassPowers.colours[class] then
            colours[class] = addon.layout.ClassPowers.colours[class]
        end
        if addon.layout.ClassPowers.colours.overflow then
            colours.overflow = addon.layout.ClassPowers.colours.overflow
        end
    end

    ICON_SIZE = ICON_SIZE * addon.uiscale

    if cpf then
        -- update existing frame
        cpf:SetHeight(ICON_SIZE)

        if cpf.icons then
            -- update icons
            for k,i in ipairs(cpf.icons) do
                i:SetSize(ICON_SIZE,ICON_SIZE)
                i:SetTexture(ICON_TEXTURE)

                i.glow:SetSize(ICON_SIZE+10,ICON_SIZE+10)
                i.glow:SetTexture(ICON_GLOW_TEXTURE)

                if i.cd then
                    i.cd:SetSwipeTexture(CD_TEXTURE)
                end
            end

            PositionIcons()
            PositionFrame()
        end
    end
end
-- messages ####################################################################
function ele:TargetUpdate(f)
    PositionFrame()
end
-- events ######################################################################
function ele:PLAYER_ENTERING_WORLD()
    -- update icons upon zoning. just in case.
    PowerUpdate()
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

        CreateIcons()

        -- set initial state
        if class ~= 'DEATHKNIGHT' then
            PowerUpdate()
        end

        -- set initial position
        PositionFrame()
    else
        self:UnregisterEvent('PLAYER_ENTERING_WORLD')
        self:UnregisterEvent('UNIT_MAXPOWER')
        self:UnregisterEvent('UNIT_POWER')
        self:UnregisterEvent('RUNE_POWER_UPDATE')

        self:UnregisterMessage('Show')
        self:UnregisterMessage('GainedTarget')
        self:UnregisterMessage('LostTarget')
        self:UnregisterMessage('HealthColourChange')

        cpf:Hide()
    end
end
function ele:RuneUpdate(event,rune_id,energise)
    -- set cooldown on rune icons
    local startTime, duration, charged = GetRuneCooldown(rune_id)
    local icon = cpf.icons[rune_id]
    if not icon then return end

    if charged or energise then
        icon.cd:Hide()
        icon.glow:Show()
    else
        icon.cd:SetCooldown(startTime, duration)
        icon.cd:Show()
        icon.glow:Hide()
    end

    self:RunCallback('PostRuneUpdate')
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
function ele:OnEnable()
    if not initialised then return end
    if not cpf then
        self:Disable()
        return
    end

    self:UpdateConfig()
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    self:PowerInit()
end
function ele:OnDisable()
    if cpf then
        cpf:Hide()
    end
end
function ele:Initialised()
    initialised = true
    class = select(2,UnitClass('player'))

    if  type(addon.layout.ClassPowers) ~= 'table' or
        not powers[class]
    then
        -- layout didn't initialise us, or this class has no special power
        self:Disable()
        return
    end

    -- create icon frame container
    cpf = CreateFrame('Frame')
    cpf:SetPoint('CENTER')
    cpf:Hide()

    addon.ClassPowersFrame = cpf

    if self.enabled then
        -- call this again since it's blocked until Initialised runs
        self:OnEnable()
    end
end
function ele:Initialise()
    -- register callbacks
    self:RegisterCallback('PositionIcons')
    self:RegisterCallback('CreateIcon',true)
    self:RegisterCallback('PostCreateIcon')
    self:RegisterCallback('PostIconsCreated')
    self:RegisterCallback('PostRuneUpdate')
    self:RegisterCallback('PostPowerUpdate')
    self:RegisterCallback('PostPositionFrame')
end
