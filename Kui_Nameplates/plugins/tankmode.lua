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
    self:SpecUpdate()
end
-- messages ####################################################################
function mod:Show(f)
    self:UNIT_THREAT_LIST_UPDATE(nil,f,f.unit)
end
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end
    self:GlowColourChange(f)
end
function mod:GlowColourChange(f)
    -- tank mode health bar colours
    if self.enabled and spec_enabled and
        ((f.state.threat and f.state.threat > 0) or
        f.state.tank_mode_offtank)
    then
        if f.elements.HealthBar then
            if f.state.threat and f.state.threat > 0 then
                f.HealthBar:SetStatusBarColor(unpack(self.colours[f.state.threat]))
            elseif f.state.tank_mode_offtank then
                f.HealthBar:SetStatusBarColor(unpack(self.colours[3]))
            end
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
function mod:UNIT_THREAT_LIST_UPDATE(event,f,unit)
    if unit == 'player' or UnitIsUnit('player',unit) then return end

    f.state.tank_mode_offtank = nil

    local status = UnitThreatSituation('player',unit)
    if not status or status < 3 then
        -- player isn't tanking; get current target
        local tank_unit = unit..'target'

        if UnitExists(tank_unit) and not UnitIsUnit(tank_unit,'player') then
            if UnitInParty(tank_unit) or UnitInRaid(tank_unit) then
                print(UnitName(tank_unit)..' is tanking '..f.state.name)

                if  UnitName(tank_unit) == 'Oto the Protector' or
                    UnitGroupRolesAssigned(tank_unit) == 'TANK'
                then
                    -- unit is attacking another tank
                    f.state.tank_mode_offtank = true
                end
            end
        end
    end

    -- force update bar colour
    self:GlowColourChange(f)
end
function mod:SpecUpdate()
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
    self:RegisterMessage('Show')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','SpecUpdate')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
    self:SpecUpdate()
end
function mod:OnDisable()
    UpdateFrames()
end
function mod:Initialise()
    self.colours = {
        { 0, 1, 0 }, -- player is tanking
        { 1, 1, 0 }, -- player is gaining/losing threat
        { 1, 0, 1 }  -- other tank is tanking
    }
end
