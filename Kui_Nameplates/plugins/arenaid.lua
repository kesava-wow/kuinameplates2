-- provides f.state.arenaid when in an arena
local addon = KuiNameplates
local mod = addon:NewPlugin('ArenaID')

local in_arena
local IsInInstance,UnitIsUnit,GetNumArenaOpponents =
      IsInInstance,UnitIsUnit,GetNumArenaOpponents

-- local functions #############################################################
local function GetArenaID(unit)
    for i=1,GetNumArenaOpponents() do
        if  UnitIsUnit(unit,'arena'..i) or
            UnitIsUnit(unit,'arenapet'..i)
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
    local in_instance,instance_type = IsInInstance()
    in_arena = in_instance and instance_type == 'arena'
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
