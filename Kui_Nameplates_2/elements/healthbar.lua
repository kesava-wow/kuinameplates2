-- listen for health events and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('HealthBar')
-- prototype additions #########################################################
function addon.Nameplate.UpdateHealthColour(f,show)
    f = f.parent
    local r,g,b = kui.GetUnitColour(f.unit,2)
    if not f.state.healthColour or
       f.state.healthColour[1] ~= r or
       f.state.healthColour[2] ~= g or
       f.state.healthColour[3] ~= b
    then
        f.state.healthColour = { r,g,b }

        if f.elements.HealthBar then
            f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
        end

        if not show then
            addon:DispatchMessage('HealthColourChange', f)
        end
    end
end
function addon.Nameplate.UpdateHealth(f,show)
    f = f.parent
    if f.elements.HealthBar then
        f.HealthBar:SetMinMaxValues(0,UnitHealthMax(f.unit))
        f.HealthBar:SetValue(UnitHealth(f.unit))
    end

    if not show then
        addon:DispatchMessage('HealthUpdate', f)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateHealth(f,true)
    f.handler:UpdateHealthColour(f,true)
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    f.handler:UpdateHealthColour(f)
end
function ele:UNIT_HEALTH(event,f)
    f.handler:UpdateHealth(f)
end
-- register ####################################################################
ele:RegisterMessage('Show')

ele:RegisterUnitEvent('UNIT_HEALTH_FREQUENT','UNIT_HEALTH')
ele:RegisterUnitEvent('UNIT_FACTION')
