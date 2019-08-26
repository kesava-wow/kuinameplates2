-- provides frame.state[...]: combat, attackable
--   combat = unit is in combat
--   attackable = unit can be attacked by player
--
-- messages: Combat, FactionUpdate
--   Combat = combat state changed
--   FactionUpdate = UNIT_FACTION event, or attackable state changed
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('CombatUpdate',0)

local INTERVAL = 1
local elapsed = 0

-- local functions #############################################################
local function Frame_UpdateCombat(f)
    f.state.combat = UnitAffectingCombat(f.unit)
end
local function Frame_UpdateAttackable(f)
    f.state.attackable = UnitCanAttack('player',f.unit)
end
local function Frame_Check(f,faction_event)
    if f.state.combat ~= UnitAffectingCombat(f.unit) then
        Frame_UpdateCombat(f)
        addon:DispatchMessage('Combat',f)
    end
    if faction_event or f.state.attackable ~= UnitCanAttack('player',f.unit) then
        Frame_UpdateAttackable(f)
        addon:DispatchMessage('FactionUpdate',f)
    end
end
local function UpdateFrame_OnUpdate(self,elap)
    elapsed = elapsed + elap
    if elapsed > INTERVAL then
        for _,f in addon:Frames() do
            if f.unit then
                Frame_Check(f)
            end
        end
        elapsed = 0
    end
end
-- messages ####################################################################
function mod:Show(f)
    Frame_UpdateCombat(f)
    Frame_UpdateAttackable(f)
end
-- events ######################################################################
function mod:Event(event,f)
    Frame_Check(f,(event == 'UNIT_FACTION'))
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_FACTION','Event')

    if not kui.CLASSIC then
        self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE','Event')
    end

    local f = CreateFrame('Frame')
    f:SetScript('OnUpdate',UpdateFrame_OnUpdate)
    self.UpdateFrame = f
end
