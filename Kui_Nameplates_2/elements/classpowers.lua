-- class powers on nameplates (combo points, shards, etc)
local addon = KuiNameplates
local ele = addon:NewElement('classpowers')
local class
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
-- prototype additions #########################################################
-- messages ####################################################################
-- events ######################################################################
function ele:PowerInit(event)
    local power_type
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
function ele:PowerUpdate(event,f,unit)
    if unit ~= 'player' then return end
end
-- register ####################################################################
function ele:Initialise()
    class = select(2,UnitClass('player'))
    if not powers[class] then return end

    ele:RegisterEvent('PLAYER_LOGIN','PowerInit')
    ele:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
end
