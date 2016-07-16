-- fetch threat state and colour the frame glow element
local addon = KuiNameplates
local ele = addon:NewElement('Threat',1)

-- TODO config
local threat_colours = {
    { 1, 0, 0 },
    { 1, .6, 0 }
}
-- messages ####################################################################
function ele:Show(f)
    self:UNIT_THREAT_LIST_UPDATE(nil,f,f.unit)
end
-- events ######################################################################
function ele:UNIT_THREAT_LIST_UPDATE(event,f,unit)
    if unit == 'player' or UnitIsUnit('player',unit) then return end

    local status = UnitThreatSituation('player',unit)
    local threat_state,threat_colour

    if status then
        threat_state = status == 3 and 1 or (status < 3 and status > 0) and 2 or 0
    end

    threat_colour = threat_state and (threat_state > 0 and threat_colours[threat_state] or nil)

    f.state.threat = threat_state
    f.state.glow_colour = threat_colour

    if threat_state and threat_state > 0 then
        f.state.glowing = true

        if f.elements.ThreatGlow then
            f.ThreatGlow:Show()
            f.ThreatGlow:SetVertexColor(unpack(threat_colour))
        end

        addon:DispatchMessage('GlowColourChange', f)
    elseif f.state.glowing then
        f.state.glowing = nil

        if f.elements.ThreatGlow then
            f.ThreatGlow:Hide()
        end

        addon:DispatchMessage('GlowColourChange', f)
    end
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
end
function ele:Initialise()
    -- force enable threat on nameplates
    SetCVar('threatWarning',3)
end
