local addon = KuiNameplates
local ele = addon:NewElement('Target')

local prev_target
-- local functions #############################################################
local function GainedTarget(f)
    addon:DispatchMessage('GainedTarget',f)
end
local function LostTarget(f)
    addon:DispatchMessage('LostTarget',f)
end
-- prototype additions #########################################################
function addon.Nameplate.IsTarget(f)
    return UnitIsUnit('target',f.parent.unit)
end
-- events ######################################################################
function ele:PLAYER_TARGET_CHANGED(event)
    if prev_target then
        -- clear existing target
        LostTarget(prev_target)
    end

    prev_target = nil

    if UnitExists('target') then
        local new_target = C_NamePlate.GetNamePlateForUnit('target')

        if new_target and new_target.kui then
            prev_target = new_target.kui
            GainedTarget(prev_target)
        end
    end
end
-- messages ####################################################################
function ele:Show(f)
    if f.handler:IsTarget() then
        GainedTarget(f)
    end
end
-- register ####################################################################
ele:RegisterEvent('PLAYER_TARGET_CHANGED')
ele:RegisterMessage('Show')
