-- provide class power stators, and don't actually draw anything
-- move all drawing to layout callbacks
local folder,ns=...
local addon = KuiNameplates
local ele = addon:NewElement('ClassPowers2')
local kui = LibStub('Kui-1.0')
if not ele then return end

local FRAMELOCK,POWERS,POWERS_CLASS,POWER_TAGS
local frame,player_class,player_spec,player_power_type,power_tag

-- scripts #####################################################################
local function FrameLockNil(self)
    self:SetScript('OnUpdate',nil)
    FRAMELOCK=nil
end
-- functions ###################################################################
local function GetPowerType(spec)
    if type(POWERS_CLASS) == 'table' then
        return POWERS_CLASS[spec]
    else
        return POWERS_CLASS
    end
end
local function UpdateWrapper(...)
    if not FRAMELOCK then
        FRAMELOCK=true
        frame:SetScript('OnUpdate',FrameLockNil)
        ele:RunCallback(...)
    end
end
local function PowerUpdate()
    -- fire power update callback
    UpdateWrapper('PowerUpdate',ele:GetCurrent(),ele:GetMax(),ele:GetDisplayMod())
end
local function RuneUpdate()
    -- fire rune update callback
    UpdateWrapper('RuneUpdate')
end
-- "public" functions #########################################################
function ele:GetCurrent()
    return UnitPower('player',player_power_type,true)
end
function ele:GetMax()
    return UnitPowerMax('player',player_power_type)
end
function ele:GetDisplayMod()
    return UnitPowerDisplayMod(player_power_type) or 1
end
-- events ######################################################################
function ele:PowerInit()
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('RUNE_POWER_UPDATE')
    frame:UnregisterAllEvents()

    player_power_type = GetPowerType(GetSpecialization())
    if not player_power_type then return end

    if player_class == 'DEATHKNIGHT' then
        -- uses RUNE_POWER_UPDATE instead of UNIT_POWER_*
        self:RegisterEvent('RUNE_POWER_UPDATE','RuneEvent')
        -- XXX with display moving to layout, we only need to provide
        -- cooldown data, so RuneDaemon doesn't need to be ported here.
    else
        -- generic class powers
        power_tag = POWER_TAGS[player_power_type]

        -- we use a non-KNP unit event for these for efficiency
        frame:RegisterUnitEvent('UNIT_MAXPOWER','player')
        frame:RegisterUnitEvent('UNIT_POWER_FREQUENT','player')
    end

    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
function ele:PLAYER_ENTERING_WORLD()
    if player_class == 'DEATHKNIGHT' then
        RuneUpdate()
    else
        PowerUpdate()
    end
end
function ele:PowerEvent(event,_,tag)
    if tag == power_tag then
        PowerUpdate()
    end
end
function ele:RuneEvent()
    RuneUpdate()
end
-- frame event wrappers #######################################################
function ele:UNIT_MAXPOWER(...)
    self:PowerEvent(...)
end
function ele:UNIT_POWER_FREQUENT(...)
    self:PowerEvent(...)
end
-- messages ####################################################################
function ele:Initialised()
    -- non-KNP unit event handler
    frame = CreateFrame('Frame')
    frame:SetScript('OnEvent',function(_,event,...)
        ele[event](ele,event,...)
    end)

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    self:PowerInit()
end
-- init ########################################################################
function ele:Initialise()
    player_class = select(2,UnitClass('player'))

    -- register our callbacks
    self:RegisterCallback('PowerUpdate')
    self:RegisterCallback('RuneUpdate')

    -- initialise powers table
    if kui.CLASSIC then
        POWERS = {
            DRUID = Enum.PowerType.ComboPoints,
            ROGUE = Enum.PowerType.ComboPoints,
        }
    else
        POWERS = {
            DEATHKNIGHT = Enum.PowerType.Runes,
            DRUID = { [2] = Enum.PowerType.ComboPoints },
            PALADIN = { [3] = Enum.PowerType.HolyPower },
            ROGUE = Enum.PowerType.ComboPoints,
            MAGE = { [1] = Enum.PowerType.ArcaneCharges },
            MONK = { [1] = 'stagger', [3] = Enum.PowerType.Chi },
            WARLOCK = Enum.PowerType.SoulShards,
        }
    end

    -- tags returned by the UNIT_POWER and UNIT_MAXPOWER events
    POWER_TAGS = {
        [Enum.PowerType.Runes]         = 'RUNES',
        [Enum.PowerType.ComboPoints]   = 'COMBO_POINTS',
        [Enum.PowerType.HolyPower]     = 'HOLY_POWER',
        [Enum.PowerType.ArcaneCharges] = 'ARCANE_CHARGES',
        [Enum.PowerType.Chi]           = 'CHI',
        [Enum.PowerType.SoulShards]    = 'SOUL_SHARDS',
    }

    POWERS_CLASS = POWERS[player_class]
end
