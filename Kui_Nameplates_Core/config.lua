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
-- add media to LSM ############################################################
LSM:Register(LSM.MediaType.FONT,'Yanone Kaffesatz Bold',kui.m.f.yanone)
LSM:Register(LSM.MediaType.FONT,'FrancoisOne',kui.m.f.francois)

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
    nameonly = true,
    nameonly_no_font_style = false,
    nameonly_damaged_friends = true,
    nameonly_enemies = true,
    glow_as_shadow = true,
    target_glow = true,
    target_glow_colour = { .3, .7, 1, 1 },

    fade_all = false,
    fade_alpha = .5,
    fade_speed = .5,
    fade_avoid_nameonly = true,
    fade_avoid_raidicon = true,

    font_face = DEFAULT_FONT,
    font_style = 2,
    hide_names = true,
    font_size_normal = 11,
    font_size_small = 9,
    level_text = false,
    health_text = false,
    text_vertical_offset = -1.5,
    name_vertical_offset = -2,
    bot_vertical_offset = -3,

    colour_hated = {.7,.2,.1},
    colour_neutral = {1,.8,0},
    colour_friendly = {.2,.6,.1},
    colour_tapped = {.5,.5,.5},
    colour_player = {.2,.5,.9},

    frame_width = 132,
    frame_height = 13,
    frame_width_minus = 72,
    frame_height_minus = 9,
    castbar_height = 5,

    auras_enabled = true,
    auras_whitelist = true,
    auras_pulsate = true,
    auras_time_threshold = 20,
    auras_minimum_length = 0,
    auras_maximum_length = -1,
    auras_icon_normal_size = 24,
    auras_icon_minus_size = 18,
    auras_icon_squareness = .7,

    castbar_enable = true,
    castbar_showpersonal = false,
    castbar_showall = true,
    castbar_showfriend = true,
    castbar_showenemy = true,

    tank_mode = true,
    tankmode_force_enable = false,
    threat_brackets = false,
    tankmode_tank_colour = { 0, 1, 0 },
    tankmode_trans_colour = { 1, 1, 0 },
    tankmode_other_colour = { .6, 0, 1 },
}
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

function configChanged.auras_enabled(v)
    if v then
        addon:GetPlugin('Auras'):Enable()
    else
        addon:GetPlugin('Auras'):Disable()
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

local function configChangedFadeRule(v,on_load)
    local plugin = addon:GetPlugin('Fading')

    if not on_load then
        -- don't reset on the configLoaded call
        plugin:ResetFadeRules()
    end

    if core.profile.fade_all then
        plugin:RemoveFadeRule(2)
    end

    if core.profile.fade_avoid_nameonly then
        plugin:AddFadeRule(function(f)
            return f.state.nameonly and 1
        end)
    end

    if core.profile.fade_avoid_raidicon then
        plugin:AddFadeRule(function(f)
            return f.RaidIcon:IsShown() and 1
        end)

        core:RegisterMessage('RaidIconUpdate')
    else
        core:UnregisterMessage('RaidIconUpdate')
    end
end
configChanged.fade_all = configChangedFadeRule
configChanged.fade_avoid_nameonly = configChangedFadeRule
configChanged.fade_avoid_raidicon = configChangedFadeRule

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
end
configChanged.colour_hated = configChangedReactionColour
configChanged.colour_neutral = configChangedReactionColour
configChanged.colour_friendly = configChangedReactionColour
configChanged.colour_tapped = configChangedReactionColour
configChanged.colour_player = configChangedReactionColour

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
configChanged.nameonly_no_font_style = configChangedFontOption

local function configChangedAuras()
    core:SetAurasConfig()
end
configChanged.auras_whitelist = configChangedAuras
configChanged.auras_pulsate = configChangedAuras
configChanged.auras_time_threshold = configChangedAuras
configChanged.auras_minimum_length = configChangedAuras
configChanged.auras_maximum_length = configChangedAuras
configChanged.auras_icon_normal_size = configChangedAuras
configChanged.auras_icon_minus_size = configChangedAuras
configChanged.auras_icon_squareness = configChangedAuras

-- config loaded functions #####################################################
local configLoaded = {}
configLoaded.fade_alpha = configChanged.fade_alpha
configLoaded.fade_speed = configChanged.fade_speed

configLoaded.colour_hated = configChangedReactionColour

configLoaded.tank_mode = configChanged.tank_mode
configLoaded.tankmode_force_enable = configChanged.tankmode_force_enable
configLoaded.castbar_enable = configChanged.castbar_enable
configLoaded.level_text = configChanged.level_text

configLoaded.auras_enabled = configChanged.auras_enabled
configLoaded.auras_whitelist = configChangedAuras

local function configLoadedFadeRule()
    configChangedFadeRule(nil,true)
end
configLoaded.fade_all = configLoadedFadeRule

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

        for i,f in addon:Frames() do
            -- hide and re-show frames
            if f:IsShown() then
                f.handler:OnHide()
                f.handler:OnUnitAdded(f.parent.namePlateUnitToken)
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
end
