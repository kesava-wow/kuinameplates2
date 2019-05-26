-- listen for raid icon changes and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('RaidIcon')
-- prototype additions #########################################################
function addon.Nameplate.UpdateRaidIcon(f,show)
    f = f.parent

    if f.elements.RaidIcon and f.unit then
        if f.state.personal then
            -- don't show on the personal frame
            f.RaidIcon:Hide()
        else
            local i = GetRaidTargetIndex(f.unit)

            if i then
                SetRaidTargetIconTexture(f.RaidIcon,i)
                f.RaidIcon:Show()
            else
                f.RaidIcon:Hide()
            end
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
    for _,f in addon:Frames() do
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
