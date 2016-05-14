-- listen for health events and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('healthbar')
-- local functions #############################################################
local function UpdateHealthColour(f)
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
local function UpdateHealth(f)
    if f.elements.Healthbar then
        f.Healthbar:SetMinMaxValues(0,UnitHealthMax(f.unit))
        f.Healthbar:SetValue(UnitHealth(f.unit))
    end

    addon:DispatchMessage('HealthUpdate', f)
end
-- messages ####################################################################
function ele.Update(f)
    UpdateHealthColour(f)
end
function ele.PreShow(f)
    UpdateHealth(f)
end
-- events ######################################################################
function ele:UNIT_HEALTH(event,f,unit)
    UpdateHealth(f)
end
-- register ####################################################################
ele:RegisterMessage('Update')
ele:RegisterMessage('PreShow')

ele:RegisterEvent('UNIT_HEALTH')
