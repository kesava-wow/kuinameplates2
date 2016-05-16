-- class powers on nameplates (combo points, shards, etc)
local addon = KuiNameplates
local ele = addon:NewElement('classpowers')
local class, power_type
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
-- local functions #############################################################
-- prototype additions #########################################################
-- messages ####################################################################
function ele.Initialised()
    if type(addon.layout.ClassPowers) ~= 'table' then return end

    self:PowerInit()

    -- create icon frames
    local cpf = CreateFrame('Frame')
    -- TODO reparent to current target etc
    cpf:SetPoint('CENTER')

    if class == 'DEATHKNIGHT' then
        -- add a cooldown frame to the icons
        for i,icon in ipairs(addon.layout.ClassPowers) do
            local cd = CreateFrame('Cooldown',nil,icon,'CooldownFrameTemplate')
            -- TODO etc
        end
    end

    ele:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    ele:RegisterEvent('PLAYER_TARGET_CHANGED','TargetUpdate')

    addon.ClassPowersFrame = cpf
    addon:DispatchMessage('ClassPowersCreated')
end
-- events ######################################################################
function ele:PowerInit()
    if class == 'DEATHKNIGHT' then
        ele:RegisterEvent('RUNE_POWER_UPDATE','RuneUpdate')
        return
    end

    if type(powers[class]) == 'table' then
        local spec = GetSpecilization()
        power_type = powers[class][spec]
    else
        power_type = powers[class]
    end

    if power_type then
        ele:RegisterEvent('UNIT_MAXPOWER','PowerUpdate')
        ele:RegisterEvent('UNIT_POWER','PowerUpdate')
    else
        ele:UnregisterEvent('UNIT_MAXPOWER')
        ele:UnregisterEvent('UNIT_POWER')
    end
end
function ele:RuneUpdate(event,rune_id)
    local startTime, duration, charged = GetRuneCooldown(rune_id)
end
function ele:PowerUpdate(event,f,unit,power_type_rcv)
    if unit ~= 'player' then return end
    if power_type_rcv == power_type then return end

    f = C_NamePlate.GetNamePlateForUnit('target')
    if not f then return end

    local cur,max =
        UnitPower(unit,power_type),
        UnitPowerMax(unit,power_type)

    if type(addon.layout.ClassPowers) == 'table' then
        for i,icon in ipairs(addon.layout.ClassPowers) do
            if cur > i then
                icon:Active()
            else
                icon:Inactive()
            end
        end
    end
end
-- register ####################################################################
function ele:Initialise()
    class = select(2,UnitClass('player'))
    if not powers[class] then return end

    self:RegisterMessage('Initialised')
end
