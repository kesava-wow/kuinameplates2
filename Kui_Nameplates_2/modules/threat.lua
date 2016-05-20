--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Override default health bar colour with custom settings when tanking
--------------------------------------------------------------------------------
local addon = KuiNameplates
local threat = addon:NewPlugin('Threat')

-- again, placeholder values
local colours = {
    { 0, 1, 0 }, -- colour for holding threat
    { 1, 1, 0 }  -- color when losing threat
}

local abs = abs
local function eq(t,v)
    if abs(t-v) < .1 then
        return true
    end
end

function threat:GlowColourChange(f)
    local r,g,b = unpack(f.state.glowColour)
    local holding = eq(r,1) and eq(g+b,0)
    local losing = f.state.glowing and not holding

    f.state.threat = (holding and 1 or losing and 2 or 0)

    --print(f.state)
    --print(f.state.name.. ' has: '..f.state.threat)

    if f.elements.HealthBar then
        if f.state.threat > 0 then
            f.HealthBar:SetStatusBarColor(unpack(colours[f.state.threat]))
            f.state.threatColoured = true
        elseif f.state.threatColoured then
            -- no threat status; set colour to default
            f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
            f.state.threatColoured = nil

            addon:DispatchMessage('HealthColourChange', f)
        end
    end
end

function threat:Initialise()
    self:RegisterMessage('GlowColourChange')
end
