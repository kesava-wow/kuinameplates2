local addon = KuiNameplates
local ele = addon:NewElement('AbsorbBar')
-- prototype additions #########################################################
function addon.Nameplate.UpdateAbsorb(f)
    f = f.parent
    f.state.absorbs = UnitGetTotalAbsorbs(f.unit) or 0

    if f.elements.AbsorbBar then
        if f.state.health_max and f.state.absorbs > 0 then
            f.AbsorbBar:SetMinMaxValues(0,f.state.health_max)
            f.AbsorbBar:SetValue(f.state.absorbs)
            f.AbsorbBar:Show()

            if f.AbsorbBar.spark then
                -- show spark for over-absorbs
                if f.state.absorbs > f.state.health_max then
                    f.AbsorbBar.spark:Show()
                else
                    f.AbsorbBar.spark:Hide()
                end
            end
        else
            f.AbsorbBar:SetValue(0)
            f.AbsorbBar:Hide()
            if f.AbsorbBar.spark then
                f.AbsorbBar.spark:Hide()
            end
        end
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
-- enable/disable per frame ####################################################
function ele:EnableOnFrame(f)
    if f:IsShown() then
        self:Show(f)
    end
end
function ele:DisableOnFrame(f)
    f.AbsorbBar:Hide()
    if f.AbsorbBar.spark then
        f.AbsorbBar.spark:Hide()
    end
end
-- register ####################################################################
function ele:OnDisable()
    for i,f in addon:Frames() do
        self:DisableOnFrame(f)
    end
end
function ele:OnEnable()
    self:RegisterMessage('Show')

    self:RegisterUnitEvent('UNIT_MAXHEALTH','AbsorbEvent')
    self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED','AbsorbEvent')
end
