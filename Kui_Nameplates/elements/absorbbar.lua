local addon = KuiNameplates
local ele = addon:NewElement('AbsorbBar')
-- prototype additions #########################################################
function addon.Nameplate.UpdateAbsorb(f)
    f = f.parent
    f.state.absorbs = UnitGetTotalAbsorbs(f.unit) or 0

    if f.elements.AbsorbBar and f.state.health_max then
        if f.AbsorbBar.spark then
            if f.state.absorbs > f.state.health_max then
                f.AbsorbBar.spark:Show()
            else
                f.AbsorbBar.spark:Hide()
            end
        end

        f.AbsorbBar:SetMinMaxValues(0,f.state.health_max)
        f.AbsorbBar:SetValue(f.state.absorbs)

        -- re-set the texture to fix tiling
        f.AbsorbBar:SetStatusBarTexture(f.AbsorbBar:GetStatusBarTexture())
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateAbsorb()
end
-- events ######################################################################
function ele:AbsorbEvent(event,f)
    f.handler:UpdateAbsorb()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')

    self:RegisterUnitEvent('UNIT_MAXHEALTH','AbsorbEvent')
    self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED','AbsorbEvent')
end
