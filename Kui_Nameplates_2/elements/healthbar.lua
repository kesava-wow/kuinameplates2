-- listen for health events and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('healthbar')
-- prototype additions #########################################################
function addon.Nameplate.UpdateHealthColour(f)
    f = f.parent
    local r,g,b = kui.GetUnitColour(f.unit,2)
    if not f.state.healthColour or
       f.state.healthColour[1] ~= r or
       f.state.healthColour[2] ~= g or
       f.state.healthColour[3] ~= b
    then
        f.state.healthColour = { r,g,b }

        if f.elements.Healthbar then
            f.Healthbar:SetStatusBarColor(unpack(f.state.healthColour))
        end

        addon:DispatchMessage('HealthColourChange', f)
    end
end
function addon.Nameplate.UpdateHealth(f)
    f = f.parent
    if f.elements.Healthbar then
        f.Healthbar:SetMinMaxValues(0,UnitHealthMax(f.unit))
        f.Healthbar:SetValue(UnitHealth(f.unit))
    end

    addon:DispatchMessage('HealthUpdate', f)
end
-- messages ####################################################################
function ele.PreShow(f)
    f.handler:UpdateHealth(f)
    f.handler:UpdateHealthColour(f)
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    f.handler:UpdateHealthColour(f)
end
function ele:UNIT_HEALTH(event,f)
    f.handler:UpdateHealth(f)
end
-- register ####################################################################
ele:RegisterMessage('PreShow')

ele:RegisterEvent('UNIT_HEALTH')
ele:RegisterEvent('UNIT_FACTION')
