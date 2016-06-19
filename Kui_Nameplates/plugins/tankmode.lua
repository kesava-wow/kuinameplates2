-- change colour of health bar when tanking
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('TankMode')
-- messages ####################################################################
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end
    self:GlowColourChange(f)
end
function mod:GlowColourChange(f)
    -- TODO tank detection etc
    -- tank mode health bar colours
    if self.enabled and f.state.threat and f.state.threat > 0 then
        if f.elements.HealthBar then
            f.HealthBar:SetStatusBarColor(unpack(self.colours[f.state.threat]))
        end

        f.state.tank_mode_coloured = true
    elseif f.state.tank_mode_coloured then
        if f.elements.HealthBar then
            -- return to colour provided by HealthBar element
            f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
        end

        addon:DispatchMessage('HealthColourChange', f, mod)
    end
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')

    self:OnDisable()
end
function mod:OnDisable()
    -- toggle on current frames
    for i,f in addon:Frames() do
        if f:IsShown() then
            self:GlowColourChange(f)
        end
    end
end
function mod:Initialise()
    self.colours = {
        { 0, 1, 0 },
        { 1, 1, 0 }
    }
end
