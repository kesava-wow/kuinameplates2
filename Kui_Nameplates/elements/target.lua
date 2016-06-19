-- listen for target changes and fire target messages
local addon = KuiNameplates
local ele = addon:NewElement('Target')

local target
-- local functions #############################################################
local function GainedTarget(f)
    target = f
    addon:DispatchMessage('GainedTarget',f)
end
local function LostTarget(f)
    target = nil
    addon:DispatchMessage('LostTarget',f)
end
local function ClearTarget()
    if not target then return end
    LostTarget(target)
end
-- prototype additions #########################################################
function addon.Nameplate.IsTarget(f)
    return f.parent.unit and UnitIsUnit('target',f.parent.unit)
end
-- events ######################################################################
function ele:TargetEvent()
    ClearTarget()

    if UnitExists('target') then
        local new_target = C_NamePlate.GetNamePlateForUnit('target')
        if new_target then
            -- target has a visible frame
            target = new_target.kui
            GainedTarget(new_target.kui)
        end
    end
end
-- messages ####################################################################
function ele:Show(f)
    if f.handler:IsTarget() then
        -- target's frame was shown
        target = f
        GainedTarget(f)
    end
end
function ele:Hide(f)
    if f == target then
        -- target's frame was hidden
        target = nil
        LostTarget(f)
    end
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterEvent('PLAYER_TARGET_CHANGED','TargetEvent')
    self:RegisterEvent('PLAYER_ENTERING_WORLD','TargetEvent')
end
