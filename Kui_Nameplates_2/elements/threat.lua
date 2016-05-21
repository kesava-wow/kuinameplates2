local addon = KuiNameplates
local ele = addon:NewElement('Threat',1)

local threat_colours = {
    { 1, 0, 0 },
    { 1, .6, 0 }
}
local tank_colours = {
    { 0, 1, 0 },
    { 1, 1, 0 }
}

function ele:Show(f)
    self:UNIT_THREAT_LIST_UPDATE(nil,f,f.unit)
end

function ele:UNIT_THREAT_LIST_UPDATE(event,f,unit)
    if unit == 'player' or UnitIsUnit('player',unit) then return end

    local status = UnitThreatSituation('player',unit)
    local threat_state = (not status and 0) or (status == 3 and 1 or (status < 3 and status > 0) and 2 or 0)
    local threat_colour = threat_state > 0 and threat_colours[threat_state] or nil

    f.state.threat = threat_state
    f.state.glowColour = threat_colour

    if f.elements.HealthBar then
        -- TODO tank mode should be a separate plugin
        -- tank mode health bar colours
        if threat_state > 0 then
            f.HealthBar:SetStatusBarColor(unpack(tank_colours[threat_state]))
            f.state.threatColoured = true
        elseif f.state.threatColoured then
            f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
            f.state.threatColoured = nil

            addon:DispatchMessage('HealthColourChange', f)
        end
    end

    if f.elements.ThreatGlow then
        if threat_state > 0 then
            f.state.glowing = true
            f.ThreatGlow:SetVertexColor(unpack(threat_colour))

            addon:DispatchMessage('GlowColourChange', f)
        elseif f.state.glowing then
            f.state.glowing = nil

            addon:DispatchMessage('GlowColourChange', f)
        end
    end
end

function ele:Initialise()
    ele:RegisterMessage('Show')
    ele:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
end
