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

]]
local addon = KuiNameplates
local ele = addon:NewElement('classpowers')
local class, power_type, power_type_tag, cpf
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
-- i think i see a pattern
local power_tags = {
    [SPELL_POWER_RUNES]          = 'RUNES',
    [SPELL_POWER_COMBO_POINTS]   = 'COMBO_POINTS',
    [SPELL_POWER_HOLY_POWER]     = 'HOLY_POWER',
    [SPELL_POWER_ARCANE_CHARGES] = 'ARCANE_CHARGES',
    [SPELL_POWER_CHI]            = 'CHI',
    [SPELL_POWER_SOUL_SHARDS]    = 'SOUL_SHARDS'

}
-- TODO configurable by the layout
local ICON_SIZE = 10
local ICON_TEXTURE = 'interface/addons/kui_nameplates/media/combopoint-round'
local CD_TEXTURE = 'interface/playerframe/classoverlay-runecooldown'
-- local functions #############################################################
local function PositionIcons()
    -- position icons in the powers container frame
    local pv
    local full_size = (ICON_SIZE * #cpf.icons) + (1 * (#cpf.icons - 1))

    for i,icon in ipairs(cpf.icons) do
        icon:ClearAllPoints()

        if i == 1 then
            icon:SetPoint('CENTER',-(full_size / 2),0)
        elseif i > 1 then
            icon:SetPoint('LEFT',pv,'RIGHT',1,0)
        end

        pv = icon
    end
end
local function CreateIcon()
    -- create individual icon
    local icon = cpf:CreateTexture(nil,'BACKGROUND')
    icon:SetTexture(ICON_TEXTURE)
    icon:SetSize(ICON_SIZE,ICON_SIZE)

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
        end
        icon.Inactive = function(self)
            self:SetAlpha(.3)
        end
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

    if type(addon.layout.ClassPowers_PositionIcons) == 'function' then
        addon.layout.ClassPowers_PositionIcons()
    else
        PositionIcons()
    end

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

    addon:DispatchMessage('ClassPowers_PowerUpdate')
end
-- messages ####################################################################
function ele.Initialised()
    -- icon frame container TODO floats on the target nameplate
    cpf = CreateFrame('Frame')
    cpf:SetSize(100,100)
    cpf:SetPoint('CENTER')
    cpf:Hide()

    ele:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    ele:PowerInit()

    addon.ClassPowersFrame = cpf
end
-- events ######################################################################
function ele:PLAYER_ENTERING_WORLD()
    -- update icons upon zoning. just in case.
    PowerUpdate()
end
function ele:TargetUpdate()
    -- TODO
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
            ele:RegisterEvent('RUNE_POWER_UPDATE','RuneUpdate')
        else
            ele:RegisterEvent('PLAYER_ENTERING_WORLD')
            ele:RegisterEvent('UNIT_MAXPOWER','PowerEvent')
            ele:RegisterEvent('UNIT_POWER','PowerEvent')
        end

        ele:RegisterEvent('PLAYER_TARGET_CHANGED','TargetUpdate')

        CreateIcons()
        cpf:Show()
    else
        ele:UnregisterEvent('PLAYER_TARGET_CHANGED')
        ele:UnregisterEvent('PLAYER_ENTERING_WORLD')
        ele:UnregisterEvent('UNIT_MAXPOWER')
        ele:UnregisterEvent('UNIT_POWER')
        cpf:Hide()
    end
end
function ele:RuneUpdate(event,rune_id)
    -- set cooldown on rune icons
    local startTime, duration, charged = GetRuneCooldown(rune_id)
    local cd = cpf.icons[rune_id].cd

    cd:SetCooldown(startTime, duration)
    cd:Show()

    addon:DispatchMessage('ClassPowers_RuneUpdate')
end
function ele:PowerEvent(event,f,unit,power_type_rcv)
    -- validate power events + passthrough to PowerUpdate
    if unit ~= 'player' then return end
    if power_type_rcv ~= power_type_tag then return end

    if event == 'UNIT_MAXPOWER' then
        CreateIcons()
    end

    PowerUpdate()
end
-- register ####################################################################
function ele:Initialise()
    class = select(2,UnitClass('player'))
    if not powers[class] then return end

    self:RegisterMessage('Initialised')
end
