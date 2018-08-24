--[[
--  sets nameplate show/hide variables uponing entering/leaving combat

    in layout initialise
    ====================

    self.CombatToggle = {
        hostile = 1-3,
        friendly = 1-3
    }
        Configuration table.
        Can be modified during runtime.
        Element will not initialise if this is missing or not a table.
]]
local addon = KuiNameplates
local mod = addon:NewPlugin('CombatToggle',nil,nil,false)

-- actions cached upon entering combat and inverted upon leaving
local ati_hostile,ati_friendly

-- mod functions ###############################################################
-- events ######################################################################
function mod:PLAYER_REGEN_DISABLED()
    if type(addon.layout.CombatToggle) ~= 'table' then
        return
    end

    ati_hostile = addon.layout.CombatToggle.hostile
    ati_friendly = addon.layout.CombatToggle.friendly

    if ati_hostile and ati_hostile > 1 then
        SetCVar('nameplateShowEnemies',ati_hostile == 3 and 1 or 0)
    end
    if ati_friendly and ati_friendly > 1 then
        SetCVar('nameplateShowFriends',ati_friendly == 3 and 1 or 0)
    end
end
function mod:PLAYER_REGEN_ENABLED()
    if ati_hostile and ati_hostile > 1 then
        SetCVar('nameplateShowEnemies',ati_hostile == 2 and 1 or 0)
    end
    if ati_friendly and ati_friendly > 1 then
        SetCVar('nameplateShowFriends',ati_friendly == 2 and 1 or 0)
    end
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterEvent('PLAYER_REGEN_DISABLED')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
end
