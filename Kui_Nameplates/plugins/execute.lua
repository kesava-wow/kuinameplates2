-- recolour health bars in execute range
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Execute',4,nil,false)

local EquipScanQueue,class,execute_range

local specs = {
    ['DRUID'] = {
        [2] = 25 -- ferocious bite
    }
}
local talents = {
    ['DRUID'] = {
        [21714] = -1, -- sabertooth (overrides ferocious bite)
        [22155] = 25, -- feral affinity -> ferocious bite (balance)
        [22156] = 25, -- (guardian)
        [22367] = 25, -- (resto)
    },
    ['HUNTER'] = {
        [22291] = 35 -- Beast Mastery Killer Instinct
    },
    ['MAGE'] = {
        [22462] = 30, -- Fire Searing Touch
    },
    ['PRIEST'] = {
        [23125] = 35 -- Shadow Twist of Fate
    },
    ['ROGUE'] = {
        [22339] = 30 -- Assassination Blindside
    },
    ['WARRIOR'] = {
        [22380] = 35, -- Arms Massacre
        [22393] = 35, -- Fury Massacre
    },
}
local pvp_talents = {
    ['WARRIOR'] = {
        [23] = 25,
        [1942] = 25
    }
}
local items = {}

-- local functions #############################################################
local function IsTalentKnown(id,pvp)
    return pvp and select(10,GetPvpTalentInfoByID(id)) or select(10,GetTalentInfoByID(id))
end
local function GetExecuteRange()
    -- return execute range depending on class/spec/talents
    local r

    if type(GetSpecialization) == 'function' then
        if specs[class] then
            local spec = GetSpecialization()
            if spec and spec > 0 and specs[class][spec] then
                r = specs[class][spec]
            end
        end
    end

    if talents[class] then
        for id,v in pairs(talents[class]) do
            if IsTalentKnown(id) then
                r = v
            end
        end
    end

    if UnitIsPVP('player') and pvp_talents[class] then
        for id,v in pairs(pvp_talents[class]) do
            if IsTalentKnown(id,true) then
                r = v
            end
        end
    end

    if #items > 0 then
        -- check equipped items
        for slot_id=1,18 do
            local item_id = GetInventoryItemID('player',slot_id)
            if item_id and items[item_id] then
                r = items[item_id]
            end
        end
    end

    return (not r or r < 0) and 20 or r
end
local function CanOverwriteHealthColor(f)
    return not f.state.health_colour_priority or
           f.state.health_colour_priority <= mod.priority
end
local function EquipScanQueue_Update()
    EquipScanQueue:Hide()
    execute_range = GetExecuteRange()
end
-- mod functions ###############################################################
function mod:SetExecuteRange(to)
    if not mod.enabled then return end
    if type(to) == 'number' then
        self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        self:UnregisterEvent('PLAYER_FLAGS_CHANGED')
        self:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
        execute_range = to
    elseif not kui.CLASSIC then
        -- force immediate auto-detect
        self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        self:RegisterEvent('PLAYER_FLAGS_CHANGED','PLAYER_SPECIALIZATION_CHANGED')
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        self:PLAYER_SPECIALIZATION_CHANGED()
    else
        -- default (only for classic)
        execute_range = 20
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
function mod:UNIT_HEALTH(_,f)
    self:HealthColourChange(f)
end
function mod:PLAYER_SPECIALIZATION_CHANGED()
    execute_range = GetExecuteRange()
end
function mod:PLAYER_EQUIPMENT_CHANGED()
    EquipScanQueue:Show()
end
-- register ####################################################################
function mod:OnEnable()
    if not EquipScanQueue then
        EquipScanQueue = CreateFrame('Frame')
        EquipScanQueue:Hide()
        EquipScanQueue:SetScript('OnUpdate',EquipScanQueue_Update)
    end

    self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT','UNIT_HEALTH')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('Show','HealthColourChange')

    self:SetExecuteRange()
end
function mod:Initialise()
    class = select(2,UnitClass('player'))
    self.colour = {1,1,1}
end
