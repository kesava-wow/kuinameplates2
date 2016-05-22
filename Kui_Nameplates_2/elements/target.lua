local addon = KuiNameplates
local ele = addon:NewElement('Target')

local cur_target,prev_target
-- prototype additions #########################################################
function addon.Nameplate.IsTarget(f)
    f = f.parent
    return cur_target and f == cur_target
end
-- events ######################################################################
function ele:PLAYER_TARGET_CHANGED(event)
    cur_target = nil

    if prev_target then
        addon:DispatchMessage('LostTarget',prev_target)
    end

    prev_target = nil

    if UnitExists('target') then
        cur_target = C_NamePlate.GetNamePlateForUnit('target')

        if cur_target and cur_target.kui then
            cur_target = cur_target.kui
            addon:DispatchMessage('GainedTarget',cur_target)

            prev_target = cur_target
        else
            cur_target = nil
        end
    end
end
-- register ####################################################################
ele:RegisterEvent('PLAYER_TARGET_CHANGED')
