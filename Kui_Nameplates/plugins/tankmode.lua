-- change colour of health bar when tanking
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('TankMode')
mod.colours = {
    { 0,1,0 },  -- player is tanking
    { 1,1,0 },  -- player is gaining/losing threat
    { .6,0,1 }  -- other tank is tanking
}
local force_enable,force_offtank,spec_enabled,offtank_enable
-- local functions #############################################################
local function UpdateFrames()
    -- update threat colour on currently visible frames
    for _,f in addon:Frames() do
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
local function CanOverwriteHealthColor(f)
    return not f.state.health_colour_priority or
           f.state.health_colour_priority <= mod.priority
end
local function ColourHealthBar(f)
    if CanOverwriteHealthColor(f) then
        f.state.tank_mode_coloured = true
        f.state.health_colour_priority = mod.priority

        if f.elements.HealthBar then
            if f.state.threat and f.state.threat > 0 then
                f.HealthBar:SetStatusBarColor(unpack(mod.colours[f.state.threat]))
            elseif f.state.tank_mode_offtank then
                f.HealthBar:SetStatusBarColor(unpack(mod.colours[3]))
            end
        end
    end
end
local function UncolourHealthBar(f)
    if not f.state.tank_mode_coloured then return end
    f.state.tank_mode_coloured = nil

    if CanOverwriteHealthColor(f) then
        -- return to colour provided by HealthBar element
        f.state.health_colour_priority = nil

        if f.elements.HealthBar then
            f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
        end

        addon:DispatchMessage('HealthColourChange', f, mod)
    end
end
-- mod functions ###############################################################
function mod:SetForceEnable(b)
    if not self.enabled then return end
    force_enable = b == true
    self:SpecUpdate()
end
function mod:SetForceOffTank(b)
    if not self.enabled then return end
    force_offtank = b == true
    self:GroupUpdate(nil,true)
    UpdateFrames()
end
-- messages ####################################################################
function mod:Show(f)
    if not UnitIsPlayer(f.unit) and not UnitPlayerControlled(f.unit) then
        self:UNIT_THREAT_LIST_UPDATE(nil,f,f.unit)
    end
end
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end
    self:GlowColourChange(f)
end
function mod:GlowColourChange(f)
    if  UnitIsPlayer(f.unit) or
        UnitPlayerControlled(f.unit) or
        UnitIsTapDenied(f.unit)
    then
        UncolourHealthBar(f)
        return
    end

    -- tank mode health bar colours
    if self.enabled and (force_enable or spec_enabled) and
        ( (f.state.threat and f.state.threat > 0) or
          f.state.tank_mode_offtank
        )
    then
        -- mod is enabled and frame has an active threat state
        ColourHealthBar(f)
    else
        -- mod is disabled or frame no longer has a coloured threat state
        UncolourHealthBar(f)
    end
end
-- events ######################################################################
function mod:UNIT_THREAT_LIST_UPDATE(_,f,unit)
    if not self.enabled then return end
    if  unit == 'player' or
        UnitIsUnit('player',unit) or
        UnitIsFriend('player',unit)
    then
        return
    end

    f.state.tank_mode_offtank = nil

    if not kui.CLASSIC then
        local status = UnitThreatSituation('player',unit)
        if not status or status < 3 then
            -- player isn't tanking; get current target
            local tank_unit = unit..'target'

            if UnitExists(tank_unit) and not UnitIsUnit(tank_unit,'player') then
                if ((UnitInParty(tank_unit) or UnitInRaid(tank_unit)) and
                    UnitGroupRolesAssigned(tank_unit) == 'TANK') or
                   (not UnitIsPlayer(tank_unit) and UnitPlayerControlled(tank_unit))
                then
                    -- unit is attacking another group tank,
                    -- or a player controlled npc (pet, vehicle, totem)
                    f.state.tank_mode_offtank = true
                end
            end
        end
    end

    -- force update bar colour
    self:GlowColourChange(f)
end
function mod:SpecUpdate()
    if not self.enabled then return end
    if kui.CLASSIC then return end -- XXX no role data on classic
    local was_enabled = spec_enabled
    local spec = GetSpecialization()
    local role = spec and GetSpecializationRole(spec) or nil

    spec_enabled = role == 'TANK'
    if spec_enabled ~= was_enabled then
        self:GroupUpdate(nil,true)
        UpdateFrames()
    end
end
function mod:GroupUpdate(_,no_update)
    -- enable/disable off-tank detection
    if not self.enabled then return end
    if kui.CLASSIC then return end -- XXX no role data on classic
    if GetNumGroupMembers() > 0 and (spec_enabled or force_offtank) then
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
    spec_enabled = false

    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')

    if not kui.CLASSIC then
        self:RegisterEvent('GROUP_ROSTER_UPDATE','GroupUpdate')
        self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','SpecUpdate')
        self:RegisterEvent('PLAYER_ENTERING_WORLD','SpecUpdate')

        self:SpecUpdate()
    end
end
function mod:OnDisable()
    UpdateFrames()
end
