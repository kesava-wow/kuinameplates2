-- change colour of health bar when tanking
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('TankMode')

local GetNumGroupMembers,UnitIsUnit,UnitIsFriend,UnitExists,UnitInParty,
      UnitInRaid,UnitGroupRolesAssigned =
      GetNumGroupMembers,UnitIsUnit,UnitIsFriend,UnitExists,UnitInParty,
      UnitInRaid,UnitGroupRolesAssigned

local force_enable,spec_enabled,offtank_enable
-- local functions #############################################################
local function UpdateFrames()
    -- update threat colour on currently visible frames
    for i,f in addon:Frames() do
        if f:IsShown() then
            if offtank_enable then
                mod:Show(f)
            else
                f.state.tank_mode_offtank = nil
                mod:GlowColourChange(f)
            end
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
    if  unit == 'player' or
        UnitIsUnit('player',unit) or
        UnitIsFriend('player',unit)
    then
        return
    end

    f.state.tank_mode_offtank = nil

    local status = UnitThreatSituation('player',unit)
    if not status or status < 3 then
        -- player isn't tanking; get current target
        local tank_unit = unit..'target'

        if UnitExists(tank_unit) and not UnitIsUnit(tank_unit,'player') then
            if UnitInParty(tank_unit) or UnitInRaid(tank_unit) then
                if UnitGroupRolesAssigned(tank_unit) == 'TANK' then
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
    local was_enabled = spec_enabled

    if force_enable then
        spec_enabled = true
    else
        local spec = GetSpecialization()
        local role = spec and GetSpecializationRole(spec) or nil

        if role == 'TANK' then
            spec_enabled = true
        else
            spec_enabled = nil
        end
    end

    if spec_enabled ~= was_enabled then
        self:GroupUpdate(nil,true)
        UpdateFrames()
    end
end
function mod:GroupUpdate(event,no_update)
    if GetNumGroupMembers() > 0 and spec_enabled then
        if not offtank_enable then
            offtank_enable = true

            self:RegisterMessage('Show')
            self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')

            if not no_update then
                UpdateFrames()
            end
        end
    elseif offtank_enable then
        offtank_enable = nil

        self:UnregisterMessage('Show')
        self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE')

        if not no_update then
            UpdateFrames()
        end
    end
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')

    self:RegisterEvent('GROUP_ROSTER_UPDATE','GroupUpdate')
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','SpecUpdate')

    self:SpecUpdate()
end
function mod:OnDisable()
    UpdateFrames()
end
function mod:Initialise()
    self.colours = {
        { 0, 1, 0 }, -- player is tanking
        { 1, 1, 0 }, -- player is gaining/losing threat
        { .6, 0, 1 }  -- other tank is tanking
    }
end
