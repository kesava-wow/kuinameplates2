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
function ele:Update()
end
-- register ####################################################################
function ele:Initialise()
    class = select(2,UnitClass('player'))

    ele:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','Update')
    ele:RegisterEvent('UNIT_MAXPOWER','Update')
end
