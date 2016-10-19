--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
local folder,ns=...
local kui = LibStub('Kui-1.0')
local kc = LibStub('KuiConfig-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local addon = KuiNameplates
local core = KuiNameplatesCore
-- combat checking frame
local cc = CreateFrame('Frame')
-- add media to LSM ############################################################
LSM:Register(LSM.MediaType.FONT,'Yanone Kaffesatz Bold',kui.m.f.yanone)
LSM:Register(LSM.MediaType.FONT,'FrancoisOne',kui.m.f.francois)
LSM:Register(LSM.MediaType.FONT,'Roboto Condensed Bold',kui.m.f.roboto)

LSM:Register(LSM.MediaType.STATUSBAR, 'Kui status bar', kui.m.t.bar)
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui shaded bar', kui.m.t.oldbar)

local locale = GetLocale()
local latin  = (locale ~= 'zhCN' and locale ~= 'zhTW' and locale ~= 'koKR' and locale ~= 'ruRU')

local DEFAULT_FONT = latin and 'FrancoisOne' or LSM:GetDefault(LSM.MediaType.FONT)
local DEFAULT_BAR = 'Kui status bar'
-- default configuration #######################################################
local default_config = {
    bar_texture = DEFAULT_BAR,
    bar_animation = 3,
    combat_hostile = 1,
    combat_friendly = 1,
    ignore_uiscale = false,
    glow_as_shadow = true,
    state_icons = true,
    target_glow = true,
    target_glow_colour = { .3, .7, 1, 1 },
    target_arrows = false,
    frame_glow_size = 8,
    target_arrows_size = 33,

    nameonly = true,
    nameonly_no_font_style = false,
    nameonly_damaged_friends = true,
    nameonly_enemies = true,
    nameonly_all_enemies = false,
    nameonly_target = true,
    guild_text_npcs = true,
    guild_text_players = false,
    title_text_players = false,

    fade_all = false,
    fade_alpha = .5,
    fade_speed = .5,
    fade_friendly_npc = false,
    fade_neutral_enemy = false,
    fade_untracked = false,
    fade_avoid_nameonly = true,
    fade_avoid_raidicon = true,
    fade_avoid_execute_friend = false,
    fade_avoid_execute_hostile = false,
    fade_avoid_tracked = false,

    font_face = DEFAULT_FONT,
    font_style = 2,
    hide_names = true,
    font_size_normal = 11,
    font_size_small = 9,
    name_text = true,
    level_text = false,
    health_text = false,
    text_vertical_offset = -1.5,
    name_vertical_offset = -2,
    bot_vertical_offset = -3,
    class_colour_friendly_names = true,
    class_colour_enemy_names = false,

    health_text_friend_max = 5,
    health_text_friend_dmg = 4,
    health_text_hostile_max = 5,
    health_text_hostile_dmg = 3,

    colour_hated = {.7,.2,.1},
    colour_neutral = {1,.8,0},
    colour_friendly = {.2,.6,.1},
    colour_tapped = {.5,.5,.5},
    colour_player = {.2,.5,.9},
    colour_self_class = true,
    colour_self = {.2,.6,.1},
    colour_enemy_class = true,
    colour_enemy_player = {.7,.2,.1},
    colour_enemy_pet = {.7,.2,.1},

    execute_enabled = true,
    execute_auto = true,
    execute_percent = 20,
    execute_colour = {1,1,1},

    frame_width = 132,
    frame_height = 13,
    frame_width_minus = 72,
    frame_height_minus = 9,
    frame_width_personal = 132,
    frame_height_personal = 13,
    castbar_height = 5,
    powerbar_height = 3,

    auras_enabled = true,
    auras_on_personal = true,
    auras_vanilla_filter = true,
    auras_whitelist = false,
    auras_pulsate = true,
    auras_centre = true,
    auras_sort = 2,
    auras_time_threshold = 60,
    auras_minimum_length = 0,
    auras_maximum_length = -1,
    auras_icon_normal_size = 24,
    auras_icon_minus_size = 18,
    auras_icon_squareness = .7,

    castbar_enable = true,
    castbar_colour = {.6,.6,.75},
    castbar_unin_colour = {.8,.3,.3},
    castbar_showpersonal = false,
    castbar_icon = true,
    castbar_name = true,
    castbar_showall = true,
    castbar_showfriend = true,
    castbar_showenemy = true,

    tank_mode = true,
    tankmode_force_enable = false,
    threat_brackets = false,
    tankmode_tank_colour = { 0, 1, 0 },
    tankmode_trans_colour = { 1, 1, 0 },
    tankmode_other_colour = { .6, 0, 1 },

    classpowers_enable = true,
    classpowers_on_target = true,
    classpowers_size = 11,
    classpowers_bar_width = 50,
    classpowers_bar_height = 3,

    classpowers_colour_deathknight = {1,.2,.3},
    classpowers_colour_druid       = {1,1,.1},
    classpowers_colour_paladin     = {1,1,.1},
    classpowers_colour_rogue       = {1,1,.1},
    classpowers_colour_mage        = {.5,.5,1},
    classpowers_colour_monk        = {.3,1,.9},
    classpowers_colour_warlock     = {1,.5,1},
    classpowers_colour_overflow    = {1,.3,.3},
    classpowers_colour_inactive    = {.5,.5,.5,.5},
}
-- local functions #############################################################
local function UpdateClickboxSize()
    local width,height =
        (core.profile.frame_width * addon.uiscale)+10,
        (core.profile.frame_height * addon.uiscale)+20

    if C_NamePlate.SetNamePlateOtherSize then
        C_NamePlate.SetNamePlateOtherSize(width,height)
    else
        C_NamePlate.SetNamePlateFriendlySize(width,height)
        C_NamePlate.SetNamePlateEnemySize(width,height)
    end

    C_NamePlate.SetNamePlateSelfSize(width,height)
end
local function QueueClickboxUpdate()
    cc:QueueFunction(UpdateClickboxSize)
end
-- config changed functions ####################################################
local configChanged = {}
function configChanged.tank_mode(v)
    if v then
        addon:GetPlugin('TankMode'):Enable()
    else
        addon:GetPlugin('TankMode'):Disable()
    end
end
function configChanged.tankmode_force_enable(v)
    local ele = addon:GetPlugin('TankMode')
    ele:SetForceEnable(v)
end

function configChanged.castbar_enable(v)
    if v then
        addon:GetPlugin('CastBar'):Enable()
    else
        addon:GetPlugin('CastBar'):Disable()
    end
end

function configChanged.level_text(v)
    if v then
        addon:GetPlugin('LevelText'):Enable()
    else
        addon:GetPlugin('LevelText'):Disable()
    end
end

function configChanged.bar_texture()
    core:configChangedBarTexture()
end

function configChanged.bar_animation()
    core:SetBarAnimation()
end

function configChanged.fade_alpha(v)
    addon:GetPlugin('Fading').faded_alpha = v
end
function configChanged.fade_speed(v)
    addon:GetPlugin('Fading').fade_speed = v
end

local function configChangedCombatAction()
    core:configChangedCombatAction()
end
configChanged.combat_hostile = configChangedCombatAction
configChanged.combat_friendly = configChangedCombatAction

local function configChangedFadeRule(v,on_load)
    local plugin = addon:GetPlugin('Fading')

    if not on_load then
        -- don't reset on the configLoaded call
        plugin:ResetFadeRules()
    end

    if core.profile.fade_all then
        -- remove target_exists rule
        plugin:RemoveFadeRule(3)
    end

    if core.profile.fade_avoid_nameonly then
        plugin:AddFadeRule(function(f)
            return f.IN_NAMEONLY and 1
        end,30)
    end

    if core.profile.fade_avoid_raidicon then
        plugin:AddFadeRule(function(f)
            return f.RaidIcon:IsShown() and 1
        end,1)

        -- force an alpha update whenever a raid icon is added/removed
        core:RegisterMessage('RaidIconUpdate')
    else
        core:UnregisterMessage('RaidIconUpdate')
    end

    if  core.profile.fade_avoid_execute_friend or
        core.profile.fade_avoid_execute_hostile
    then
        if core.profile.fade_avoid_execute_friend then
            plugin:AddFadeRule(function(f)
                return f.state.friend and
                       f.state.in_execute_range and 1
            end,21)
        end

        if core.profile.fade_avoid_execute_hostile then
            plugin:AddFadeRule(function(f)
                return not f.state.friend and
                       f.state.in_execute_range and 1
            end,21)
        end

        -- force alpha update when entering/leaving execute range
        core:RegisterMessage('ExecuteUpdate')
    else
        core:UnregisterMessage('ExecuteUpdate')
    end

    if core.profile.fade_avoid_tracked then
        plugin:AddFadeRule(function(f)
            return f.state.tracked and 1
        end,22)
    end

    if core.profile.fade_neutral_enemy then
        plugin:AddFadeRule(function(f)
            return f.state.reaction == 4 and
                   UnitCanAttack('player',f.unit) and -1
       end,25)
    end

    if core.profile.fade_friendly_npc then
        plugin:AddFadeRule(function(f)
            return f.state.reaction >= 4 and
                   not UnitIsPlayer(f.unit) and
                   not UnitCanAttack('player',f.unit) and -1
        end,25)
    end

    if core.profile.fade_untracked then
        plugin:AddFadeRule(function(f)
            return not f.state.tracked and -1
        end,25)
    end
end
configChanged.fade_all = configChangedFadeRule
configChanged.fade_friendly_npc = configChangedFadeRule
configChanged.fade_neutral_enemy = configChangedFadeRule
configChanged.fade_untracked = configChangedFadeRule
configChanged.fade_avoid_nameonly = configChangedFadeRule
configChanged.fade_avoid_raidicon = configChangedFadeRule
configChanged.fade_avoid_execute_friend = configChangedFadeRule
configChanged.fade_avoid_execute_hostile = configChangedFadeRule
configChanged.fade_avoid_tracked = configChangedFadeRule

local function configChangedTextOffset()
    core:configChangedTextOffset()
end
configChanged.text_vertical_offset = configChangedTextOffset
configChanged.name_vertical_offset = configChangedTextOffset
configChanged.bot_vertical_offset = configChangedTextOffset

local function configChangedReactionColour()
    local ele = addon:GetPlugin('HealthBar')
    ele.colours.hated = core.profile.colour_hated
    ele.colours.neutral = core.profile.colour_neutral
    ele.colours.friendly = core.profile.colour_friendly
    ele.colours.tapped = core.profile.colour_tapped
    ele.colours.player = core.profile.colour_player
    ele.colours.enemy_pet = core.profile.colour_enemy_pet

    if core.profile.colour_self_class then
        ele.colours.self = nil
    else
        ele.colours.self = core.profile.colour_self
    end

    if core.profile.colour_enemy_class then
        ele.colours.enemy_player = nil
    else
        ele.colours.enemy_player = core.profile.colour_enemy_player
    end
end
configChanged.colour_hated = configChangedReactionColour
configChanged.colour_neutral = configChangedReactionColour
configChanged.colour_friendly = configChangedReactionColour
configChanged.colour_tapped = configChangedReactionColour
configChanged.colour_player = configChangedReactionColour
configChanged.colour_self_class = configChangedReactionColour
configChanged.colour_self = configChangedReactionColour
configChanged.colour_enemy_class = configChangedReactionColour
configChanged.colour_enemy_player = configChangedReactionColour
configChanged.colour_enemy_pet = configChangedReactionColour

local function configChangedTankColour()
    local ele = addon:GetPlugin('TankMode')
    ele.colours = {
        core.profile.tankmode_tank_colour,
        core.profile.tankmode_trans_colour,
        core.profile.tankmode_other_colour
    }
end
configChanged.tankmode_tank_colour = configChangedTankColour
configChanged.tankmode_trans_colour = configChangedTankColour
configChanged.tankmode_other_colour = configChangedTankColour

local function configChangedFrameSize()
    core:configChangedFrameSize()
    QueueClickboxUpdate()
end
configChanged.frame_width = configChangedFrameSize
configChanged.frame_height = configChangedFrameSize
configChanged.frame_width_minus = configChangedFrameSize
configChanged.frame_height_minus = configChangedFrameSize
configChanged.castbar_height = configChangedFrameSize

local function configChangedFontOption()
    core:configChangedFontOption()
end
configChanged.font_face = configChangedFontOption
configChanged.font_size_normal = configChangedFontOption
configChanged.font_size_small = configChangedFontOption
configChanged.font_style = configChangedFontOption

function configChanged.nameonly()
    core:configChangedNameOnly()
end
function configChanged.nameonly_no_font_style()
    core:configChangedNameOnly()
    core:configChangedFontOption()
end
configChanged.nameonly_damaged_friends = configChanged.nameonly
configChanged.nameonly_enemies = configChanged.nameonly
configChanged.nameonly_all_enemies = configChanged.nameonly
configChanged.nameonly_target = configChanged.nameonly

function configChanged.auras_enabled(v)
    if v then
        addon:GetPlugin('Auras'):Enable()
    else
        addon:GetPlugin('Auras'):Disable()
    end
end
local function configChangedAuras()
    core:SetAurasConfig()
end
configChanged.auras_vanilla_filter = configChangedAuras
configChanged.auras_whitelist = configChangedAuras
configChanged.auras_pulsate = configChangedAuras
configChanged.auras_centre = configChangedAuras
configChanged.auras_sort = configChangedAuras
configChanged.auras_time_threshold = configChangedAuras
configChanged.auras_minimum_length = configChangedAuras
configChanged.auras_maximum_length = configChangedAuras
configChanged.auras_icon_normal_size = configChangedAuras
configChanged.auras_icon_minus_size = configChangedAuras
configChanged.auras_icon_squareness = configChangedAuras

function configChanged.classpowers_enable(v)
    if v then
        addon:GetPlugin('ClassPowers'):Enable()
    else
        addon:GetPlugin('ClassPowers'):Disable()
    end
end
local function configChangedClassPowers()
    core.ClassPowers.on_target = core.profile.classpowers_on_target
    core.ClassPowers.icon_size = core.profile.classpowers_size
    core.ClassPowers.bar_width = core.profile.classpowers_bar_width
    core.ClassPowers.bar_height = core.profile.classpowers_bar_height

    if addon:GetPlugin('ClassPowers').enabled then
        addon:GetPlugin('ClassPowers'):UpdateConfig()
    end
end
configChanged.classpowers_size = configChangedClassPowers
configChanged.classpowers_on_target = configChangedClassPowers
configChanged.classpowers_bar_width = configChangedClassPowers
configChanged.classpowers_bar_height = configChangedClassPowers

local function configChangedClassPowersColour()
    local class = select(2,UnitClass('player'))
    if core.profile['classpowers_colour_'..strlower(class)] then
        core.ClassPowers.colours[class] =  core.profile['classpowers_colour_'..strlower(class)]
    end

    core.ClassPowers.colours.overflow = core.profile.classpowers_colour_overflow
    core.ClassPowers.colours.inactive = core.profile.classpowers_colour_inactive

    if addon:GetPlugin('ClassPowers').enabled then
        addon:GetPlugin('ClassPowers'):UpdateConfig()
    end
end
configChanged.classpowers_colour_deathknight = configChangedClassPowersColour
configChanged.classpowers_colour_druid = configChangedClassPowersColour
configChanged.classpowers_colour_paladin = configChangedClassPowersColour
configChanged.classpowers_colour_rogue = configChangedClassPowersColour
configChanged.classpowers_colour_mage = configChangedClassPowersColour
configChanged.classpowers_colour_monk = configChangedClassPowersColour
configChanged.classpowers_colour_warlock = configChangedClassPowersColour
configChanged.classpowers_colour_overflow = configChangedClassPowersColour
configChanged.classpowers_colour_inactive = configChangedClassPowersColour

function configChanged.execute_enabled(v)
    if v then
        addon:GetPlugin('Execute'):Enable()
        configChanged.execute_percent()
    else
        addon:GetPlugin('Execute'):Disable()
    end
end
function configChanged.execute_colour(v)
    addon:GetPlugin('Execute').colour = v
end
function configChanged.execute_percent(v)
    if core.profile.execute_auto then
        -- revert to automatic
        addon:GetPlugin('Execute'):SetExecuteRange()
    else
        addon:GetPlugin('Execute'):SetExecuteRange(core.profile.execute_percent)
    end
end
configChanged.execute_auto = configChanged.execute_percent

function configChanged.target_arrows()
    core:configChangedTargetArrows()
end
configChanged.target_glow_colour = configChanged.target_arrows
configChanged.target_arrows_size = configChanged.target_arrows

function configChanged.frame_glow_size(v)
    for k,f in addon:Frames() do
        if f.ThreatGlow then
            f.ThreatGlow:SetSize(v)
        end
        if f.UpdateNameOnlyGlowSize then
            f:UpdateNameOnlyGlowSize()
        end
    end
end

function configChanged.ignore_uiscale(v)
    addon.IGNORE_UISCALE = v
    addon:UI_SCALE_CHANGED()
    QueueClickboxUpdate()
end

-- config loaded functions #####################################################
local configLoaded = {}
configLoaded.fade_alpha = configChanged.fade_alpha
configLoaded.fade_speed = configChanged.fade_speed

configLoaded.nameonly = configChanged.nameonly

configLoaded.colour_hated = configChangedReactionColour

configLoaded.tank_mode = configChanged.tank_mode
configLoaded.tankmode_force_enable = configChanged.tankmode_force_enable
configLoaded.tankmode_tank_colour = configChangedTankColour

configLoaded.castbar_enable = configChanged.castbar_enable
configLoaded.level_text = configChanged.level_text

configLoaded.auras_enabled = configChanged.auras_enabled
configLoaded.auras_whitelist = configChangedAuras

function configLoaded.classpowers_enable(v)
    if v then
        addon:GetPlugin('ClassPowers'):Enable()
    else
        addon:GetPlugin('ClassPowers'):Disable()
    end
end

local function configLoadedFadeRule()
    configChangedFadeRule(nil,true)
end
configLoaded.fade_all = configLoadedFadeRule

configLoaded.execute_enabled = configChanged.execute_enabled
configLoaded.execute_colour = configChanged.execute_colour
configLoaded.execute_percent = configChanged.execute_percent

function configLoaded.ignore_uiscale(v)
    addon.IGNORE_UISCALE = v
    addon:UI_SCALE_CHANGED()
end

-- init config #################################################################
function core:InitialiseConfig()
    self.config = kc:Initialise('KuiNameplatesCore',default_config)
    self.profile = self.config:GetConfig()

    self.config:RegisterConfigChanged(function(self,k,v)
        core.profile = self:GetConfig()
        core:SetLocals()

        if k then
            -- call affected listener
            if configChanged[k] then
                configChanged[k](v)
            end
        else
            -- profile changed; call all listeners
            for k,f in pairs(configChanged) do
                f(core.profile[k])
            end
        end

        if addon.debug and addon.debug_config then
            kui.print(self:GetActiveProfile())
        end

        for i,f in addon:Frames() do
            -- hide and re-show frames
            if f:IsShown() then
                local unit = f.unit
                f.handler:OnHide()
                f.handler:OnUnitAdded(unit)
            end
        end
    end)

    -- run config loaded functions
    for k,f in pairs(configLoaded) do
        f(self.profile[k])
    end

    -- inform config addon that the config table is available if it's loaded
    if KuiNameplatesCoreConfig then
        KuiNameplatesCoreConfig:LayoutLoaded()
    end

    -- update clickbox size to fit with config
    QueueClickboxUpdate()

    -- also update upon closing interface options
    InterfaceOptionsFrame:HookScript('OnHide',QueueClickboxUpdate)
end

-- combat checking frame #######################################################
cc.queue = {}
function cc:QueueFunction(func,...)
    if InCombatLockdown() then
        tinsert(self.queue,{func,{...}})
    else
        func(...)
    end
end
function cc:QueueConfigChanged(name)
    if type(configChanged[name]) == 'function' then
        self:QueueFunction(configChanged[name],core.profile[name])
    end
end
cc:SetScript('OnEvent',function(self,event,...)
    for i,f_tbl in ipairs(self.queue) do
        if type(f_tbl[1]) == 'function' then
            f_tbl[1](unpack(f_tbl[2]))
        end
    end

    wipe(self.queue)
end)
cc:RegisterEvent('PLAYER_REGEN_ENABLED')
