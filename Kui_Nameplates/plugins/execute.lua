-- recolour health bars in execute range
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Execute',4)

local class,execute_range

local specs = {
    ['DRUID'] = {
        [2] = 25 -- ferocious bite
    }
}

local talents = {
    ['PRIEST'] = {
        [22317] = 35
    },
    ['DRUID'] = {
        [21714] = -1, -- sabertooth
        [22155] = 25, -- feral affinity -> ferocious bite (balance)
        [22156] = 25, -- (guardian)
        [22367] = 25, -- (resto)
    },
}
local pvp_talents = {
    ['WARRIOR'] = {
        [23] = 25,
        [1942] = 25
    }
}

-- local functions #############################################################
local function IsTalentKnown(id,pvp)
    return pvp and select(10,GetPvpTalentInfoByID(id)) or select(10,GetTalentInfoByID(id))
end
local function GetExecuteRange()
    -- return execute range depending on class/spec/talents
    local r

    if specs[class] then
        local spec = GetSpecialization()
        if spec and spec > 0 and specs[class][spec] then
            r = specs[class][spec]
        end
    end

    if talents[class] then
        for id,v in pairs(talents[class]) do
            if IsTalentKnown(id) then
                r = v
            end
        end
    end

    if pvp_talents[class] then
        for id,v in pairs(pvp_talents[class]) do
            if IsTalentKnown(id,true) then
                r = v
            end
        end
    end

    return (not r or r < 0) and 20 or r
end
local function CanOverwriteHealthColor(f)
    return not f.state.health_colour_priority or
           f.state.health_colour_priority <= mod.priority
end
-- mod functions ###############################################################
function mod:SetExecuteRange(to)
    if type(to) == 'number' then
        self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        execute_range = to
    else
        self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        self:PLAYER_SPECIALIZATION_CHANGED()
    end
end
-- messages ####################################################################
function mod:HealthColourChange(f,caller)
    if caller and caller == self then return end

    if not UnitIsTapDenied(f.unit) and
       f.state.health_cur > 0 and
       f.state.health_per <= execute_range
    then
        if CanOverwriteHealthColor(f) then
            f.state.execute_range_coloured = true
            f.state.health_colour_priority = self.priority

            if f.elements.HealthBar then
                f.HealthBar:SetStatusBarColor(unpack(self.colour))
            end
        end

        if not f.state.in_execute_range then
            f.state.in_execute_range = true
            addon:DispatchMessage('ExecuteUpdate',f,true)
        end

    elseif f.state.in_execute_range then
        f.state.execute_range_coloured = nil
        f.state.in_execute_range = nil

        if CanOverwriteHealthColor(f) then
            f.state.health_colour_priority = nil

            if f.elements.HealthBar then
                f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
            end

            addon:DispatchMessage('HealthColourChange', f, mod)
        end

        addon:DispatchMessage('ExecuteUpdate',f,false)
    end
end
-- events ######################################################################
function mod:UNIT_HEALTH(event,f)
    self:HealthColourChange(f)
end
function mod:PLAYER_SPECIALIZATION_CHANGED()
    execute_range = GetExecuteRange()
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT','UNIT_HEALTH')
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('Show','HealthColourChange')

    self:PLAYER_SPECIALIZATION_CHANGED()
end
function mod:Initialise()
    class = select(2,UnitClass('player'))
    self.colour = {1,1,1}
end
