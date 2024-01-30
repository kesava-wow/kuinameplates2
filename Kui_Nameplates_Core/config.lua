--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
local kui = LibStub('Kui-1.0')
local kc = LibStub('KuiConfig-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local addon = KuiNameplates
local core = KuiNameplatesCore --luacheck:globals KuiNameplatesCore
-- local event frame
local cc = CreateFrame('Frame')
-- add media to LSM ############################################################
LSM:Register(LSM.MediaType.FONT,'FrancoisOne',kui.m.f.francois)
LSM:Register(LSM.MediaType.FONT,'Roboto Condensed Bold',kui.m.f.roboto,
    LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU)

LSM:Register(LSM.MediaType.STATUSBAR, 'Kui status bar', kui.m.t.bar)
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui status bar (brighter)', kui.m.t.brightbar)
LSM:Register(LSM.MediaType.STATUSBAR, 'Kui shaded bar', kui.m.t.oldbar)

local locale = GetLocale()
local font_support = locale ~= 'zhCN' and locale ~= 'zhTW' and locale ~= 'koKR'

local DEFAULT_FONT = font_support and 'Roboto Condensed Bold' or
                     LSM:GetDefault(LSM.MediaType.FONT)
local DEFAULT_BAR = 'Kui status bar'
-- default configuration #######################################################
local default_config = {
    bar_texture = DEFAULT_BAR,
    bar_animation = 3,
    bar_spark = true, -- NEX XXX requires reload
    combat_hostile = 1,
    combat_friendly = 1,
    ignore_uiscale = false,
    glow_as_shadow = true,
    state_icons = true,
    target_glow = true,
    target_glow_colour = { .3, .7, 1, .6 },
    mouseover_glow = false,
    mouseover_glow_colour = { .3, .7, 1, .5 },
    mouseover_highlight = true,
    mouseover_highlight_opacity = .4, -- NEX
    frame_glow_size_shadow = 3,
    frame_glow_size_target = 8,
    frame_glow_size_threat = 8,
    target_arrows = false,
    target_arrows_size = 28,
    target_arrows_inset = 3, -- NEX
    target_arrows_texture = 'interface/addons/kui_nameplates_core/media/targetarrows3', -- NEX
    use_blizzard_personal = false,
    use_blizzard_powers = false,
    frame_vertical_offset = 0, -- NEX
    show_arena_id = true, -- NEX

    clickthrough_self = false,
    clickthrough_friend = false,
    clickthrough_enemy = false,

    nameonly = true,
    nameonly_no_font_style = false,
    nameonly_health_colour = true,
    nameonly_target = true,
    nameonly_all_enemies = false,
    nameonly_neutral = false,
    nameonly_enemies = true,
    nameonly_hostile_players = false,
    nameonly_damaged_enemies = true,
    nameonly_friends = true,
    nameonly_friendly_players = true,
    nameonly_damaged_friends = true,
    nameonly_combat_hostile = true,
    nameonly_combat_hostile_player = true,
    nameonly_combat_friends = true,
    guild_text_npcs = true,
    guild_text_players = false,
    title_text_players = false,

    fade_all = false,
    fade_non_target_alpha = .5,
    fade_conditional_alpha = .3,
    fade_speed = .3,
    fade_friendly_npc = false,
    fade_friendly_npc_exclude_titled = false,
    fade_neutral_enemy = false,
    fade_untracked = false,
    fade_avoid_nameonly = true,
    fade_avoid_raidicon = true,
    fade_avoid_execute_friend = false,
    fade_avoid_execute_hostile = false,
    fade_avoid_tracked = false,
    fade_avoid_combat = false,
    fade_avoid_casting_friendly = false,
    fade_avoid_casting_hostile = false,
    fade_avoid_casting_interruptible = false,
    fade_avoid_casting_uninterruptible = true,
    fade_avoid_mouseover = false,

    font_face = DEFAULT_FONT,
    font_style = 2,
    hide_names = true,
    font_size_normal = 11,
    font_size_small = 10,
    name_text = true,
    level_text = false,
    level_nameonly = false,
    health_text = false,
    name_vertical_offset = -3,
    bot_vertical_offset = -3,
    name_constrain_offset = -20, -- NEX
    name_constrain_justify = 2, -- NEX

    name_colour_white_in_bar_mode = true,
    class_colour_friendly_names = true,
    class_colour_enemy_names = false,
    name_colour_brighten_class = .2, -- NEX
    name_colour_player_friendly = {.6,.7,1},
    name_colour_player_hostile  = {1,.7,.7},
    name_colour_npc_friendly = {.7,1,.7},
    name_colour_npc_neutral = {1,.97,.7},
    name_colour_npc_hostile = {1,.7,.7},

    health_text_friend_max = 1,
    health_text_friend_dmg = 5,
    health_text_hostile_max = 1,
    health_text_hostile_dmg = 4,
    health_text_percent_symbol = false, -- NEX

    colour_hated = {.7,.2,.1},
    colour_neutral = {1,.8,0},
    colour_friendly = {.2,.6,.1},
    colour_friendly_pet = {.2,.6,.1},
    colour_tapped = {.5,.5,.5},
    colour_player_class = false,
    colour_player = {.2,.5,.9},
    colour_self_class = true,
    colour_self = {.2,.6,.1},
    colour_enemy_class = true,
    colour_enemy_player = {.7,.2,.1},
    colour_enemy_pet = {.7,.2,.1},

    absorb_enable = true,
    absorb_striped = true,
    colour_absorb = {.3,.7,1,.5},

    execute_enabled = true,
    execute_auto = true,
    execute_percent = 20,
    execute_colour = {1,1,1},

    frame_width = 100,
    frame_height = 14,
    frame_width_minus = 72,
    frame_height_minus = 14,
    frame_width_personal = 128,
    frame_height_personal = 16,
    frame_width_target = 128,
    frame_height_target = 16,
    frame_target_size = true,
    frame_minus_size = true,
    frame_padding_x = 10,
    frame_padding_y = 20,
    powerbar_height = 3,
    global_scale = 1,

    auras_enabled = true,
    auras_on_personal = true,
    auras_on_friends = true, -- NEX
    auras_on_enemies = true, -- NEX
    auras_on_minus = true, -- NEX
    auras_pulsate = true,
    auras_centre = true,
    auras_sort = 2,
    auras_show_all_self = false,
    auras_hide_all_other = false,
    auras_time_threshold = 60,
    auras_icon_normal_size = 24,
    auras_icon_minus_size = 18,
    auras_icon_squareness = .7,
    auras_colour_short = {1,.3,.3},
    auras_colour_medium = {1,.8,.3},
    auras_colour_long = {1,1,1},
    auras_show_purge = true,
    auras_purge_size = 32,
    auras_purge_opposite = false,
    auras_side = 1,
    auras_offset = 15,
    auras_decimal_threshold = 2, -- NEX
    auras_highlight_other = true, -- NEX
    auras_per_row = 5, -- NEX
    auras_cd_size = 0,
    auras_count_size = 0,

    castbar_enable = true,
    castbar_colour = {.75,.75,.9},
    castbar_unin_colour = {.8,.3,.3},
    castbar_showpersonal = false,
    castbar_icon = true,
    castbar_name = true,
    castbar_shield = true,
    castbar_shield_size = 16,
    castbar_showall = true,
    castbar_showfriend = true,
    castbar_showenemy = true,
    castbar_animate = true,
    castbar_animate_change_colour = true,
    castbar_name_vertical_offset = 6,
    castbar_spacing = 1, -- NEX
    castbar_height = 8,
    castbar_detach = false,
    castbar_detach_height = 22,
    castbar_detach_width = 38,
    castbar_detach_offset = 6,
    castbar_detach_combine = true,
    castbar_detach_nameonly = false,
    castbar_detach_match_frame_width = false, -- NEX
    castbar_icon_side = 1,

    tank_mode = true,
    tankmode_force_enable = false,
    tankmode_force_offtank = false,
    threat_brackets = false,
    threat_brackets_size = 24,
    frame_glow_threat = true,
    tankmode_tank_colour = { 0, 1, 0 },
    tankmode_trans_colour = { 1, 1, 0 },
    tankmode_other_colour = { .6, 0, 1 },
    tankmode_tank_glow_colour = { .9, 0, 0, .6 },
    tankmode_trans_glow_colour = { .9, .5, 0, .6 },

    classpowers_enable = true,
    classpowers_on_target = true,
    classpowers_on_friends = true,
    classpowers_on_enemies = true,
    classpowers_size = 12,
    classpowers_bar_width = 80,
    classpowers_bar_height = 5,
    classpowers_y = 1,
    classpowers_y_personal = -8, -- XXX remove with 226_CLASSPOWERS_Y

    classpowers_colour_deathknight = {1,.2,.3},
    classpowers_colour_druid       = {1,1,.1},
    classpowers_colour_paladin     = {1,1,.1},
    classpowers_colour_rogue       = {1,1,.1},
    classpowers_colour_mage        = {.5,.5,1},
    classpowers_colour_monk        = {.3,1,.9},
    classpowers_colour_warlock     = {.9,.6,1},
    classpowers_colour_overflow    = {1,.3,.3},
    classpowers_colour_inactive    = {.5,.5,.5,.7},
    classpowers_colour_animacharged    = {0,.874,1,1},
    classpowers_colour_animacharged_active    = {1,0,0,1},

    bossmod_enable = true,
    bossmod_control_visibility = true,
    bossmod_icon_size = 32,
    bossmod_x_offset = 0,
    bossmod_y_offset = 35,
    bossmod_clickthrough = false,

    cvar_enable = false,
    cvar_show_friendly_npcs = GetCVarDefault('nameplateShowFriendlyNPCs')=="1",
    cvar_name_only = GetCVarDefault('nameplateShowOnlyNames')=="1",
    cvar_personal_show_always = GetCVarDefault('nameplatePersonalShowAlways')=="1",
    cvar_personal_show_combat = GetCVarDefault('nameplatePersonalShowInCombat')=="1",
    cvar_personal_show_target = GetCVarDefault('nameplatePersonalShowWithTarget')=="1",
    cvar_clamp_top = tonumber(GetCVarDefault('nameplateOtherTopInset')),
    cvar_clamp_bottom = tonumber(GetCVarDefault('nameplateOtherBottomInset')),
    cvar_self_clamp_top = tonumber(GetCVarDefault('nameplateSelfTopInset')),
    cvar_self_clamp_bottom = tonumber(GetCVarDefault('nameplateSelfBottomInset')),
    cvar_overlap_v = tonumber(GetCVarDefault('nameplateOverlapV')),
    cvar_disable_scale = true,
    cvar_disable_alpha = true,
    cvar_self_alpha = 1,
    cvar_occluded_mult = tonumber(GetCVarDefault('nameplateOccludedAlphaMult')),

    -- XXX legacy aura variables; kept for transition
    -- transition logic: p=px*py;x=ox;y=oy.
    auras_cd_point_x = 1,
    auras_cd_point_y = 1,
    auras_cd_offset_x = -4,
    auras_cd_offset_y = 3,
    auras_count_point_x = 3,
    auras_count_point_y = 3,
    auras_count_offset_x = 5,
    auras_count_offset_y = -2,
    -- simple movables; XXX to be moved once KuiConfig supports subtables
    -- auras text overrides
    auras_cd_point = 1, -- TOPLEFT
    auras_cd_x = -4,
    auras_cd_y = 3,
    auras_count_point = 9, -- BOTTOMRIGHT
    auras_count_x = 5,
    auras_count_y = -2,
    show_quest_icon = true,
    quest_icon_size = 18,
    quest_icon_point = 2,
    quest_icon_x = -18,
    quest_icon_y = 0,
    show_raid_icon = true,
    raid_icon_size = 26,
    raid_icon_point = 8,
    raid_icon_x = 31,
    raid_icon_y = 0,
}
-- global scale helper #########################################################
-- for frame/texture sizes; apply global scale to given value
local GLOBAL_SCALE
function core:Scale(v)
    if not tonumber(GLOBAL_SCALE) or GLOBAL_SCALE == 1 then
        return v
    else
        return floor((v*GLOBAL_SCALE)+.5)
    end
end
-- local functions #############################################################
local function UpdateClickboxSize()
    if kui.CLASSIC then return end -- XXX functions exist, but break display
    local x_pad = core:Scale(core.profile.frame_padding_x)
    local y_pad = core:Scale(core.profile.frame_padding_y)

    local o_width = (core:Scale(core.profile.frame_width) * addon.uiscale) + x_pad
    local o_height = (core:Scale(core.profile.frame_height) * addon.uiscale) + y_pad

    if C_NamePlate.SetNamePlateOtherSize then
        C_NamePlate.SetNamePlateOtherSize(o_width,o_height)
    else
        C_NamePlate.SetNamePlateFriendlySize(o_width,o_height)
        C_NamePlate.SetNamePlateEnemySize(o_width,o_height)
    end

    if addon.USE_BLIZZARD_PERSONAL then
        -- obey width, use static height
        C_NamePlate.SetNamePlateSelfSize(
            core.profile.frame_width_personal - x_pad,
            45
        )
    else
        local p_width = (core:Scale(core.profile.frame_width_personal) * addon.uiscale) + x_pad
        local p_height = (core:Scale(core.profile.frame_height_personal) * addon.uiscale) + y_pad
        C_NamePlate.SetNamePlateSelfSize(p_width,p_height)
    end
end
local function QueueClickboxUpdate()
    cc:QueueFunction(UpdateClickboxSize)
end
-- config changed functions ####################################################
local configChanged = {}
function configChanged.target_arrows(v)
    if v then
        -- create arrows if needed
        core:configChangedTargetArrows()
    end
end
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
function configChanged.tankmode_force_offtank(v)
    local ele = addon:GetPlugin('TankMode')
    ele:SetForceOffTank(v)
end

function configChanged.bar_texture()
    core:configChangedBarTexture()
end

function configChanged.bar_animation()
    core:SetBarAnimation()
end

function configChanged.state_icons()
    core:configChangedStateIcons()
end

function configChanged.fade_non_target_alpha(v)
    addon:GetPlugin('Fading').non_target_alpha = v
end
function configChanged.fade_conditional_alpha(v)
    addon:GetPlugin('Fading').conditional_alpha = v
end
function configChanged.fade_speed(v)
    addon:GetPlugin('Fading').fade_speed = v
end

local function configChangedCombatAction()
    if core.profile.combat_hostile == 1 and
       core.profile.combat_friendly == 1
    then
        addon:GetPlugin('CombatToggle'):Disable()
    else
        addon:GetPlugin('CombatToggle'):Enable()
        core.CombatToggle = {
            hostile = core.profile.combat_hostile,
            friendly = core.profile.combat_friendly
        }
    end
end
configChanged.combat_hostile = configChangedCombatAction
configChanged.combat_friendly = configChangedCombatAction

local function configChangedFadeRule(_,on_load)
    local plugin = addon:GetPlugin('Fading')
    if not on_load then
        -- don't reset on the configLoaded call
        plugin:ResetFadeRules()
    end
    core:InitialiseFadeRules()
end
configChanged.fade_all = configChangedFadeRule
configChanged.fade_friendly_npc = configChangedFadeRule
configChanged.fade_friendly_npc_exclude_titled = configChangedFadeRule
configChanged.fade_neutral_enemy = configChangedFadeRule
configChanged.fade_untracked = configChangedFadeRule
configChanged.fade_avoid_nameonly = configChangedFadeRule
configChanged.fade_avoid_raidicon = configChangedFadeRule
configChanged.fade_avoid_execute_friend = configChangedFadeRule
configChanged.fade_avoid_execute_hostile = configChangedFadeRule
configChanged.fade_avoid_tracked = configChangedFadeRule
configChanged.fade_avoid_combat = configChangedFadeRule
configChanged.fade_avoid_casting_friendly = configChangedFadeRule
configChanged.fade_avoid_casting_hostile = configChangedFadeRule
configChanged.fade_avoid_casting_interruptible = configChangedFadeRule
configChanged.fade_avoid_casting_uninterruptible = configChangedFadeRule
configChanged.fade_avoid_mouseover = configChangedFadeRule

local function configChangedTextOffset()
    core:configChangedTextOffset()
end
configChanged.name_vertical_offset = configChangedTextOffset
configChanged.bot_vertical_offset = configChangedTextOffset

local function configChangedReactionColour()
    local ele = addon:GetPlugin('HealthBar')
    ele.colours.hated = core.profile.colour_hated
    ele.colours.neutral = core.profile.colour_neutral
    ele.colours.friendly = core.profile.colour_friendly
    ele.colours.tapped = core.profile.colour_tapped
    ele.colours.enemy_pet = core.profile.colour_enemy_pet
    ele.colours.friendly_pet = core.profile.colour_friendly_pet

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

    if core.profile.colour_player_class then
        ele.colours.player = nil
    else
        ele.colours.player = core.profile.colour_player
    end
end
configChanged.colour_hated = configChangedReactionColour
configChanged.colour_neutral = configChangedReactionColour
configChanged.colour_friendly = configChangedReactionColour
configChanged.colour_friendly_pet = configChangedReactionColour
configChanged.colour_tapped = configChangedReactionColour
configChanged.colour_player_class = configChangedReactionColour
configChanged.colour_player = configChangedReactionColour
configChanged.colour_self_class = configChangedReactionColour
configChanged.colour_self = configChangedReactionColour
configChanged.colour_enemy_class = configChangedReactionColour
configChanged.colour_enemy_player = configChangedReactionColour
configChanged.colour_enemy_pet = configChangedReactionColour

local function configChangedAbsorb()
    if core.profile.absorb_enable then
        addon:GetPlugin('AbsorbBar'):Enable()
    else
        addon:GetPlugin('AbsorbBar'):Disable()
    end

    core:configChangedAbsorb()
end
configChanged.absorb_enable = configChangedAbsorb
configChanged.absorb_striped = configChangedAbsorb
configChanged.colour_absorb = configChangedAbsorb

local function configChangedTankColour()
    addon:GetPlugin('TankMode').colours = {
        core.profile.tankmode_tank_colour,
        core.profile.tankmode_trans_colour,
        core.profile.tankmode_other_colour,
    }
    addon:GetPlugin('Threat').colours = {
        core.profile.tankmode_tank_glow_colour,
        core.profile.tankmode_trans_glow_colour,
    }
end
configChanged.tankmode_tank_colour = configChangedTankColour
configChanged.tankmode_trans_colour = configChangedTankColour
configChanged.tankmode_other_colour = configChangedTankColour
configChanged.tankmode_tank_glow_colour = configChangedTankColour
configChanged.tankmode_trans_glow_colour = configChangedTankColour

local function configChangedFrameSize()
    core:configChangedFrameSize()
    QueueClickboxUpdate()
end
configChanged.frame_width = configChangedFrameSize
configChanged.frame_height = configChangedFrameSize
configChanged.frame_width_minus = configChangedFrameSize
configChanged.frame_height_minus = configChangedFrameSize
configChanged.frame_width_target = configChangedFrameSize
configChanged.frame_height_target = configChangedFrameSize
configChanged.frame_padding_x = configChangedFrameSize
configChanged.frame_padding_y = configChangedFrameSize

local function configChangedFontOption()
    core:configChangedFontOption()
end
configChanged.font_face = configChangedFontOption
configChanged.font_size_normal = configChangedFontOption
configChanged.font_size_small = configChangedFontOption
configChanged.font_style = configChangedFontOption

local function configChangedName()
    core:configChangedName()
    core:configChangedTextOffset()
end
configChanged.name_constrain = configChangedName
configChanged.name_constrain_offset = configChangedName
configChanged.name_constrain_justify = configChangedName
configChanged.name_colour_white_in_bar_mode = configChangedName
configChanged.class_colour_friendly_names = configChangedName
configChanged.class_colour_enemy_names = configChangedName
configChanged.name_colour_brighten_class = configChangedName
configChanged.name_colour_player_friendly = configChangedName
configChanged.name_colour_player_hostile = configChangedName
configChanged.name_colour_npc_friendly = configChangedName
configChanged.name_colour_npc_neutral = configChangedName
configChanged.name_colour_npc_hostile = configChangedName

function configChanged.nameonly()
    core:configChangedNameOnly()
end
function configChanged.nameonly_no_font_style()
    core:configChangedNameOnly()
    core:configChangedFontOption()
end
configChanged.nameonly_health_colour = configChanged.nameonly
configChanged.nameonly_target = configChanged.nameonly
configChanged.nameonly_all_enemies = configChanged.nameonly
configChanged.nameonly_neutral = configChanged.nameonly
configChanged.nameonly_enemies = configChanged.nameonly
configChanged.nameonly_hostile_players = configChanged.nameonly
configChanged.nameonly_damaged_enemies = configChanged.nameonly
configChanged.nameonly_friends = configChanged.nameonly
configChanged.nameonly_friendly_players = configChanged.nameonly
configChanged.nameonly_damaged_friends = configChanged.nameonly
configChanged.nameonly_combat_hostile = configChanged.nameonly
configChanged.nameonly_combat_hostile_player = configChanged.nameonly
configChanged.nameonly_combat_friends = configChanged.nameonly

local function configChangedAuras()
    core:SetAurasConfig()
end
configChanged.auras_enabled = configChangedAuras
configChanged.auras_pulsate = configChangedAuras
configChanged.auras_centre = configChangedAuras
configChanged.auras_sort = configChangedAuras
configChanged.auras_time_threshold = configChangedAuras
configChanged.auras_icon_normal_size = configChangedAuras
configChanged.auras_icon_minus_size = configChangedAuras
configChanged.auras_icon_squareness = configChangedAuras
configChanged.auras_on_personal = configChangedAuras
configChanged.auras_on_friends = configChangedAuras
configChanged.auras_on_enemies = configChangedAuras
configChanged.auras_on_minus = configChangedAuras
configChanged.auras_show_all_self = configChangedAuras
configChanged.auras_hide_all_other = configChangedAuras
configChanged.auras_colour_short = configChangedAuras
configChanged.auras_colour_medium = configChangedAuras
configChanged.auras_colour_long = configChangedAuras
configChanged.auras_show_purge = configChangedAuras
configChanged.auras_purge_size = configChangedAuras
configChanged.auras_purge_opposite = configChangedAuras
configChanged.auras_side = configChangedAuras
configChanged.auras_offset = configChangedAuras
configChanged.auras_decimal_threshold = configChangedAuras
configChanged.auras_highlight_other = configChangedAuras
configChanged.auras_per_row = configChangedAuras
configChanged.auras_cd_size = configChangedAuras
configChanged.auras_count_size = configChangedAuras
configChanged.auras_cd_point = configChangedAuras
configChanged.auras_cd_x = configChangedAuras
configChanged.auras_cd_y = configChangedAuras
configChanged.auras_count_point = configChangedAuras
configChanged.auras_count_x = configChangedAuras
configChanged.auras_count_y = configChangedAuras

local function configChangedCastBar()
    core:SetCastBarConfig()
end
function configChanged.castbar_enable(v)
    if v then
        addon:GetPlugin('CastBar'):Enable()
    else
        addon:GetPlugin('CastBar'):Disable()
    end
    configChangedCastBar()
end
configChanged.castbar_colour = configChangedCastBar
configChanged.castbar_unin_colour = configChangedCastBar
configChanged.castbar_icon = configChangedCastBar
configChanged.castbar_name = configChangedCastBar
configChanged.castbar_shield = configChangedCastBar
configChanged.castbar_shield_size = configChangedCastBar
configChanged.castbar_animate = configChangedCastBar
configChanged.castbar_animate_change_colour = configChangedCastBar
configChanged.castbar_name_vertical_offset = configChangedCastBar
configChanged.castbar_spacing = configChangedCastBar
configChanged.castbar_height = configChangedCastBar
configChanged.castbar_detach = configChangedCastBar
configChanged.castbar_detach_height = configChangedCastBar
configChanged.castbar_detach_width = configChangedCastBar
configChanged.castbar_detach_offset = configChangedCastBar
configChanged.castbar_detach_combine = configChangedCastBar
configChanged.castbar_icon_side = configChangedCastBar

function configChanged.classpowers_enable(v)
    if v then
        addon:GetPlugin('ClassPowers'):Enable()
    else
        addon:GetPlugin('ClassPowers'):Disable()
    end
end
local function configChangedClassPowers()
    if not core.ClassPowers then return end
    core.ClassPowers.on_target = core.profile.classpowers_on_target
    core.ClassPowers.icon_size = core:Scale(core.profile.classpowers_size)
    core.ClassPowers.bar_width = core:Scale(core.profile.classpowers_bar_width)
    core.ClassPowers.bar_height = core:Scale(core.profile.classpowers_bar_height)
    addon:GetPlugin('ClassPowers'):UpdateConfig()
end
configChanged.classpowers_size = configChangedClassPowers
configChanged.classpowers_on_target = configChangedClassPowers
configChanged.classpowers_bar_width = configChangedClassPowers
configChanged.classpowers_bar_height = configChangedClassPowers

local function configChangedClassPowersColour()
    if not core.ClassPowers then return end

    local class = select(2,UnitClass('player'))
    if core.profile['classpowers_colour_'..strlower(class)] then
        core.ClassPowers.colours[class] =  core.profile['classpowers_colour_'..strlower(class)]
    end

    core.ClassPowers.colours.overflow = core.profile.classpowers_colour_overflow
    core.ClassPowers.colours.inactive = core.profile.classpowers_colour_inactive
    core.ClassPowers.colours.animacharged = core.profile.classpowers_colour_animacharged
    core.ClassPowers.colours.animacharged_active = core.profile.classpowers_colour_animacharged_active

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
configChanged.classpowers_colour_animacharged = configChangedClassPowersColour
configChanged.classpowers_colour_animacharged_active = configChangedClassPowersColour

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
function configChanged.execute_percent()
    if core.profile.execute_auto then
        -- revert to automatic
        addon:GetPlugin('Execute'):SetExecuteRange()
    else
        addon:GetPlugin('Execute'):SetExecuteRange(core.profile.execute_percent)
    end
end
configChanged.execute_auto = configChanged.execute_percent

function configChanged.ignore_uiscale(v)
    addon.IGNORE_UISCALE = v
    addon:UI_SCALE_CHANGED()
    QueueClickboxUpdate()
end

local function ClickthroughUpdate()
    C_NamePlate.SetNamePlateSelfClickThrough(core.profile.clickthrough_self)
    C_NamePlate.SetNamePlateFriendlyClickThrough(core.profile.clickthrough_friend)
    C_NamePlate.SetNamePlateEnemyClickThrough(core.profile.clickthrough_enemy)
end
local function QueueClickthroughUpdate()
    cc:QueueFunction(ClickthroughUpdate)
end
configChanged.clickthrough_self = QueueClickthroughUpdate
configChanged.clickthrough_friend = QueueClickthroughUpdate
configChanged.clickthrough_enemy = QueueClickthroughUpdate

configChanged.bossmod_enable = function(v)
    if v then
        addon:GetPlugin('BossMods'):Enable()
    else
        addon:GetPlugin('BossMods'):Disable()
    end
end
local function configChangedBossMod()
    core.BossModIcon.icon_size = core:Scale(core.profile.bossmod_icon_size)
    core.BossModIcon.icon_x_offset = core:Scale(core.profile.bossmod_x_offset)
    core.BossModIcon.icon_y_offset = core:Scale(core.profile.bossmod_y_offset)
    core.BossModIcon.control_visibility = core.profile.bossmod_control_visibility
    core.BossModIcon.clickthrough = core.profile.bossmod_clickthrough

    if addon:GetPlugin('BossMods').enabled then
        addon:GetPlugin('BossMods'):UpdateConfig()
    end
end
configChanged.bossmod_control_visibility = configChangedBossMod
configChanged.bossmod_icon_size = configChangedBossMod
configChanged.bossmod_x_offset = configChangedBossMod
configChanged.bossmod_y_offset = configChangedBossMod
configChanged.bossmod_clickthrough = configChangedBossMod

local function UpdateCVars()
    SetCVar('nameplateShowFriendlyNPCs',core.profile.cvar_show_friendly_npcs)
    SetCVar('nameplateShowOnlyNames',core.profile.cvar_name_only)
    SetCVar('nameplatePersonalShowAlways',core.profile.cvar_personal_show_always)
    SetCVar('nameplatePersonalShowInCombat',core.profile.cvar_personal_show_combat)
    SetCVar('nameplatePersonalShowWithTarget',core.profile.cvar_personal_show_target)
    SetCVar('nameplateOtherTopInset',core.profile.cvar_clamp_top)
    SetCVar('nameplateLargeTopInset',core.profile.cvar_clamp_top)
    SetCVar('nameplateOtherBottomInset',core.profile.cvar_clamp_bottom)
    SetCVar('nameplateLargeBottomInset',core.profile.cvar_clamp_bottom)
    SetCVar('nameplateSelfTopInset',core.profile.cvar_self_clamp_top)
    SetCVar('nameplateSelfBottomInset',core.profile.cvar_self_clamp_bottom)
    SetCVar('nameplateOverlapV',core.profile.cvar_overlap_v)

    SetCVar('nameplateOccludedAlphaMult',core.profile.cvar_occluded_mult)
    SetCVar('nameplateSelfAlpha',core.profile.cvar_self_alpha)

    if core.profile.cvar_disable_scale then
        SetCVar('nameplateMinScale',1)
        SetCVar('nameplateMaxScale',1)
        SetCVar('nameplateLargerScale',1)
        SetCVar('nameplateSelectedScale',1)
        SetCVar('nameplateSelfScale',1)
    elseif GetCVar('nameplateMinScale') == '1' and
           GetCVar('nameplateMaxScale') == '1' and
           GetCVar('nameplateLargerScale') == '1' and
           GetCVar('nameplateSelectedScale') == '1' and
           GetCVar('nameplateSelfScale') == '1'
    then
        -- reset to defaults if the current values match ours,
        -- since i haven't provided a way to set them directly.
        SetCVar('nameplateMinScale',GetCVarDefault('nameplateMinScale'))
        SetCVar('nameplateMaxScale',GetCVarDefault('nameplateMaxScale'))
        SetCVar('nameplateLargerScale',GetCVarDefault('nameplateLargerScale'))
        SetCVar('nameplateSelectedScale',GetCVarDefault('nameplateSelectedScale'))
        SetCVar('nameplateSelfScale',GetCVarDefault('nameplateSelfScale'))
    end

    if core.profile.cvar_disable_alpha then
        SetCVar('nameplateMinAlpha',1)
        SetCVar('nameplateMaxAlpha',1)
        SetCVar('nameplateSelectedAlpha',1)
    elseif GetCVar('nameplateMinAlpha') == '1' and
           GetCVar('nameplateMaxAlpha') == '1' and
           GetCVar('nameplateSelectedAlpha') == '1'
    then
        -- reset to defaults
        SetCVar('nameplateMinAlpha',GetCVarDefault('nameplateMinAlpha'))
        SetCVar('nameplateMaxAlpha',GetCVarDefault('nameplateMaxAlpha'))
        SetCVar('nameplateSelectedAlpha',GetCVarDefault('nameplateSelectedAlpha'))
    end
end
local function configChangedCVar()
    if InCombatLockdown() then
        return cc:QueueConfigChanged('cvar_enable')
    end
    if core.profile.cvar_enable then
        -- register related events & update cvars immediately
        cc:EnableCVarUpdate()
        UpdateCVars()
    else
        -- leave cvars alone entirely if not enabled
        cc:DisableCVarUpdate()
    end
end
configChanged.cvar_enable = configChangedCVar
configChanged.cvar_show_friendly_npcs = configChangedCVar
configChanged.cvar_personal_show_always = configChangedCVar
configChanged.cvar_personal_show_combat = configChangedCVar
configChanged.cvar_personal_show_target = configChangedCVar
configChanged.cvar_clamp_top = configChangedCVar
configChanged.cvar_clamp_bottom = configChangedCVar
configChanged.cvar_self_clamp_top = configChangedCVar
configChanged.cvar_self_clamp_bottom = configChangedCVar
configChanged.cvar_overlap_v = configChangedCVar
configChanged.cvar_disable_scale = configChangedCVar
configChanged.cvar_disable_alpha = configChangedCVar
configChanged.cvar_self_alpha = configChangedCVar
configChanged.cvar_occluded_mult = configChangedCVar

function configChanged.global_scale()
    configChanged.state_icons()
    configChangedCastBar()
    configChangedAuras()
    configChangedFontOption()
    configChangedClassPowers()
    configChangedTextOffset()
    configChangedFrameSize()
    configChanged.show_quest_icon()
    configChanged.show_raid_icon()
end

-- simple-movables #############################################################
do
    local function this()
        core:configChangedQuestIcon()
    end
    configChanged.show_quest_icon = this
    configChanged.quest_icon_size = this
    configChanged.quest_icon_point = this
    configChanged.quest_icon_x = this
    configChanged.quest_icon_y = this
end
do
    local function this()
        core:configChangedRaidIcon()
    end
    configChanged.show_raid_icon = this
    configChanged.raid_icon_size = this
    configChanged.raid_icon_point = this
    configChanged.raid_icon_x = this
    configChanged.raid_icon_y = this
end

-- config loaded functions #####################################################
local configLoaded = {}
configLoaded.fade_non_target_alpha = configChanged.fade_non_target_alpha
configLoaded.fade_conditional_alpha = configChanged.fade_conditional_alpha
configLoaded.fade_speed = configChanged.fade_speed

configLoaded.class_colour_friendly_names = configChangedName

configLoaded.nameonly = configChanged.nameonly

configLoaded.colour_hated = configChangedReactionColour

configLoaded.absorb_enable = configChanged.absorb_enable

configLoaded.tank_mode = configChanged.tank_mode
configLoaded.tankmode_force_enable = configChanged.tankmode_force_enable
configLoaded.tankmode_force_offtank = configChanged.tankmode_force_offtank
configLoaded.tankmode_tank_colour = configChangedTankColour

configLoaded.auras_enabled = configChangedAuras

configLoaded.castbar_enable = configChanged.castbar_enable

configLoaded.clickthrough_self = QueueClickthroughUpdate

configLoaded.cvar_enable = configChangedCVar

configLoaded.state_icons = configChanged.state_icons

configLoaded.combat_hostile = configChangedCombatAction

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

function configLoaded.use_blizzard_personal(v)
    addon.USE_BLIZZARD_PERSONAL = v
end
function configLoaded.use_blizzard_powers(v)
    addon.USE_BLIZZARD_POWERS = v
end

configLoaded.bossmod_enable = configChanged.bossmod_enable

configLoaded.show_quest_icon = configChanged.show_quest_icon
configLoaded.show_raid_icon = configChanged.show_raid_icon

-- init config #################################################################
local function UpdateProfile()
    core.profile = core.config:GetConfig()
    GLOBAL_SCALE = core.profile.global_scale

    -- initialise config locals in create.lua
    core:SetLocals()
end
function core:ConfigChanged(_,k,v)
    UpdateProfile()

    if k then
        -- call affected key's configChanged function
        if configChanged[k] then
            configChanged[k](v)
        end
    else
        -- profile changed;
        -- run all configChanged functions, skipping duplicates
        local called = {}
        for func_name,func in pairs(configChanged) do
            if not called[func] then
                called[func] = true
                func(core.profile[func_name])
            end
        end
    end

    if addon.debug and addon.debug_config then
        kui.print(self.config.profile)
    end

    for _,f in addon:Frames() do
        -- hide and re-show frames
        if f:IsShown() then
            local unit = f.unit
            f.handler:OnHide() -- (this clears f.unit)
            f.handler:OnUnitAdded(unit)
        end
    end
end
function core:InitialiseConfig()
    --luacheck:globals KuiNameplatesCoreSaved KuiNameplatesCoreConfig
    --@alpha@
    if not KuiNameplatesCoreSaved or not KuiNameplatesCoreSaved.SHUT_UP then
        addon:ui_print('Alpha version - Report issues to github.com/kesava-wow/kuinameplates2 and include the output of: /knp dump -- Thanks!')
    end
    --@end-alpha@

    if KuiNameplatesCoreSaved then
        -- XXX TEMP 2.27
        if not KuiNameplatesCoreSaved['226_AURAS_TRANSITION'] then
            -- rewrite old auras_cd/auras_count vars on all profiles where set
            local function upd(prefix,profile)
                local px = tonumber(profile[prefix..'_point_x'] or default_config[prefix..'_point_x'])
                local py = tonumber(profile[prefix..'_point_y'] or default_config[prefix..'_point_y'])
                profile[prefix..'_point'] = px * py
                profile[prefix..'_x'] = tonumber(profile[prefix..'_offset_x'])
                profile[prefix..'_y'] = tonumber(profile[prefix..'_offset_y'])
            end
            for _,profile in pairs(KuiNameplatesCoreSaved.profiles) do
                upd('auras_cd',profile)
                upd('auras_count',profile)
            end
        end
        if not KuiNameplatesCoreSaved['226_TARGET_SIZE'] then
            -- disable frame_target_size on extant profiles if
            -- frame_{width/height} is greater than the target size
            for _,profile in pairs(KuiNameplatesCoreSaved.profiles) do
                if (profile.frame_target_size or profile.frame_target_size == nil) and
                   ((profile.frame_width and profile.frame_width > (profile.frame_width_target or default_config.frame_width_target)) or
                   (profile.frame_height and profile.frame_height > (profile.frame_height_target or default_config.frame_height_target)))
                then
                    profile.frame_target_size = false
                end
            end
        end
        if not KuiNameplatesCoreSaved['226_CLASSPOWERS_Y'] then
            -- i did a quick-fix so now i have to do more work to undo it yay
            -- (on all profiles, if set, copy classpowers_y_personal to classpowers_y)
            for _,profile in pairs(KuiNameplatesCoreSaved.profiles) do
                local on_personal = profile.classpowers_on_target == false
                local y_personal = profile.classpowers_y_personal or default_config.classpowers_y_personal
                if on_personal and y_personal then
                    profile.classpowers_y = y_personal
                end
            end
        end
    end

    self.config = kc:Initialise('KuiNameplatesCore',default_config)
    self.config:RegisterConfigChanged(self,'ConfigChanged')
    UpdateProfile()

    -- XXX TEMP 2.27
    KuiNameplatesCoreSaved['226_AURAS_TRANSITION'] = true
    KuiNameplatesCoreSaved['226_TARGET_SIZE'] = true
    KuiNameplatesCoreSaved['226_CLASSPOWERS_Y'] = true

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
    if SettingsPanel then
        SettingsPanel:HookScript('OnHide',QueueClickboxUpdate)
    elseif InterfaceOptionsFrame then
        InterfaceOptionsFrame:HookScript('OnHide',QueueClickboxUpdate)
    end

    -- listen for LSM media updates
    LSM.RegisterCallback(self, 'LibSharedMedia_Registered', 'LSMMediaRegistered')
end
-- local event frame ###########################################################
-- combat function queue #######################################################
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
function cc:PLAYER_REGEN_ENABLED()
    -- pop queued functions
    for _,f_tbl in ipairs(self.queue) do
        if type(f_tbl[1]) == 'function' then
            f_tbl[1](unpack(f_tbl[2]))
        end
    end
    wipe(self.queue)
end
function cc:PLAYER_ENTERING_WORLD()
    self:PLAYER_REGEN_ENABLED()
end
-- cvar update #################################################################
function cc:EnableCVarUpdate()
    cc:RegisterEvent('CVAR_UPDATE')
    cc:RegisterEvent('PLAYER_ENTERING_WORLD')
end
function cc:DisableCVarUpdate()
    cc:UnregisterEvent('CVAR_UPDATE')
    cc:UnregisterEvent('PLAYER_ENTERING_WORLD')
end
function cc:CVAR_UPDATE()
    -- reapply our CVar changes
    if InCombatLockdown() then return end
    UpdateCVars()
end

cc:SetScript('OnEvent',function(self,event,...) self[event](self,...) end)
cc:RegisterEvent('PLAYER_REGEN_ENABLED')
