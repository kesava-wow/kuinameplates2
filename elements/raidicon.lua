-- listen for raid icon changes and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('RaidIcon')
-- prototype additions #########################################################
function addon.Nameplate.UpdateRaidIcon(f,show)
    f = f.parent

    if f.elements.RaidIcon and f.unit then
        local i = GetRaidTargetIndex(f.unit)

        if i then
            SetRaidTargetIconTexture(f.RaidIcon,i)
            f.RaidIcon:Show()
        else
            f.RaidIcon:Hide()
        end
    end

    if not show then
        addon:DispatchMessage('RaidIconUpdate', f)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateRaidIcon(true)
end
-- events ######################################################################
function ele:RAID_TARGET_UPDATE()
    -- update all frames
    for k,f in addon:Frames() do
        if f:IsShown() then
            f.handler:UpdateRaidIcon()
        end
    end
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterEvent('RAID_TARGET_UPDATE')
end
