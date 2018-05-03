-- provides f.state.arenaid when in an arena
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('ArenaID')

local in_arena
local UnitIsUnit,IsActiveBattlefieldArena,GetNumArenaOpponents =
      UnitIsUnit,IsActiveBattlefieldArena,GetNumArenaOpponents

-- local functions #############################################################
local function GetArenaID(unit)
    for i=1,GetNumArenaOpponents() do
        if  UnitIsUnit(f.unit,'arena'..i) or
            UnitIsUnit(f.unit,'arenapet'..i)
        then
            return i
        end
    end
end
-- messages ####################################################################
function mod:Show(f)
    if in_arena then
        f.state.arenaid = GetArenaID(f.unit)
    end
end
-- events ######################################################################
function mod:PLAYER_ENTERING_WORLD()
    in_arena = IsActiveBattlefieldArena()
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
