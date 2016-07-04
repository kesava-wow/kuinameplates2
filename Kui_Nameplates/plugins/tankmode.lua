-- change colour of health bar when tanking
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('TankMode')

local force_enable,spec_enabled
-- local functions #############################################################
local function UpdateFrames()
    -- update threat colour on currently visible frames
    for i,f in addon:Frames() do
        if f:IsShown() then
            mod:GlowColourChange(f)
        end
    end
end
-- mod functions ###############################################################
function mod:SetForceEnable(b)
    force_enable = b == true
    self:Update()
end
-- messages ####################################################################
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end
    self:GlowColourChange(f)
end
function mod:GlowColourChange(f)
    -- tank mode health bar colours
    if self.enabled and spec_enabled and f.state.threat and f.state.threat > 0 then
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
-- events ######################################################################
function mod:Update()
    if not force_enable then
        local spec = GetSpecialization()
        local role = spec and GetSpecializationRole(spec) or nil

        if role == 'TANK' then
            spec_enabled = true
        else
            spec_enabled = nil
        end
    else
        spec_enabled = true
    end

    UpdateFrames()
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','Update')
    self:Update()
end
function mod:OnDisable()
    UpdateFrames()
end
function mod:Initialise()
    self.colours = {
        { 0, 1, 0 },
        { 1, 1, 0 }
    }
end
