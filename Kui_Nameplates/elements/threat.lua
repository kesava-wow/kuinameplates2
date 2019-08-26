-- fetch threat state and colour the frame glow element
-- provides frame.state[...]: threat, glow_colour
--   threat = player's state in the unit's threat table:
--     nil = not in threat table;
--     0 = not tanking;
--     1 = tanking;
--     2 = transition.
--   glow_colour = threat colour from threat state.
--
-- provides message: GlowColourChange
--   GlowColourChange = threat state changed
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('Threat',1)
ele.colours = {
    { 1,0,0 }, -- tanking
    { 1,.6,0 } -- transition
}
-- messages ####################################################################
function ele:Show(f)
    if not UnitIsPlayer(f.unit) and not UnitPlayerControlled(f.unit) then
        self:UNIT_THREAT_LIST_UPDATE(nil,f,f.unit)
    end
end
-- events ######################################################################
function ele:UNIT_THREAT_LIST_UPDATE(_,f,unit)
    if unit == 'player' or UnitIsUnit('player',unit) then return end

    local status = UnitThreatSituation('player',unit)
    local threat_state = status and (
        (status == 3 and 1) or -- target
        (status < 3 and status > 0 and 2) or -- transition
        0 -- in threat table
    )

    if f.state.threat ~= threat_state then
        f.state.threat = threat_state

        local threat_colour = threat_state and (
            threat_state > 0 and self.colours[threat_state]
        )
        f.state.glow_colour = threat_colour

        if threat_state and threat_state > 0 then
            f.state.glowing = true

            if f.elements.ThreatGlow then
                f.ThreatGlow:Show()
                f.ThreatGlow:SetAlpha(1)
                f.ThreatGlow:SetVertexColor(unpack(threat_colour))
            end
        else
            f.state.glowing = nil

            if f.elements.ThreatGlow then
                f.ThreatGlow:Hide()
            end
        end

        addon:DispatchMessage('GlowColourChange', f)
    end
end
-- register ####################################################################
function ele:OnEnable()
    if kui.CLASSIC then return false end -- XXX nil out for classic

    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
end
