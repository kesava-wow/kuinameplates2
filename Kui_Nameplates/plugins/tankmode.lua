-- change colour of health bar when tanking
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('TankMode')

local colours = {
    { 0, 1, 0 },
    { 1, 1, 0 }
}
-- messages ####################################################################
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end
    self:GlowColourChange(f)
end
function mod:GlowColourChange(f)
    -- TODO tank detection etc
    -- tank mode health bar colours
    if f.state.threat and f.state.threat > 0 then
        if f.elements.HealthBar then
            f.HealthBar:SetStatusBarColor(unpack(colours[f.state.threat]))
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
function mod:Initialise()
    -- TODO get colours from layout
    mod:RegisterMessage('HealthColourChange')
    mod:RegisterMessage('GlowColourChange')
end
