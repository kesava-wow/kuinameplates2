local addon = KuiNameplates
local ele = addon:NewElement('Target')

local prev_target
-- local functions #############################################################
local function GainedTarget(f)
    addon:DispatchMessage('GainedTarget',f)
    prev_target = f
end
local function LostTarget(f)
    addon:DispatchMessage('LostTarget',f)
end
local function ClearTarget()
    if not prev_target then return end
    LostTarget(prev_target)
    prev_target = nil
end
-- prototype additions #########################################################
function addon.Nameplate.IsTarget(f)
    return UnitIsUnit('target',f.parent.unit)
end
-- events ######################################################################
function ele:PLAYER_TARGET_CHANGED(event)
    ClearTarget()

    if UnitExists('target') then
        local new_target = C_NamePlate.GetNamePlateForUnit('target')
        if new_target and new_target.kui then
            GainedTarget(new_target.kui)
        end
    end
end
-- messages ####################################################################
function ele:Show(f)
    if f.handler:IsTarget() then
        ClearTarget()
        GainedTarget(f)
    end
end
function ele:Hide(f)
    if f == prev_target then
        prev_target = nil
    end
end
-- register ####################################################################
ele:RegisterEvent('PLAYER_TARGET_CHANGED')
ele:RegisterMessage('Show')
ele:RegisterMessage('Hide')
