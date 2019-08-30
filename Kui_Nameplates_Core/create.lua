--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- layout's element create/update functions
-- draw layers reference -------------------------------------------------------
-- HealthBar/CastBar ###########################################################
-- ARTWORK
-- powerbar spark = 7
-- raid icon (bar) = 6
-- target arrows = 4
-- state icon = 4
-- spell shield = 3
-- health bar highlight = 2
-- spell icon = 2
-- castbar spark = 1
-- absorb bar = 1
-- power bar = 0
-- health bar = 0
-- cast bar = 0
--
-- BACKGROUND
-- castbar background = 1
-- spell icon bg = 1
--
-- Frame #######################################################################
-- ARTWORK
-- raid icon (nameonly) = 1
--
-- BACKGROUND
-- healthbar fill background = 2
-- frame background = 1
-- threat brackets = 0
-- frame glow = -5
-- target glow = -5
--------------------------------------------------------------------------------
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local KSL = LibStub('KuiSpellList-2.0')
local core = KuiNameplatesCore --luacheck:globals KuiNameplatesCore

-- frame fading plugin - called by some update functions
local plugin_fading
-- class powers plugin - called by NameOnlyUpdateFunctions
local plugin_classpowers

-- common globals
local UnitIsPlayer,UnitShouldDisplayName,
      strlen,format,pairs,ipairs,floor,ceil,unpack =
      UnitIsPlayer,UnitShouldDisplayName,
      strlen,format,pairs,ipairs,floor,ceil,unpack

-- config locals
local KUI_MEDIA = 'interface/addons/kui_media/'
local MEDIA = 'interface/addons/kui_nameplates_core/media/'

-- global enum tables (XXX used by auras only at the moment)
local POINT_X_ASSOC = { 'LEFT', 'CENTER', 'RIGHT' }
local POINT_Y_ASSOC = { 'TOP', 'CENTER', 'BOTTOM' }

local FRAME_WIDTH,FRAME_HEIGHT,FRAME_WIDTH_MINUS,FRAME_HEIGHT_MINUS,
      FRAME_WIDTH_PERSONAL,FRAME_HEIGHT_PERSONAL,POWER_BAR_HEIGHT,
      FONT,FONT_STYLE,FONT_SHADOW,FONT_SIZE_NORMAL,
      FONT_SIZE_SMALL,NAME_VERTICAL_OFFSET,
      BOT_VERTICAL_OFFSET,BAR_TEXTURE,BAR_ANIMATION,
      SHOW_HEALTH_TEXT,SHOW_NAME_TEXT,SHOW_ARENA_ID,GUILD_TEXT_NPCS,
      GUILD_TEXT_PLAYERS,TITLE_TEXT_PLAYERS,HEALTH_TEXT_FRIEND_MAX,
      HEALTH_TEXT_FRIEND_DMG,HEALTH_TEXT_HOSTILE_MAX,HEALTH_TEXT_HOSTILE_DMG,
      HIDE_NAMES,GLOBAL_SCALE,FRAME_VERTICAL_OFFSET,
      MOUSEOVER_HIGHLIGHT,HIGHLIGHT_OPACITY

local FADE_UNTRACKED,FADE_AVOID_NAMEONLY,FADE_AVOID_MOUSEOVER,
      FADE_AVOID_TRACKED,FADE_AVOID_COMBAT,FADE_AVOID_CASTING
local TARGET_ARROWS,TARGET_ARROWS_SIZE,TARGET_ARROWS_INSET
local TARGET_GLOW,TARGET_GLOW_COLOUR,FRAME_GLOW_THREAT,FRAME_GLOW_SIZE,
      GLOW_AS_SHADOW,MOUSEOVER_GLOW,MOUSEOVER_GLOW_COLOUR
local THREAT_BRACKETS,THREAT_BRACKETS_SIZE
local CASTBAR_DETACH

-- helper functions ############################################################
local CreateStatusBar
do
    local function FadeSpark(bar)
        local val,max = bar:GetValue(),select(2,bar:GetMinMaxValues())
        local show_val = (max / 100) * 80

        if val == 0 or val == max then
            bar.spark:Hide()
        elseif val < show_val then
            bar.spark:SetAlpha(1)
            bar.spark:Show()
        else
            bar.spark:SetAlpha(1 - ((val - show_val) / (max - show_val)))
            bar.spark:Show()
        end
    end

    local function FilledBar_SetStatusBarColor(self,r,g,b,a)
        self:orig_SetStatusBarColor(r,g,b,a)

        if self.fill then
            self.fill:SetVertexColor(r,g,b)
        end

        if self.spark then
            self.spark:SetVertexColor(kui.Brighten(.3,r,g,b,a))
        end
    end
    local function FilledBar_Show(self)
        self:orig_Show()
        self.fill:Show()
    end
    local function FilledBar_Hide(self)
        self:orig_Hide()
        self.fill:Hide()
    end

    function CreateStatusBar(parent,spark,no_fill,no_fade_spark,spark_level)
        local bar = CreateFrame('StatusBar',nil,parent)
        bar:SetStatusBarTexture(BAR_TEXTURE)
        bar:SetFrameLevel(0)

        if not no_fill then
            local fill = bar:CreateTexture(nil,'BACKGROUND',nil,2)
            fill:SetTexture(BAR_TEXTURE)
            fill:SetAllPoints(bar)
            fill:SetAlpha(.2)

            bar.fill = fill

            bar.orig_Show = bar.Show
            bar.Show = FilledBar_Show

            bar.orig_Hide = bar.Hide
            bar.Hide = FilledBar_Hide
        end

        if spark then
            local texture = bar:GetStatusBarTexture()
            spark = bar:CreateTexture(nil,'ARTWORK',nil,spark_level or 7)
            spark:SetTexture(KUI_MEDIA..'t/spark')
            spark:SetWidth(12)

            spark:SetPoint('TOP',texture,'TOPRIGHT',-1,4)
            spark:SetPoint('BOTTOM',texture,'BOTTOMRIGHT',-1,-4)

            bar.spark = spark

            if not no_fade_spark then
                bar:HookScript('OnValueChanged',FadeSpark)
                bar:HookScript('OnMinMaxChanged',FadeSpark)
            end
        end

        if not no_fill or spark then
            bar.orig_SetStatusBarColor = bar.SetStatusBarColor
            bar.SetStatusBarColor = FilledBar_SetStatusBarColor
        end

        return bar
    end
end
local function UpdateFontObject(object)
    if not object then return end
    object:SetFont(
        FONT,
        object.fontobject_size or (object.fontobject_small and
         FONT_SIZE_SMALL or FONT_SIZE_NORMAL),
        not object.fontobject_no_style and FONT_STYLE or nil
    )

    if object.fontobject_shadow or FONT_SHADOW then
        object:SetShadowColor(0,0,0,1)
        object:SetShadowOffset(1,-1)
    else
        object:SetShadowColor(0,0,0,0)
    end
end
local function CreateFontString(parent,small)
    local f = parent:CreateFontString(nil,'OVERLAY')
    f.fontobject_small = small
    f:SetWordWrap()

    UpdateFontObject(f)

    return f
end
local function Scale(v)
    if not GLOBAL_SCALE or GLOBAL_SCALE == 1 then return v end
    return floor((v*GLOBAL_SCALE)+.5)
end
local function ScaleTextOffset(v)
    return floor(Scale(v)) - .5
end
local function ResolvePointPair(x,y)
    -- convert x/y to single point
    if x == 2 and y == 2 then
        return 'CENTER'
    elseif x == 2 then
        return POINT_Y_ASSOC[y]
    elseif y == 2 then
        return POINT_X_ASSOC[x]
    else
        return POINT_Y_ASSOC[y]..POINT_X_ASSOC[x]
    end
end
-- config functions ############################################################
do
    local FONT_STYLE_ASSOC = {
        '',
        'THINOUTLINE',
        '',
        'THINOUTLINE',
        'THINOUTLINE MONOCHROME'
    }
    local ANIM_ASSOC = {
        nil,'smooth','cutaway'
    }
    local function UpdateMediaLocals()
        BAR_TEXTURE = LSM:Fetch(LSM.MediaType.STATUSBAR,core.profile.bar_texture)
        FONT = LSM:Fetch(LSM.MediaType.FONT,core.profile.font_face)
    end
    function core:SetLocals()
        -- set config locals to reduce table lookup
        UpdateMediaLocals()

        GLOBAL_SCALE = self.profile.global_scale
        BAR_ANIMATION = ANIM_ASSOC[self.profile.bar_animation]

        TARGET_ARROWS = self.profile.target_arrows
        TARGET_ARROWS_SIZE = Scale(self.profile.target_arrows_size)
        TARGET_ARROWS_INSET = Scale(self.profile.target_arrows_inset)
        TARGET_GLOW = self.profile.target_glow
        TARGET_GLOW_COLOUR = self.profile.target_glow_colour
        MOUSEOVER_GLOW = self.profile.mouseover_glow
        MOUSEOVER_GLOW_COLOUR = self.profile.mouseover_glow_colour
        MOUSEOVER_HIGHLIGHT = self.profile.mouseover_highlight
        HIGHLIGHT_OPACITY = self.profile.mouseover_highlight_opacity
        GLOW_AS_SHADOW = self.profile.glow_as_shadow

        THREAT_BRACKETS = self.profile.threat_brackets
        THREAT_BRACKETS_SIZE = Scale(self.profile.threat_brackets_size)

        FRAME_WIDTH = Scale(self.profile.frame_width)
        FRAME_HEIGHT = Scale(self.profile.frame_height)
        FRAME_WIDTH_MINUS = Scale(self.profile.frame_width_minus)
        FRAME_HEIGHT_MINUS = Scale(self.profile.frame_height_minus)
        FRAME_WIDTH_PERSONAL = Scale(self.profile.frame_width_personal)
        FRAME_HEIGHT_PERSONAL = Scale(self.profile.frame_height_personal)
        POWER_BAR_HEIGHT = Scale(self.profile.powerbar_height)
        FRAME_VERTICAL_OFFSET = self.profile.frame_vertical_offset

        FRAME_GLOW_SIZE = Scale(self.profile.frame_glow_size)
        FRAME_GLOW_THREAT = self.profile.frame_glow_threat

        NAME_VERTICAL_OFFSET = ScaleTextOffset(self.profile.name_vertical_offset)
        BOT_VERTICAL_OFFSET = ScaleTextOffset(self.profile.bot_vertical_offset)

        FONT_STYLE = FONT_STYLE_ASSOC[self.profile.font_style]
        FONT_SHADOW = self.profile.font_style == 3 or self.profile.font_style == 4
        FONT_SIZE_NORMAL = Scale(self.profile.font_size_normal)
        FONT_SIZE_SMALL = Scale(self.profile.font_size_small)

        FADE_UNTRACKED = self.profile.fade_untracked
        FADE_AVOID_NAMEONLY = self.profile.fade_avoid_nameonly
        FADE_AVOID_MOUSEOVER = self.profile.fade_avoid_mouseover
        FADE_AVOID_TRACKED = self.profile.fade_avoid_tracked
        FADE_AVOID_COMBAT = self.profile.fade_avoid_combat
        FADE_AVOID_CASTING =
            (self.profile.fade_avoid_casting_friendly
            or self.profile.fade_avoid_casting_hostile) and
            (self.profile.fade_avoid_casting_interruptible or
            self.profile.fade_avoid_casting_uninterruptible)

        SHOW_HEALTH_TEXT = self.profile.health_text
        SHOW_NAME_TEXT = self.profile.name_text
        SHOW_ARENA_ID = self.profile.show_arena_id
        HIDE_NAMES = self.profile.hide_names
        HEALTH_TEXT_FRIEND_MAX = self.profile.health_text_friend_max
        HEALTH_TEXT_FRIEND_DMG = self.profile.health_text_friend_dmg
        HEALTH_TEXT_HOSTILE_MAX = self.profile.health_text_hostile_max
        HEALTH_TEXT_HOSTILE_DMG = self.profile.health_text_hostile_dmg

        GUILD_TEXT_NPCS = self.profile.guild_text_npcs
        GUILD_TEXT_PLAYERS = self.profile.guild_text_players
        TITLE_TEXT_PLAYERS = self.profile.title_text_players

        CASTBAR_DETACH = self.profile.castbar_detach
    end
    function core:LSMMediaRegistered(_,mediatype,key)
        -- callback registered in config.lua:InitialiseConfig
        if mediatype == LSM.MediaType.STATUSBAR and key == self.profile.bar_texture or
           mediatype == LSM.MediaType.FONT and key == self.profile.font_face
        then
            UpdateMediaLocals()
        end
    end
end
function core:configChangedTargetArrows()
    if not TARGET_ARROWS then return end
    for _,f in addon:Frames() do
        if not f.TargetArrows then
            self:CreateTargetArrows(f)
        end
    end
end
function core:configChangedFrameSize()
    for _,f in addon:Frames() do
        if f.Auras and f.Auras.frames then
            -- force auras frame size + position update
            if f.Auras.frames.core_dynamic then
                f.Auras.frames.core_dynamic.__width = nil
            end
            if f.Auras.frames.core_purge then
                f.Auras.frames.core_purge.__width = nil
            end
        end
    end
end
function core:configChangedTextOffset()
    for _,f in addon:Frames() do
        f:UpdateNameTextPosition()
        f:UpdateSpellNamePosition()

        if f.Auras and f.Auras.frames then
            -- update aura text
            for _,frame in pairs(f.Auras.frames) do
                for _,button in ipairs(frame.buttons) do
                    self.Auras_PostCreateAuraButton(frame,button)
                end
            end
        end
    end
end
function core:configChangedFontOption()
    -- update font objects
    for _,f in addon:Frames() do
        UpdateFontObject(f.NameText)
        UpdateFontObject(f.GuildText)
        UpdateFontObject(f.SpellName)
        UpdateFontObject(f.HealthText)
        UpdateFontObject(f.LevelText)

        if f.Auras and f.Auras.frames then
            for _,frame in pairs(f.Auras.frames) do
                for _,button in ipairs(frame.buttons) do
                    self.AurasButton_SetFont(button)
                end
            end
        end
    end
end
do
    local function UpdateStatusBar(object)
        if not object then return end
        if object.SetStatusBarTexture then
            object:SetStatusBarTexture(BAR_TEXTURE)
            UpdateStatusBar(object.fill)
        elseif object.SetTexture then
            object:SetTexture(BAR_TEXTURE)
        end
    end
    function core:configChangedBarTexture()
        for _,f in addon:Frames() do
            UpdateStatusBar(f.CastBar)
            UpdateStatusBar(f.Highlight)
            UpdateStatusBar(f.HealthBar)
            UpdateStatusBar(f.PowerBar)

            if f.UpdateAbsorbBar then
                f:UpdateAbsorbBar()
            end
        end

        if addon.ClassPowersFrame then
            UpdateStatusBar(addon.ClassPowersFrame.bar)
            self.ClassPowers.bar_texture = BAR_TEXTURE
        end
    end
end
function core:SetBarAnimation()
    for _,f in addon:Frames() do
        f.handler:SetBarAnimation(f.HealthBar,BAR_ANIMATION)
        f.handler:SetBarAnimation(f.PowerBar,BAR_ANIMATION)

        if BAR_ANIMATION == 'smooth' then
            f.handler:SetBarAnimation(f.AbsorbBar,BAR_ANIMATION)
        else
            f.handler:SetBarAnimation(f.AbsorbBar,nil)
        end
    end
end
-- #############################################################################
-- create/update functions #####################################################
-- frame background ############################################################
local function UpdateFrameSize(f)
    -- set frame size and position
    if f.state.minus then
        f:SetSize(FRAME_WIDTH_MINUS,FRAME_HEIGHT_MINUS)
    elseif f.state.personal then
        f:SetSize(FRAME_WIDTH_PERSONAL,FRAME_HEIGHT_PERSONAL)
    else
        f:SetSize(FRAME_WIDTH,FRAME_HEIGHT)
    end

    if f.state.no_name and not f.state.personal then
        f:SetHeight(FRAME_HEIGHT_MINUS)
    end

    f:SetPoint('CENTER',0,FRAME_VERTICAL_OFFSET)

    f:UpdateMainBars()
    f:SpellIconSetWidth()
    f:UpdateAuras()
end
function core:CreateBackground(f)
    local bg = f:CreateTexture(nil,'BACKGROUND',nil,1)
    bg:SetTexture(kui.m.t.solid)
    bg:SetVertexColor(0,0,0,.9)
    bg:SetAllPoints(f)

    -- in UpdateFrameSize,
    -- we override the frame position + size to use it as the background
    f:ClearAllPoints()

    f.bg = bg
    f.UpdateFrameSize = UpdateFrameSize
end
-- highlight ###################################################################
do
    local function UpdateHighlight(f)
        if MOUSEOVER_HIGHLIGHT then
            if not f.Highlight then
                core:CreateHighlight(f)
            end

            f.Highlight:SetVertexColor(1,1,1,HIGHLIGHT_OPACITY)
            f.handler:EnableElement('Highlight')
        elseif f.Highlight and f.elements.Highlight then
            f.handler:DisableElement('Highlight')
        end

        -- functions which depend on f.state.glow from Highlight
        -- (which is set regardless of the element being enabled)
        if MOUSEOVER_GLOW then
            f:UpdateFrameGlow()
        end
        if FADE_AVOID_MOUSEOVER then
            plugin_fading:UpdateFrame(f)
        end
    end
    function core:CreateHighlight(f)
        f.UpdateHighlight = UpdateHighlight

        if not MOUSEOVER_HIGHLIGHT then return end

        local highlight = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,2)
        highlight:SetTexture(BAR_TEXTURE)
        highlight:SetAllPoints(f.HealthBar)
        highlight:SetBlendMode('ADD')
        highlight:Hide()

        f.handler:RegisterElement('Highlight',highlight)
    end
end
-- health bar ##################################################################
do
    local function UpdateMainBars(f)
        -- update health/power bar size
        local hb_height = f.bg:GetHeight()-2

        if f.PowerBar:IsShown() then
            local pb_height = POWER_BAR_HEIGHT

            if pb_height >= (hb_height-1) then
                -- reduce height so that healthbar is at least 1 pixel
                pb_height = hb_height - 2
            end

            hb_height = (hb_height-pb_height)-1
            f.PowerBar:SetHeight(pb_height)
        end

        f.HealthBar:SetHeight(hb_height)
    end
    function core:CreateHealthBar(f)
        local healthbar = CreateStatusBar(f)

        healthbar:SetPoint('TOPLEFT',f.bg,1,-1)
        healthbar:SetPoint('RIGHT',f.bg,-1,0)

        f.handler:SetBarAnimation(healthbar,BAR_ANIMATION)
        f.handler:RegisterElement('HealthBar',healthbar)

        f.UpdateMainBars = UpdateMainBars
    end
end
-- power bar ###################################################################
do
    local function UpdatePowerBar(f,on_show)
        if  f.state.personal and
            f.state.power_type
            and UnitPowerMax(f.unit,f.state.power_type) > 0
        then
            f.handler:EnableElement('PowerBar')
        else
            f.handler:DisableElement('PowerBar')
        end

        if not on_show then
            -- update health bar height
            f:UpdateMainBars()
        end
    end
    function core:CreatePowerBar(f)
        local powerbar = CreateStatusBar(f.HealthBar,true)
        powerbar:SetPoint('TOPLEFT',f.HealthBar,'BOTTOMLEFT',0,-1)
        powerbar:SetPoint('RIGHT',f.bg,-1,0)

        f.handler:SetBarAnimation(powerbar,BAR_ANIMATION)
        f.handler:RegisterElement('PowerBar',powerbar)

        f.UpdatePowerBar = UpdatePowerBar
    end
end
-- absorb bar ##################################################################
do
    local ABSORB_ENABLE,ABSORB_STRIPED,ABSORB_COLOUR

    function core:configChangedAbsorb()
        ABSORB_ENABLE = not kui.CLASSIC and self.profile.absorb_enable
        ABSORB_STRIPED = self.profile.absorb_striped
        ABSORB_COLOUR = self.profile.colour_absorb

        if ABSORB_ENABLE then
            for _,f in addon:Frames() do
                if not f.AbsorbBar then
                    self:CreateAbsorbBar(f)
                else
                    f:UpdateAbsorbBar()
                end
            end
        end
    end

    local function UpdateAbsorbBar(f)
        if not ABSORB_ENABLE then return end
        if ABSORB_STRIPED then
            f.AbsorbBar.t:SetTexture(kui.m.t.stripebar,true,true)
            f.AbsorbBar.t:SetHorizTile(true)
            f.AbsorbBar.t:SetVertTile(true)
        else
            f.AbsorbBar.t:SetTexture(BAR_TEXTURE,false,false)
            f.AbsorbBar.t:SetHorizTile(false)
            f.AbsorbBar.t:SetVertTile(false)
        end

        f.AbsorbBar.t:SetDrawLayer('ARTWORK',1)
        f.AbsorbBar:SetStatusBarColor(unpack(ABSORB_COLOUR))
        f.AbsorbBar.spark:SetVertexColor(unpack(ABSORB_COLOUR))
        f.AbsorbBar.spark:SetAlpha(1)
    end
    function core:CreateAbsorbBar(f)
        if not ABSORB_ENABLE then return end

        local bar = CreateStatusBar(f.HealthBar,nil,true)
        bar:SetAllPoints(f.HealthBar)

        bar.t = bar:CreateTexture(nil,'ARTWORK')
        bar:SetStatusBarTexture(bar.t)

        -- spark for over-absorb highlighting
        local spark = bar:CreateTexture(nil,'ARTWORK',nil,7)
        spark:SetTexture(KUI_MEDIA..'t/spark')
        spark:SetWidth(12)
        spark:SetPoint('TOP',bar,'TOPRIGHT',-1,4)
        spark:SetPoint('BOTTOM',bar,'BOTTOMRIGHT',-1,-4)
        bar.spark = spark

        if BAR_ANIMATION == 'smooth' then
            -- updated by core.SetBarAnimation (XXX twice?)
            f.handler:SetBarAnimation(bar,BAR_ANIMATION)
        end

        f.handler:RegisterElement('AbsorbBar',bar)
        f.UpdateAbsorbBar = UpdateAbsorbBar
        f:UpdateAbsorbBar()
    end
end
-- name text ###################################################################
do
    local NAME_COLOUR_WHITE_IN_BAR_MODE,CLASS_COLOUR_FRIENDLY_NAMES,
          CLASS_COLOUR_ENEMY_NAMES,NAME_COLOUR_BRIGHTEN_CLASS,
          NAME_COLOUR_PLAYER_FRIENDLY,NAME_COLOUR_PLAYER_HOSTILE,
          NAME_COLOUR_NPC_FRIENDLY,NAME_COLOUR_NPC_NEUTRAL,
          NAME_COLOUR_NPC_HOSTILE

    -- adjusted class colours, built as needed
    local CLASS_COLOURS

    function core:configChangedNameColour()
        CLASS_COLOURS = nil
        NAME_COLOUR_WHITE_IN_BAR_MODE = self.profile.name_colour_white_in_bar_mode
        CLASS_COLOUR_FRIENDLY_NAMES = self.profile.class_colour_friendly_names
        CLASS_COLOUR_ENEMY_NAMES = self.profile.class_colour_enemy_names
        NAME_COLOUR_BRIGHTEN_CLASS = self.profile.name_colour_brighten_class
        NAME_COLOUR_PLAYER_FRIENDLY = self.profile.name_colour_player_friendly
        NAME_COLOUR_PLAYER_HOSTILE = self.profile.name_colour_player_hostile
        NAME_COLOUR_NPC_FRIENDLY = self.profile.name_colour_npc_friendly
        NAME_COLOUR_NPC_NEUTRAL = self.profile.name_colour_npc_neutral
        NAME_COLOUR_NPC_HOSTILE = self.profile.name_colour_npc_hostile
    end

    local function GetClassColour(f)
        -- return adjusted class colour
        if not f.state.class then return end
        if not CLASS_COLOURS then CLASS_COLOURS = {} end
        if not CLASS_COLOURS[f.state.class] then
            if NAME_COLOUR_BRIGHTEN_CLASS then
                CLASS_COLOURS[f.state.class] = { kui.Brighten(NAME_COLOUR_BRIGHTEN_CLASS,kui.GetClassColour(f.state.class,2)) }
            else
                CLASS_COLOURS[f.state.class] = { kui.GetClassColour(f.state.class,2) }
            end
        end
        return unpack(CLASS_COLOURS[f.state.class])
    end
    local function SetNameTextColour(f)
        -- override colour based on config
        -- white by default
        f.NameText:SetTextColor(1,1,1,1)
        f.GuildText:SetTextColor(1,1,1,.8)

        if f.state.personal then
            -- self (name & guild text always hidden)
            return
        elseif UnitIsPlayer(f.unit) then
            -- other players
            if f.state.friend then
                if CLASS_COLOUR_FRIENDLY_NAMES then
                    -- use adjusted class colour
                    f.NameText:SetTextColor(GetClassColour(f))
                elseif NAME_COLOUR_WHITE_IN_BAR_MODE and not f.IN_NAMEONLY then
                    -- white in bar mode
                    return
                else
                    -- use configured friendly player colour
                    f.NameText:SetTextColor(unpack(NAME_COLOUR_PLAYER_FRIENDLY))
                end
            elseif CLASS_COLOUR_ENEMY_NAMES then
                f.NameText:SetTextColor(GetClassColour(f))
            elseif NAME_COLOUR_WHITE_IN_BAR_MODE and not f.IN_NAMEONLY then
                return
            else
                f.NameText:SetTextColor(unpack(NAME_COLOUR_PLAYER_HOSTILE))
            end
        elseif NAME_COLOUR_WHITE_IN_BAR_MODE and not f.IN_NAMEONLY then
            return
        else
            -- NPCs; reaction colour
            if not f.state.attackable and f.state.reaction >= 4 then
                -- friendly
                f.NameText:SetTextColor(unpack(NAME_COLOUR_NPC_FRIENDLY))
            else
                if f.state.reaction == 4 then
                    -- neutral, attackable
                    f.NameText:SetTextColor(unpack(NAME_COLOUR_NPC_NEUTRAL))
                else
                    -- hostile
                    f.NameText:SetTextColor(unpack(NAME_COLOUR_NPC_HOSTILE))
                end
            end
        end

        f.GuildText:SetTextColor(kui.Brighten(.8,f.NameText:GetTextColor()))
        f.GuildText:SetAlpha(.8)
    end

    local function UpdateNameText(f)
        if f.IN_NAMEONLY then
            if TITLE_TEXT_PLAYERS then
                -- override name with title
                f.state.name = UnitPVPName(f.unit) or UnitName(f.unit)
                f.NameText:SetText(f.state.name)
            end

            f.NameText:Show()
            SetNameTextColour(f)

            -- update name text colour to with health percent
            core:NameOnlySetNameTextToHealth(f)
        elseif SHOW_NAME_TEXT or SHOW_ARENA_ID then
            if SHOW_NAME_TEXT and TITLE_TEXT_PLAYERS then
                -- reset name to title-less
                f.handler:UpdateName()
            end
            if f.state.no_name then
                f.NameText:Hide()
            else
                if SHOW_ARENA_ID and f.state.arenaid then
                    if SHOW_NAME_TEXT then
                        f.NameText:SetText('|cffffffff'..f.state.arenaid..'|r '..f.state.name)
                    else
                        f.NameText:SetText('|cffffffff'..f.state.arenaid..'|r')
                    end
                end
                f.NameText:Show()
                SetNameTextColour(f)
            end
        else
            f.NameText:Hide()
        end
    end
    local function UpdateNameTextPosition(f)
        f.NameText:SetPoint('BOTTOM',f.HealthBar,'TOP',0,NAME_VERTICAL_OFFSET)
    end
    function core:CreateNameText(f)
        local nametext = CreateFontString(f)
        f.handler:RegisterElement('NameText',nametext)

        f.UpdateNameTextPosition = UpdateNameTextPosition
        f.UpdateNameText = UpdateNameText

        f:UpdateNameTextPosition()
    end
end
-- level text ##################################################################
do
    local function UpdateLevelText(f)
        if f.IN_NAMEONLY then return end
        if not core.profile.level_text or f.state.minus or f.state.personal then
            f.LevelText:Hide()
        else
            f.LevelText:ClearAllPoints()

            if f.state.no_name then
                f.LevelText:SetPoint('LEFT',2,0)
            else
                f.LevelText:SetPoint('BOTTOMLEFT',2,BOT_VERTICAL_OFFSET)
            end

            f.LevelText:Show()
        end
    end
    function core:CreateLevelText(f)
        local leveltext = CreateFontString(f.HealthBar)

        f.handler:RegisterElement('LevelText',leveltext)

        f.UpdateLevelText = UpdateLevelText
    end
end
-- health text #################################################################
do
    local function HealthDisplay_Percent(s)
        local v = s.health_per
        if v < 1 then
            return format('%.1f',v)
        else
            return ceil(v)
        end
    end
    local health_display_funcs = {
        function() return '' end,
        function(s) return kui.num(s.health_cur) end,
        function(s) return kui.num(s.health_max) end,
        HealthDisplay_Percent,
        function(s) return '-'..kui.num(s.health_deficit) end,
        function(s) return kui.num(s.health_cur)..'  '..HealthDisplay_Percent(s)..'%' end,
        function(s) return kui.num(s.health_cur)..'  -'..kui.num(s.health_deficit) end,
    }
    local function GetHealthDisplay(f,key)
        return type(key) == 'number' and
            health_display_funcs[key] and
            health_display_funcs[key](f.state) or
            ''
    end

    local function UpdateHealthText(f)
        if f.IN_NAMEONLY then return end
        if not SHOW_HEALTH_TEXT or f.state.minus or f.state.personal then
            f.HealthText:Hide()
        else
            local disp

            if f.state.friend then
                if f.state.health_cur ~= f.state.health_max then
                    disp = GetHealthDisplay(f,HEALTH_TEXT_FRIEND_DMG)
                else
                    disp = GetHealthDisplay(f,HEALTH_TEXT_FRIEND_MAX)
                end
            else
                if f.state.health_cur ~= f.state.health_max then
                    disp = GetHealthDisplay(f,HEALTH_TEXT_HOSTILE_DMG)
                else
                    disp = GetHealthDisplay(f,HEALTH_TEXT_HOSTILE_MAX)
                end
            end

            f.HealthText:SetText(disp)
            f.HealthText:ClearAllPoints()

            if f.state.no_name then
                f.HealthText:SetPoint('RIGHT',-2,0)
            else
                f.HealthText:SetPoint('BOTTOMRIGHT',-2,BOT_VERTICAL_OFFSET)
            end

            f.HealthText:Show()
        end
    end
    function core:CreateHealthText(f)
        local healthtext = CreateFontString(f.HealthBar)

        f.HealthText = healthtext
        f.UpdateHealthText = UpdateHealthText
    end
end
-- npc guild text ##############################################################
do
    local function UpdateGuildText(f)
        if not f.IN_NAMEONLY or not f.state.guild_text or
           (not GUILD_TEXT_PLAYERS and UnitIsPlayer(f.unit)) or
           (not GUILD_TEXT_NPCS and not UnitIsPlayer(f.unit))
        then
            f.GuildText:Hide()
        else
            f.GuildText:SetText(f.state.guild_text)
            f.GuildText:Show()

            -- shift name text up in nameonly mode
            f.NameText:SetPoint('CENTER',.5,6)
        end
    end
    function core:CreateGuildText(f)
        local guildtext = CreateFontString(f,FONT_SIZE_SMALL)
        guildtext:SetPoint('TOP',f.NameText,'BOTTOM', 0, -2)
        guildtext:SetShadowOffset(1,-1)
        guildtext:SetShadowColor(0,0,0,1)
        guildtext:Hide()

        f.GuildText = guildtext
        f.UpdateGuildText = UpdateGuildText
    end
end
-- frame glow ##################################################################
do
    local GLOW_POINTS = {
        { 'BOTTOMRIGHT', 'TOPLEFT', 1, -1 },
        { { 'BOTTOMLEFT', 'TOPLEFT', 1, -1 },
          { 'BOTTOMRIGHT', 'TOPRIGHT', -1, -1 }
        },
        { 'BOTTOMLEFT', 'TOPRIGHT', -1, -1 },
        { { 'TOPLEFT', 'TOPRIGHT', -1, -1 },
          { 'BOTTOMLEFT', 'BOTTOMRIGHT', -1, 1 }
        },
        { 'TOPLEFT', 'BOTTOMRIGHT', -1, 1 },
        { { 'TOPRIGHT', 'BOTTOMRIGHT', -1, 1 },
          { 'TOPLEFT', 'BOTTOMLEFT', 1, 1 }
        },
        { 'TOPRIGHT', 'BOTTOMLEFT', 1, 1 },
        { { 'BOTTOMRIGHT', 'BOTTOMLEFT', 1, 1 },
          { 'TOPRIGHT', 'TOPLEFT', 1, -1 }
        }
    }
    local GLOW_TEXTURE_COORDS = {
        { 0, .5, 0, .5 }, -- top left
        { .5, 1, 0, .5 }, -- top
        { .5, 0, 0, .5 }, -- top right
        { .5, 0, .5, 1 }, -- right
        { .5, 0, .5, 0 }, -- bottom right
        { .5, 1, .5, 0 }, -- bottom
        { 0, .5, .5, 0 }, -- bottom left
        { 0, .5, .5, 1 }, -- left
    }

    -- frame glow prototype
    local glow_prototype = {}
    glow_prototype.__index = glow_prototype
    function glow_prototype:SetVertexColor(...)
        for _,side in ipairs(self.sides) do
            local r,g,b,a = ...
            a = (a or 1) * .6
            side:SetVertexColor(r,g,b,a)
        end
    end
    function glow_prototype:Show()
        for _,side in ipairs(self.sides) do
            side:Show()
        end
    end
    function glow_prototype:Hide()
        for _,side in ipairs(self.sides) do
            side:Hide()
        end
    end
    function glow_prototype:SetSize(size)
        if not tonumber(size) then return end
        for _,side in ipairs(self.sides) do
            side:SetSize(size,size)
        end
    end
    function glow_prototype:SetAlpha(...)
        for _,side in ipairs(self.sides) do
            side:SetAlpha(...)
        end
    end

    -- update
    local function UpdateFrameGlow(f)
        -- update colour of ThreatGlow or NameOnlyGlow
        if f.IN_NAMEONLY then
            f.ThreatGlow:Hide()
            f.TargetGlow:Hide()

            if f.NameOnlyGlow then
                if TARGET_GLOW and f.state.target then
                    f.NameOnlyGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
                    f.NameOnlyGlow:Show()
                elseif MOUSEOVER_GLOW and f.state.highlight then
                    f.NameOnlyGlow:SetVertexColor(unpack(MOUSEOVER_GLOW_COLOUR))
                    f.NameOnlyGlow:Show()
                elseif FRAME_GLOW_THREAT and f.state.glowing then
                    f.NameOnlyGlow:SetVertexColor(unpack(f.state.glow_colour))
                    f.NameOnlyGlow:SetAlpha(.6)
                    f.NameOnlyGlow:Show()
                else
                    f.NameOnlyGlow:Hide()
                end
            end
        else
            f.ThreatGlow:Show()

            if f.NameOnlyGlow then
                f.NameOnlyGlow:Hide()
            end

            if TARGET_GLOW and f.state.target then
                -- target glow colour
                f.ThreatGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
                f.TargetGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
                f.TargetGlow:Show()
            elseif MOUSEOVER_GLOW and f.state.highlight then
                -- mouseover glow
                f.ThreatGlow:SetVertexColor(unpack(MOUSEOVER_GLOW_COLOUR))
                f.TargetGlow:SetVertexColor(unpack(MOUSEOVER_GLOW_COLOUR))
                f.TargetGlow:Show()
            else
                f.TargetGlow:Hide()

                if FRAME_GLOW_THREAT and f.state.glowing then
                    -- threat glow colour
                    f.ThreatGlow:SetVertexColor(unpack(f.state.glow_colour))
                else
                    if GLOW_AS_SHADOW then
                        -- shadow
                        f.ThreatGlow:SetVertexColor(0,0,0,.3)
                    else
                        f.ThreatGlow:SetVertexColor(0,0,0,0)
                    end
                end
            end
        end
    end
    local function UpdateFrameGlowSize(f)
        if not f.ThreatGlow then return end
        f.ThreatGlow:SetSize(FRAME_GLOW_SIZE)
        f.TargetGlow:SetHeight(FRAME_GLOW_SIZE)
    end
    function core:CreateFrameGlow(f)
        local glow = { sides = {} }
        setmetatable(glow,glow_prototype)

        for i=1,8 do
            local side = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            side:SetTexture(KUI_MEDIA..'t/shadowBorder')

            side:SetTexCoord(unpack(GLOW_TEXTURE_COORDS[i]))

            local point = GLOW_POINTS[i]

            if type(point[1]) == 'table' then
                -- flat side
                side:SetPoint(point[1][1],f.bg,point[1][2],point[1][3],point[1][4])
                side:SetPoint(point[2][1],f.bg,point[2][2],point[2][3],point[2][4])
            else
                -- corner
                side:SetPoint(point[1],f.bg,point[2],point[3],point[4])
            end

            tinsert(glow.sides,side)
        end

        glow:SetSize(FRAME_GLOW_SIZE)
        f.handler:RegisterElement('ThreatGlow',glow)

        local target_glow = f:CreateTexture(nil,'BACKGROUND',nil,-5)
        target_glow:SetTexture(MEDIA..'target-glow')
        target_glow:SetPoint('TOPLEFT',f.bg,'BOTTOMLEFT')
        target_glow:SetPoint('TOPRIGHT',f.bg,'BOTTOMRIGHT')
        f.TargetGlow = target_glow

        f.UpdateFrameGlow = UpdateFrameGlow
        f.UpdateFrameGlowSize = UpdateFrameGlowSize
        f:UpdateFrameGlowSize()
    end
end
-- target arrows ###############################################################
do
    local function Arrows_Hide(self)
        self.l:Hide()
        self.r:Hide()
    end
    local function Arrows_Show(self)
        self.l:Show()
        self.r:Show()
    end
    local function Arrows_SetVertexColor(self,...)
        self.l:SetVertexColor(...)
        self.r:SetVertexColor(...)
    end
    local function Arrows_UpdatePosition(self)
        if not CASTBAR_DETACH and
            self.parent.state.casting and
            self.parent.SpellIcon and
            self.parent.SpellIcon:IsVisible()
        then
            -- move for non-detached cast bar spell icon
            self.l:SetPoint('RIGHT',self.parent.bg,'LEFT',
                TARGET_ARROWS_INSET-self.parent.SpellIcon.bg:GetWidth(),0)
        else
            self.l:SetPoint('RIGHT',self.parent.bg,'LEFT',
                TARGET_ARROWS_INSET,0)
        end

        self.r:SetPoint('LEFT',self.parent.bg,'RIGHT',
            -TARGET_ARROWS_INSET,0)
    end
    local function Arrows_SetSize(self,size)
        self.l:SetSize(size,size)
        self.r:SetSize(size,size)
        self:UpdatePosition()
    end

    local function UpdateTargetArrows(f)
        if not TARGET_ARROWS or f.IN_NAMEONLY then
            f.TargetArrows:Hide()
            return
        end

        if f.state.target then
            -- update size, colour
            f.TargetArrows:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
            f.TargetArrows:SetSize(TARGET_ARROWS_SIZE)

            f.TargetArrows:Show()
            f.TargetArrows:UpdatePosition()
        else
            f.TargetArrows:Hide()
        end
    end
    function core:CreateTargetArrows(f)
        if not TARGET_ARROWS or f.TargetArrows then return end

        local left = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,4)
        left:SetTexture(MEDIA..'target-arrow')
        left:SetBlendMode('ADD')

        local right = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,4)
        right:SetTexture(MEDIA..'target-arrow')
        right:SetBlendMode('ADD')
        right:SetTexCoord(1,0,0,1)

        local arrows = {
            Hide = Arrows_Hide,
            Show = Arrows_Show,
            SetVertexColor = Arrows_SetVertexColor,
            UpdatePosition = Arrows_UpdatePosition,
            SetSize = Arrows_SetSize,
            parent = f,
            l = left,
            r = right,
        }

        f.TargetArrows = arrows
        f.UpdateTargetArrows = UpdateTargetArrows
    end
end
-- castbar #####################################################################
do
    local CASTBAR_ENABLED,CASTBAR_HEIGHT,CASTBAR_COLOUR,CASTBAR_UNIN_COLOUR,
          CASTBAR_SHOW_ICON,CASTBAR_SHOW_NAME,CASTBAR_SHOW_SHIELD,
          CASTBAR_NAME_VERTICAL_OFFSET,CASTBAR_ANIMATE,
          CASTBAR_ANIMATE_CHANGE_COLOUR,CASTBAR_SPACING,SHIELD_H,SHIELD_W,
          CASTBAR_DETACH_HEIGHT,CASTBAR_DETACH_WIDTH,
          CASTBAR_DETACH_OFFSET,CASTBAR_DETACH_COMBINE,CASTBAR_DETACH_NAMEONLY,
          CASTBAR_RATIO,CASTBAR_ICON_SIDE

    local function AnimGroup_Stop(self)
        self.frame:HideCastBar(nil,true)
        self.frame.CastBar.highlight:Hide()
    end
    local function SpellIconSetWidth(f)
        -- set spell icon width (as it's based on height)
        if CASTBAR_DETACH or not f.SpellIcon or not f.SpellIcon.bg then return end
        f.SpellIcon.bg:SetWidth(ceil(f.CastBar.bg:GetHeight() + f.bg:GetHeight() + CASTBAR_SPACING))
    end
    local function CastBarSetColour(castbar,colour,glow_too)
        -- set colour, assuming colour is a 3/4-length table,
        -- and set alpha depending on detach-combine/spell icon settings
        castbar:SetStatusBarColor(unpack(colour))

        if glow_too then
            -- glow inherits colour
            castbar.top:SetVertexColor(unpack(colour))
            castbar.bottom:SetVertexColor(unpack(colour))
        elseif GLOW_AS_SHADOW then
            castbar.top:SetVertexColor(0,0,0,.2)
            castbar.bottom:SetVertexColor(0,0,0,.2)
        else
            castbar.top:SetVertexColor(0,0,0,0)
            castbar.bottom:SetVertexColor(0,0,0,0)
        end

        if CASTBAR_DETACH_COMBINE and CASTBAR_SHOW_ICON then
            -- reduce alpha when combined
            castbar:GetStatusBarTexture():SetAlpha(.7)
        else
            castbar:GetStatusBarTexture():SetAlpha(1)
        end
    end

    local function ShowCastBar(f)
        if not f.elements.CastBar then
            -- ignore cast messsages if we've disabled the cast bar
            return
        end

        if CASTBAR_ANIMATE then
            f.CastBar.AnimGroup:Stop()
        end

        if f.cast_state.interruptible then
            CastBarSetColour(f.CastBar,CASTBAR_COLOUR)

            if f.elements.SpellShield then
                f.SpellShield:Hide()
            end
        else
            CastBarSetColour(f.CastBar,CASTBAR_UNIN_COLOUR,true)

            if f.elements.SpellShield then
                f.SpellShield:Show()
            end
        end

        f.CastBar:Show()
        f.CastBar.bg:Show()
        f.CastBar.spark:Show()

        if CASTBAR_SHOW_ICON and f.SpellIcon then
            f.SpellIcon:Show()
        end

        if CASTBAR_SHOW_NAME and f.SpellName then
            f.SpellName:Show()
        end

        if FADE_AVOID_CASTING then
            plugin_fading:UpdateFrame(f)
        end

        if TARGET_ARROWS then
            f:UpdateTargetArrows()
        end
    end
    local function HideCastBar(f,hide_cause,force)
        -- always hide spark instantly
        f.CastBar.spark:Hide()

        if force or not CASTBAR_ANIMATE then
            -- hide instantly
            if CASTBAR_ANIMATE and f.CastBar.AnimGroup:IsPlaying() then
                -- this fires another force hide, so use that;
                f.CastBar.AnimGroup:Stop()
                return
            end

            f.CastBar:Hide()
            f.CastBar.bg:Hide()

            if f.SpellName then
                f.SpellName:Hide()
            end
            if f.SpellIcon then
                f.SpellIcon:Hide()
            end
            if f.SpellShield then
                f.SpellShield:Hide()
            end
        else
            -- soft hide; set state colours, text, start animation
            if hide_cause == 2 then
                -- stopped
                f.CastBar:SetMinMaxValues(0,1)
                f.CastBar:SetValue(0)
            else
                if hide_cause == 1 then
                    -- interrupted
                    if f.SpellName then
                        f.SpellName:SetText(INTERRUPTED)
                    end

                    if CASTBAR_ANIMATE_CHANGE_COLOUR then
                        CastBarSetColour(f.CastBar,CASTBAR_UNIN_COLOUR)
                    end
                else
                    -- successful
                    if CASTBAR_ANIMATE_CHANGE_COLOUR then
                        CastBarSetColour(f.CastBar,CASTBAR_COLOUR)
                    end
                end

                f.CastBar:SetMinMaxValues(0,1)
                f.CastBar:SetValue(1)
                f.CastBar.highlight:Show()
            end

            f.CastBar.AnimGroup:Play()
        end

        if FADE_AVOID_CASTING then
            plugin_fading:UpdateFrame(f)
        end

        if TARGET_ARROWS then
            f:UpdateTargetArrows()
        end
    end
    local function UpdateCastBar(f)
        if not CASTBAR_ENABLED then return end
        if f.IN_NAMEONLY and (not CASTBAR_DETACH or not CASTBAR_DETACH_NAMEONLY) then
            f.handler:DisableElement('CastBar')

            if CASTBAR_ANIMATE and f.CastBar.AnimGroup:IsPlaying() then
                -- disabling the element only fires a force hide if the unit
                -- is currently casting; the animation can be left playing
                f.CastBar.AnimGroup:Stop()
            end
        else
            if f.state.personal then
                if core.profile.castbar_showpersonal then
                    f.handler:EnableElement('CastBar')
                else
                    f.handler:DisableElement('CastBar')
                end
            else
                if not core.profile.castbar_showall and
                   not f.state.target
                then
                    f.handler:DisableElement('CastBar')
                elseif f.state.friend then
                    if core.profile.castbar_showfriend then
                        f.handler:EnableElement('CastBar')
                    else
                        f.handler:DisableElement('CastBar')
                    end
                else
                    if core.profile.castbar_showenemy then
                        f.handler:EnableElement('CastBar')
                    else
                        f.handler:DisableElement('CastBar')
                    end
                end
            end
        end
    end
    local function UpdateSpellNamePosition(f)
        if not f.SpellName then return end
        f.SpellName:SetPoint('TOP',f.CastBar.bg,'BOTTOM',0,CASTBAR_NAME_VERTICAL_OFFSET)
    end
    local function UpdateCastbarSize(f)
        -- update castbar position and size to match config
        f.CastBar.bg:ClearAllPoints()
        f.CastBar:SetPoint('TOPLEFT',f.CastBar.bg,1,-1)
        f.CastBar:SetPoint('BOTTOMRIGHT',f.CastBar.bg,-1,1)

        if CASTBAR_DETACH then
            -- castbar detached from main frame
            f.CastBar.bg:SetSize(CASTBAR_DETACH_WIDTH,CASTBAR_DETACH_HEIGHT)
            f.CastBar.bg:SetPoint('TOP',f.bg,'BOTTOM',0,-CASTBAR_DETACH_OFFSET)

            if CASTBAR_SHOW_ICON and f.SpellIcon then
                if CASTBAR_DETACH_COMBINE then
                    -- overlay spell icon on bar
                    f.SpellIcon:SetAllPoints()
                    f.SpellIcon:SetTexCoord(.1,.9,.1+CASTBAR_RATIO,.9-CASTBAR_RATIO)
                    f.SpellIcon:SetAlpha(.6)
                else
                    -- spell icon next to bar
                    f.SpellIcon:ClearAllPoints()
                    f.SpellIcon:SetSize(CASTBAR_DETACH_HEIGHT-2,CASTBAR_DETACH_HEIGHT-2)
                    f.SpellIcon:SetTexCoord(.1,.9,.1,.9)
                    f.SpellIcon:SetAlpha(1)

                    if CASTBAR_ICON_SIDE == 1 then
                        f.SpellIcon:SetPoint('TOPLEFT',f.CastBar.bg,1,-1)
                        f.CastBar:SetPoint('TOPLEFT',f.SpellIcon,'TOPRIGHT',1,0)
                    else
                        f.SpellIcon:SetPoint('TOPRIGHT',f.CastBar.bg,-1,-1)
                        f.CastBar:SetPoint('BOTTOMRIGHT',f.SpellIcon,'BOTTOMLEFT',-1,0)
                    end
                end
            end
        else
            -- move spell icon to left side of health bar,
            -- attach castbar to bottom of health bar background
            f.CastBar.bg:SetPoint('TOPLEFT',f.bg,'BOTTOMLEFT',0,-CASTBAR_SPACING)
            f.CastBar.bg:SetPoint('TOPRIGHT',f.bg,'BOTTOMRIGHT')
            f.CastBar.bg:SetHeight(CASTBAR_HEIGHT)

            f.CastBar:SetPoint('TOPLEFT',f.CastBar.bg,1,-1)
            f.CastBar:SetPoint('BOTTOMRIGHT',f.CastBar.bg,-1,1)

            if CASTBAR_SHOW_ICON and f.SpellIcon then
                f.SpellIcon:ClearAllPoints()
                f.SpellIcon.bg:ClearAllPoints()

                f.SpellIcon:SetPoint('TOPLEFT',f.SpellIcon.bg,1,-1)
                f.SpellIcon:SetPoint('BOTTOMRIGHT',f.SpellIcon.bg,-1,1)
                f.SpellIcon:SetTexCoord(.1,.9,.1,.9)
                f.SpellIcon:SetAlpha(1)

                if CASTBAR_ICON_SIDE == 1 then
                    f.SpellIcon.bg:SetPoint('TOPRIGHT',f.bg,'TOPLEFT',-CASTBAR_SPACING,0)
                    f.SpellIcon.bg:SetPoint('BOTTOMRIGHT',f.CastBar.bg,'BOTTOMLEFT')
                else
                    f.SpellIcon.bg:SetPoint('TOPLEFT',f.bg,'TOPRIGHT',CASTBAR_SPACING,0)
                    f.SpellIcon.bg:SetPoint('BOTTOMLEFT',f.CastBar.bg,'BOTTOMRIGHT')
                end

                f:SpellIconSetWidth()
            end
        end
    end

    local function CreateSpellIcon(f)
        local icon = f.CastBar:CreateTexture(nil, 'BACKGROUND', nil, 2)
        f.handler:RegisterElement('SpellIcon', icon)
        return icon
    end
    local function CreateSpellIconBackground(f)
        local bg = f.CastBar:CreateTexture(nil,'BACKGROUND',nil,1)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.9)
        f.SpellIcon.bg = bg
        return bg
    end
    local function CreateSpellShield(f)
        -- cast shield
        local shield = f.CastBar:CreateTexture(nil, 'ARTWORK', nil, 3)
        shield:SetTexture(MEDIA..'Shield')
        shield:SetTexCoord(0, .84375, 0, 1)
        shield:SetSize(SHIELD_W,SHIELD_H)
        shield:SetPoint('LEFT', f.CastBar.bg, -7, 0)
        shield:SetVertexColor(.5, .5, .7)
        shield:Hide()

        f.handler:RegisterElement('SpellShield', shield)
        return shield
    end
    local function CreateSpellName(f)
        local spellname = CreateFontString(f.CastBar,FONT_SIZE_SMALL)
        spellname:SetWordWrap()
        spellname:Hide()

        f.handler:RegisterElement('SpellName', spellname)
        return spellname
    end
    local function CreateAnimGroup(f)
        -- bar highlight texture
        local hl = f.CastBar:CreateTexture(nil,'ARTWORK',nil,1)
        hl:SetTexture(BAR_TEXTURE)
        hl:SetAllPoints(f.CastBar)
        hl:SetVertexColor(1,1,1,.4)
        hl:SetBlendMode('ADD')
        hl:Hide()
        f.CastBar.highlight = hl

        local grp = f.CastBar:CreateAnimationGroup()
        -- bar fade
        local bar = grp:CreateAnimation("Alpha")
        bar:SetStartDelay(.5)
        bar:SetDuration(.5)
        bar:SetFromAlpha(1)
        bar:SetToAlpha(0)
        grp.bar = bar

        -- highlight flash
        local highlight = grp:CreateAnimation("Alpha")
        highlight:SetChildKey('highlight')
        highlight:SetStartDelay(.05)
        highlight:SetDuration(.25)
        highlight:SetSmoothing('IN')
        highlight:SetFromAlpha(.4)
        highlight:SetToAlpha(0)
        grp.highlight = highlight

        grp.frame = f
        f.CastBar.AnimGroup = grp
        grp:SetScript('OnFinished',AnimGroup_Stop)
        grp:SetScript('OnStop',AnimGroup_Stop)
    end
    local function CreateOptionalElementsMaybe(f)
        -- check if we need to create extra elements to support configuration
        if CASTBAR_SHOW_NAME and not f.SpellName then
            CreateSpellName(f)
        end
        if CASTBAR_SHOW_ICON and not f.SpellIcon then
            CreateSpellIcon(f)
        end
        if CASTBAR_SHOW_ICON and not CASTBAR_DETACH and not f.SpellIcon.bg then
            CreateSpellIconBackground(f)
        end
        if CASTBAR_SHOW_SHIELD and not f.SpellShield then
            CreateSpellShield(f)
        end
        if CASTBAR_ANIMATE and not f.CastBar.AnimGroup then
            CreateAnimGroup(f)
        elseif not CASTBAR_ANIMATE and f.CastBar.AnimGroup then
            -- make sure frames which might have been animating when the
            -- option was changed are stopped;
            f.CastBar.AnimGroup:Stop()
        end
    end

    function core:CreateCastBar(f)
        local castbar = CreateStatusBar(f,true,nil,true,1)
        castbar:Hide()

        local bg = castbar:CreateTexture(nil,'BACKGROUND',nil,1)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.9)
        bg:Hide()

        castbar.bg = bg

        -- XXX glow
        local top = castbar:CreateTexture(nil,'BACKGROUND',nil,-5)
        top:SetTexture(MEDIA..'target-glow')
        top:SetTexCoord(1,0,1,0)
        top:SetPoint('BOTTOMLEFT',bg,'TOPLEFT',0,0)
        top:SetPoint('BOTTOMRIGHT',bg,'TOPRIGHT',0,0)
        top:SetHeight(6)
        top:SetVertexColor(0,0,0,.2)
        castbar.top = top

        local bottom = castbar:CreateTexture(nil,'BACKGROUND',nil,-5)
        bottom:SetTexture(MEDIA..'target-glow')
        bottom:SetPoint('TOPLEFT',bg,'BOTTOMLEFT',0,0)
        bottom:SetPoint('TOPRIGHT',bg,'BOTTOMRIGHT',0,0)
        bottom:SetHeight(6)
        bottom:SetVertexColor(0,0,0,.2)
        castbar.bottom = bottom

        -- register base elements
        f.handler:RegisterElement('CastBar', castbar)

        CreateOptionalElementsMaybe(f)

        f.ShowCastBar = ShowCastBar
        f.HideCastBar = HideCastBar
        f.UpdateCastBar = UpdateCastBar
        f.UpdateSpellNamePosition = UpdateSpellNamePosition
        f.UpdateCastbarSize = UpdateCastbarSize
        f.SpellIconSetWidth = SpellIconSetWidth

        f:UpdateSpellNamePosition()
        f:UpdateCastbarSize()
    end

    function core:SetCastBarConfig()
        CASTBAR_ENABLED = self.profile.castbar_enable
        CASTBAR_HEIGHT = Scale(self.profile.castbar_height)
        CASTBAR_COLOUR = self.profile.castbar_colour
        CASTBAR_UNIN_COLOUR = self.profile.castbar_unin_colour
        CASTBAR_SHOW_ICON = self.profile.castbar_icon
        CASTBAR_SHOW_NAME = self.profile.castbar_name
        CASTBAR_SHOW_SHIELD = self.profile.castbar_shield
        CASTBAR_NAME_VERTICAL_OFFSET = ScaleTextOffset(self.profile.castbar_name_vertical_offset)
        CASTBAR_ANIMATE = self.profile.castbar_animate
        CASTBAR_ANIMATE_CHANGE_COLOUR = self.profile.castbar_animate_change_colour
        CASTBAR_SPACING = self.profile.castbar_spacing
        SHIELD_H = Scale(16)
        SHIELD_W = SHIELD_H * .84375

        CASTBAR_DETACH = self.profile.castbar_detach
        CASTBAR_DETACH_HEIGHT = Scale(self.profile.castbar_detach_height)
        CASTBAR_DETACH_WIDTH = Scale(self.profile.castbar_detach_width)
        CASTBAR_DETACH_OFFSET = Scale(self.profile.castbar_detach_offset)
        CASTBAR_DETACH_COMBINE = CASTBAR_DETACH and self.profile.castbar_detach_combine
        CASTBAR_DETACH_NAMEONLY = self.profile.castbar_detach_nameonly
        CASTBAR_RATIO = (1-(CASTBAR_DETACH_HEIGHT/CASTBAR_DETACH_WIDTH))/2
        CASTBAR_ICON_SIDE = self.profile.castbar_icon_side

        for _,f in addon:Frames() do
            CreateOptionalElementsMaybe(f)

            if f.SpellShield then
                if CASTBAR_SHOW_SHIELD then
                    f.handler:EnableElement('SpellShield')
                    f.SpellShield:SetSize(SHIELD_W,SHIELD_H)
                else
                    f.handler:DisableElement('SpellShield')
                end
            end

            if f.SpellIcon then
                -- determine spell icon visibility...
                if CASTBAR_SHOW_ICON then
                    f.SpellIcon:Show()

                    -- determine icon background visibility...
                    if f.SpellIcon.bg then
                        if CASTBAR_DETACH then
                            f.SpellIcon.bg:Hide()
                        else
                            f.SpellIcon.bg:Show()
                        end
                    end
                else
                    -- hide icon and background
                    f.SpellIcon:Hide()

                    if f.SpellIcon.bg then
                        f.SpellIcon.bg:Hide()
                    end
                end
            end

            f:UpdateCastbarSize()
            f:UpdateSpellNamePosition()
        end
    end
end
-- state icons #################################################################
do
    local SHOW_STATE_ICONS,ICON_SIZE
    local BOSS = {0,.5,0,.5}
    local RARE = {.5,1,.5,1}

    function core:configChangedStateIcons()
        SHOW_STATE_ICONS = self.profile.state_icons
        ICON_SIZE = Scale(20)

        for _,f in addon:Frames() do
            f:UpdateStateIconSize()
        end
    end

    local function UpdateStateIcon(f)
        if  not SHOW_STATE_ICONS or
            f.IN_NAMEONLY or
            (f.elements.LevelText and f.LevelText:IsShown())
        then
            f.StateIcon:Hide()
            return
        end

        if f.state.classification == 'worldboss' then
            f.StateIcon:SetTexCoord(unpack(BOSS))
            f.StateIcon:SetVertexColor(1,1,1)
            f.StateIcon:Show()
        elseif f.state.classification == 'rare' or f.state.classification == 'rareelite' then
            f.StateIcon:SetTexCoord(unpack(RARE))
            f.StateIcon:SetVertexColor(1,.8,.2)
            f.StateIcon:Show()
        else
            f.StateIcon:Hide()
        end
    end
    local function UpdateStateIconSize(f)
        f.StateIcon:SetSize(ICON_SIZE,ICON_SIZE)
    end
    function core:CreateStateIcon(f)
        local stateicon = f:CreateTexture(nil,'ARTWORK',nil,4)
        stateicon:SetTexture(MEDIA..'state-icons')
        stateicon:SetPoint('LEFT',f.HealthBar,'BOTTOMLEFT',0,1)

        f.StateIcon = stateicon
        f.UpdateStateIcon = UpdateStateIcon
        f.UpdateStateIconSize = UpdateStateIconSize

        f:UpdateStateIconSize()
    end
end
-- raid icons ##################################################################
do
    local function UpdateRaidIcon(f)
        f.RaidIcon:ClearAllPoints()

        if f.IN_NAMEONLY then
            f.RaidIcon:SetParent(f)
            f.RaidIcon:SetDrawLayer('ARTWORK',1)
            f.RaidIcon:SetPoint('LEFT',f.NameText,f.NameText:GetStringWidth()+2,0)
        else
            f.RaidIcon:SetParent(f.HealthBar)
            f.RaidIcon:SetDrawLayer('ARTWORK',6)
            f.RaidIcon:SetPoint('LEFT',f.HealthBar,'RIGHT',5,0)
        end
    end
    function core:CreateRaidIcon(f)
        local raidicon = f:CreateTexture()
        raidicon:SetTexture('interface/targetingframe/ui-raidtargetingicons')
        raidicon:SetSize(26,26)

        f.UpdateRaidIcon = UpdateRaidIcon

        f.handler:RegisterElement('RaidIcon',raidicon)
    end
end
-- auras #######################################################################
do
    local AURAS_NORMAL_SIZE,AURAS_MINUS_SIZE,AURAS_CENTRE,
          AURAS_ON_PERSONAL,AURAS_ON_FRIENDS,AURAS_ON_ENEMIES,AURAS_ON_MINUS,
          AURAS_ENABLED,AURAS_SHOW_ALL_SELF,AURAS_HIDE_ALL_OTHER,
          AURAS_PURGE_SIZE,AURAS_SHOW_PURGE,AURAS_SIDE,AURAS_OFFSET,
          AURAS_POINT_S,AURAS_POINT_R,PURGE_POINT_S,PURGE_POINT_R,
          PURGE_OFFSET,AURAS_TIMER_THRESHOLD,
          AURAS_PURGE_OPPOSITE,AURAS_HIGHLIGHT_OTHER,
          AURAS_CD_SIZE,AURAS_COUNT_SIZE,AURAS_PER_ROW,
          AURAS_PULSATE,AURAS_ICON_SQUARENESS,AURAS_SORT

    local AURAS_CD_POINT_X,AURAS_CD_POINT_Y,
          AURAS_CD_OFFSET_X,AURAS_CD_OFFSET_Y,
          AURAS_COUNT_POINT_X,AURAS_COUNT_POINT_Y,
          AURAS_COUNT_OFFSET_X,AURAS_COUNT_OFFSET_Y

    local function AuraFrame_UpdateFrameSize(self,to_size)
        -- frame width changes depending on icon size, needs to be correct if
        -- auras are centred, and we want to make sure the frame isn't aligned
        -- to subpixels;
        if not self.__width or to_size then
            self.__width = ((to_size or self.size) * self.num_per_row) +
                           (self.num_per_row - 1)
            self:SetWidth(self.__width)

            if to_size or AURAS_CENTRE then
                -- resize & re-arrange buttons
                -- (arrange is always needed after a width change if centred)
                self:SetIconSize(to_size)
            end

            -- update frame height
            core.Auras_PostUpdateAuraFrame(self)

            self.__h_offset = AURAS_CENTRE and
                floor((self.parent.bg:GetWidth() - self.__width) / 2) or
                0
        end

        self:ClearAllPoints()

        -- update position
        if self.id == 'core_dynamic' or
           (not AURAS_PURGE_OPPOSITE and not self.sibling:IsShown())
        then
            -- attach to top/bottom of frame bg
            self:SetPoint(AURAS_POINT_S,self.parent.bg,AURAS_POINT_R,
                self.__h_offset,AURAS_OFFSET)
        else
            -- core_purge;
            if AURAS_PURGE_OPPOSITE then
                -- attach to the opposite side of frame bg
                self:SetPoint(PURGE_POINT_S,self.parent.bg,PURGE_POINT_R,
                    self.__h_offset,PURGE_OFFSET)
            else
                -- attach to top/bottom of core_dynamic
                self:SetPoint(PURGE_POINT_S,self.sibling,PURGE_POINT_R,
                    0,PURGE_OFFSET)
                self:SetPoint('LEFT',self.parent.bg,
                    self.__h_offset,0)
            end
        end
    end
    local function AuraFrame_UpdateIconSize(self,minus)
        -- determine current icon size
        local size = (self.id == 'core_purge' and AURAS_PURGE_SIZE) or
                     (minus and AURAS_MINUS_SIZE or AURAS_NORMAL_SIZE)

        if self.id ~= 'core_purge' and self.size == size then
            -- no size update necessary
            size = nil
        end

        -- update frame point + size
        AuraFrame_UpdateFrameSize(self,size)
    end
    local function AuraFrame_CoreDynamic_OnVisibilityChange(self)
        if self.parent.IGNORE_VISIBILITY_BUBBLE then return end
        if not AURAS_PURGE_OPPOSITE and self.sibling.__width then
            -- update sibling point if it's attached and initialised
            AuraFrame_UpdateFrameSize(self.sibling)
        end
    end

    local function UpdateAuras(f)
        -- enable/disable aura frames on frame update
        if not f.Auras or not f.Auras.frames then return end
        if f.Auras.frames.core_dynamic then
            if not AURAS_ENABLED or
               (not AURAS_ON_PERSONAL and f.state.personal) or
               (not AURAS_ON_FRIENDS and f.state.friend and not f.state.personal) or
               (not AURAS_ON_ENEMIES and not f.state.friend) or
               (not AURAS_ON_MINUS and f.state.minus)
            then
                f.Auras.frames.core_dynamic:Disable()
            else
                f.Auras.frames.core_dynamic:Enable(true)
                AuraFrame_UpdateIconSize(f.Auras.frames.core_dynamic,f.state.minus)
            end
        end
        if f.Auras.frames.core_purge then
            if not AURAS_SHOW_PURGE or f.state.friend then
                f.Auras.frames.core_purge:Disable()
            else
                -- only show purge on enemies
                f.Auras.frames.core_purge:Enable(true)
                AuraFrame_UpdateIconSize(f.Auras.frames.core_purge)
            end
        end
    end
    function core:CreateAuras(f)
        -- for both frames:
        -- initial icon size set by AuraFrame_UpdateIconSize < UpdateAuras
        -- frame width & point set by AuraFrame_UpdateFrameSize < _UpdateIconSize
        f.UpdateAuras = UpdateAuras

        local auras = f.handler:CreateAuraFrame({
            id = 'core_dynamic',
            max = 10,
            point = {'BOTTOMLEFT','LEFT','RIGHT'},
            x_spacing = 1,
            y_spacing = 1,

            num_per_row = AURAS_PER_ROW,
            pulsate = AURAS_PULSATE,
            timer_threshold = AURAS_TIMER_THRESHOLD,
            squareness = AURAS_ICON_SQUARENESS,
            sort = AURAS_SORT,
            centred = AURAS_CENTRE,
        })
        auras.__core = true
        auras:SetFrameLevel(0)
        auras:HookScript('OnShow',AuraFrame_CoreDynamic_OnVisibilityChange)
        auras:HookScript('OnHide',AuraFrame_CoreDynamic_OnVisibilityChange)

        local purge = f.handler:CreateAuraFrame({
            id = 'core_purge',
            purge = true,
            max = 4,
            point = {'BOTTOMLEFT','LEFT','RIGHT'},
            x_spacing = 1,
            y_spacing = 1,
            rows = 1,

            pulsate = false,
            timer_threshold = AURAS_TIMER_THRESHOLD,
            squareness = AURAS_ICON_SQUARENESS,
            sort = AURAS_SORT,
            centred = AURAS_CENTRE,
        })
        purge.__core = true
        purge:SetFrameLevel(0)

        auras.sibling = purge
        purge.sibling = auras
    end

    -- callbacks
    function core.Auras_PostCreateAuraButton(frame,button)
        -- move text to obey our settings
        button.cd.fontobject_shadow = true
        button.cd:ClearAllPoints()
        button.cd:SetPoint(
            ResolvePointPair(AURAS_CD_POINT_X,AURAS_CD_POINT_Y),
            AURAS_CD_OFFSET_X, AURAS_CD_OFFSET_Y
        )
        button.cd:SetJustifyH(POINT_X_ASSOC[AURAS_CD_POINT_X])

        button.count.fontobject_shadow = true
        button.count.fontobject_small = true
        button.count:ClearAllPoints()
        button.count:SetPoint(
            ResolvePointPair(AURAS_COUNT_POINT_X,AURAS_COUNT_POINT_Y),
            AURAS_COUNT_OFFSET_X, AURAS_COUNT_OFFSET_Y
        )
        button.count:SetJustifyH(POINT_X_ASSOC[AURAS_COUNT_POINT_X])

        if frame.__core and not button.hl then
            -- create owner highlight
            local hl = button:CreateTexture(nil,'ARTWORK',nil,2)
            hl:SetTexture(KUI_MEDIA..'t/button-highlight')
            hl:SetAllPoints(button.icon)
            hl:Hide()

            button.hl = hl
        end

        core.AurasButton_SetFont(button)
    end
    function core.Auras_PostDisplayAuraButton(frame,button)
        if not frame.__core then return end
        if not button.hl then return end

        if frame.purge or button.can_purge then
            button.hl:SetVertexColor(1,.2,.2,.8)
            button.hl:Show()
        elseif AURAS_HIGHLIGHT_OTHER and not button.own then
            button.hl:SetVertexColor(.4,1,.2,.8)
            button.hl:Show()
        else
            button.hl:Hide()
        end
    end
    function core.Auras_PostUpdateAuraFrame(frame)
        -- maintain auraframe height corresponding to #visible buttons
        if not frame.__core then return end
        if frame.visible and frame.visible > 0 then
            frame:SetHeight(
                ceil(frame.size*frame.squareness) *
                ceil(frame.visible / (frame.max / frame.rows))
            )
        end
    end
    function core.Auras_DisplayAura(frame,spellid,name,duration,_,own,_,nps_own,nps_all)
        if not frame.__core then return end
        if frame.purge then
            -- force hide if excluded by spell list
            if KSL:SpellExcluded(spellid) or KSL:SpellExcluded(name) then
                return 1
            end
        else
            -- force show if included by spell list
            if  (KSL:SpellIncludedAll(spellid) or
                 KSL:SpellIncludedAll(name)) or
                (own and (KSL:SpellIncludedOwn(spellid) or
                 KSL:SpellIncludedOwn(name)))
            then
                return 2
            end

            if not kui.CLASSIC then
                -- force hide infinite duration unless whitelisted
                -- (duration data is limited on classic)
                if duration == 0 and not nps_all and not nps_own then
                    return 1
                end
            end

            -- force hide if excluded by spell list, as above
            if KSL:SpellExcluded(spellid) or KSL:SpellExcluded(name) then
                return 1
            end

            if AURAS_SHOW_ALL_SELF or AURAS_HIDE_ALL_OTHER then
                if own then
                    if AURAS_SHOW_ALL_SELF then
                        -- show all casts from the player
                        return 2
                    end
                else
                    if AURAS_HIDE_ALL_OTHER then
                        -- hide all other players' casts (CC, etc.)
                        return 1
                    end
                end
            end
        end

        -- process as normal
        return
    end
    function core.AurasButton_SetFont(button)
        button.cd.fontobject_size = AURAS_CD_SIZE > 0 and AURAS_CD_SIZE
        UpdateFontObject(button.cd)

        button.count.fontobject_size = AURAS_COUNT_SIZE > 0 and AURAS_COUNT_SIZE
        UpdateFontObject(button.count)
    end

    -- config changed
    function core:SetAurasConfig()
        AURAS_ENABLED = self.profile.auras_enabled
        AURAS_PULSATE = self.profile.auras_pulsate
        AURAS_CENTRE = self.profile.auras_centre
        AURAS_SORT = self.profile.auras_sort
        AURAS_TIMER_THRESHOLD = self.profile.auras_time_threshold
        AURAS_NORMAL_SIZE = Scale(self.profile.auras_icon_normal_size)
        AURAS_MINUS_SIZE = Scale(self.profile.auras_icon_minus_size)
        AURAS_ICON_SQUARENESS = self.profile.auras_icon_squareness
        AURAS_ON_PERSONAL = self.profile.auras_on_personal
        AURAS_ON_FRIENDS = self.profile.auras_on_friends
        AURAS_ON_ENEMIES = self.profile.auras_on_enemies
        AURAS_ON_MINUS = self.profile.auras_on_minus
        AURAS_SHOW_ALL_SELF = self.profile.auras_show_all_self
        AURAS_HIDE_ALL_OTHER = self.profile.auras_hide_all_other
        AURAS_SHOW_PURGE = self.profile.auras_show_purge
        AURAS_PURGE_SIZE = Scale(self.profile.auras_purge_size)
        AURAS_PURGE_OPPOSITE = self.profile.auras_purge_opposite
        AURAS_SIDE = self.profile.auras_side
        AURAS_OFFSET = Scale(self.profile.auras_offset)
        AURAS_HIGHLIGHT_OTHER = self.profile.auras_highlight_other
        AURAS_PER_ROW = self.profile.auras_per_row
        AURAS_CD_SIZE = Scale(self.profile.auras_cd_size)
        AURAS_COUNT_SIZE = Scale(self.profile.auras_count_size)
        AURAS_CD_POINT_X = self.profile.auras_cd_point_x
        AURAS_CD_POINT_Y = self.profile.auras_cd_point_y
        AURAS_CD_OFFSET_X = ScaleTextOffset(self.profile.auras_cd_offset_x)
        AURAS_CD_OFFSET_Y = ScaleTextOffset(self.profile.auras_cd_offset_y)
        AURAS_COUNT_POINT_X = self.profile.auras_count_point_x
        AURAS_COUNT_POINT_Y = self.profile.auras_count_point_y
        AURAS_COUNT_OFFSET_X = ScaleTextOffset(self.profile.auras_count_offset_x)
        AURAS_COUNT_OFFSET_Y = ScaleTextOffset(self.profile.auras_count_offset_y)

        if AURAS_TIMER_THRESHOLD < 0 then
            AURAS_TIMER_THRESHOLD = nil
        end

        -- resolve side to points
        if not AURAS_SIDE or AURAS_SIDE == 1 then
            -- top
            AURAS_POINT_S = 'BOTTOMLEFT'
            AURAS_POINT_R = 'TOPLEFT'

            if AURAS_PURGE_OPPOSITE then
                PURGE_POINT_S = 'TOPLEFT'
                PURGE_POINT_R = 'BOTTOMLEFT'
                PURGE_OFFSET = -AURAS_OFFSET
            else
                PURGE_POINT_S = 'BOTTOM'
                PURGE_POINT_R = 'TOP'
                PURGE_OFFSET = 3
            end
        else
            -- bottom
            AURAS_POINT_S = 'TOPLEFT'
            AURAS_POINT_R = 'BOTTOMLEFT'

            if AURAS_PURGE_OPPOSITE then
                PURGE_POINT_S = 'BOTTOMLEFT'
                PURGE_POINT_R = 'TOPLEFT'
                PURGE_OFFSET = AURAS_OFFSET
            else
                PURGE_POINT_S = 'TOP'
                PURGE_POINT_R = 'BOTTOM'
                PURGE_OFFSET = -3
            end

            AURAS_OFFSET = -AURAS_OFFSET
        end

        -- update config values within aura frames;
        for _,f in addon:Frames() do
            if f.Auras and f.Auras.frames then
                local cd = f.Auras.frames.core_dynamic
                local cp = f.Auras.frames.core_purge
                if cd then
                    cd.point[1] = AURAS_POINT_S
                    cd.pulsate = AURAS_PULSATE
                    cd.num_per_row = AURAS_PER_ROW
                    cd.timer_threshold = AURAS_TIMER_THRESHOLD
                    cd.squareness = AURAS_ICON_SQUARENESS
                    cd.centred = AURAS_CENTRE
                    cd.__width = nil -- force size & position update
                    cd:SetSort(AURAS_SORT)
                end
                if cp and AURAS_SHOW_PURGE then
                    cp.point[1] = AURAS_PURGE_OPPOSITE and
                                  PURGE_POINT_S or AURAS_POINT_S
                    cp.timer_threshold = AURAS_TIMER_THRESHOLD
                    cp.squareness = AURAS_ICON_SQUARENESS
                    cp.centred = AURAS_CENTRE
                    cp.__width = nil
                    cp:SetSort(AURAS_SORT)
                end

                -- update all buttons
                for _,auraframe in pairs(f.Auras.frames) do
                    for _,button in ipairs(auraframe.buttons) do
                        self.Auras_PostCreateAuraButton(auraframe,button)
                    end
                end
            end
        end

        -- update auras plugin config
        -- (we override fonts with the PostCreateAuraButton callback)
        self.Auras                   = self.Auras or {}
        self.Auras.colour_short      = self.profile.auras_colour_short
        self.Auras.colour_medium     = self.profile.auras_colour_medium
        self.Auras.colour_long       = self.profile.auras_colour_long
        self.Auras.decimal_threshold = self.profile.auras_decimal_threshold

        addon:GetPlugin('Auras'):UpdateConfig()

        -- we don't want to actually disable the element as other plugins
        -- (such as bossmods) rely on it
    end
end
-- class powers ################################################################
function core.ClassPowers_PostPositionFrame(cpf,parent)
    if not parent or not cpf or not cpf:IsShown() then return end

    -- change position in nameonly mode/on the player's nameplate
    if parent.IN_NAMEONLY then
        cpf:ClearAllPoints()

        if parent.GuildText and parent.state.guild_text then
            cpf:SetPoint('TOP',parent.GuildText,'BOTTOM',0,-3)
        else
            cpf:SetPoint('TOP',parent.NameText,'BOTTOM',0,-3)
        end
    elseif parent.state.personal then
        cpf:ClearAllPoints()
        cpf:SetPoint('CENTER',parent.HealthBar,'TOP',0,9)
    end
end
function core.ClassPowers_CreateBar()
    local bar = CreateStatusBar(addon.ClassPowersFrame)
    bar:SetSize(
        core.profile.classpowers_bar_width,
        core.profile.classpowers_bar_height
    )
    bar:SetPoint('CENTER',0,-1)

    bar.fill:SetParent(bar)
    bar.fill:SetDrawLayer('BACKGROUND',2)

    bar:SetBackdrop({
        bgFile=kui.m.t.solid,
        insets={top=-1,right=-1,bottom=-1,left=-1}
    })
    bar:SetBackdropColor(0,0,0,.9)

    return bar
end
-- threat brackets #############################################################
do
    local TB_TEXTURE = MEDIA..'threat-bracket'
    local TB_POINTS = {
        { 'BOTTOMRIGHT', 'TOPLEFT',    -1, 1 },
        { 'BOTTOMLEFT','TOPRIGHT',     1, 1 },
        { 'TOPRIGHT',    'BOTTOMLEFT', -1, -1 },
        { 'TOPLEFT',   'BOTTOMRIGHT',  1, -1 },
    }
    -- threat bracket prototype
    local tb_prototype = {}
    tb_prototype.__index = tb_prototype
    function tb_prototype:SetVertexColor(...)
        for _,v in ipairs(self.textures) do
            v:SetVertexColor(...)
            v:SetAlpha(.8)
        end
    end
    function tb_prototype:Show(...)
        for _,v in ipairs(self.textures) do
            v:Show(...)
        end
    end
    function tb_prototype:Hide(...)
        for _,v in ipairs(self.textures) do
            v:Hide(...)
        end
    end
    function tb_prototype:SetSize(size)
        for _,v in ipairs(self.textures) do
            v:SetSize(size,size)
        end
    end
    -- update
    local function UpdateThreatBrackets(f)
        if not THREAT_BRACKETS or f.IN_NAMEONLY then
            f.ThreatBrackets:Hide()
            return
        end

        if f.state.glowing then
            f.ThreatBrackets:SetVertexColor(unpack(f.state.glow_colour))
            f.ThreatBrackets:SetSize(THREAT_BRACKETS_SIZE)
            f.ThreatBrackets:Show()
        else
            f.ThreatBrackets:Hide()
        end
    end
    -- create
    function core:CreateThreatBrackets(f)
        local tb = { textures = {} }
        setmetatable(tb,tb_prototype)

        for i,p in ipairs(TB_POINTS) do
            local b = f:CreateTexture(nil,'BACKGROUND',nil,0)
            b:SetTexture(TB_TEXTURE)
            b:SetBlendMode('ADD')
            b:SetPoint(p[1], f.bg, p[2], p[3], p[4])
            b:Hide()

            if i == 2 then
                b:SetTexCoord(1,0,0,1)
            elseif i == 3 then
                b:SetTexCoord(0,1,1,0)
            elseif i == 4 then
                b:SetTexCoord(1,0,1,0)
            end

            tinsert(tb.textures,b)
        end

        f.ThreatBrackets = tb
        f.UpdateThreatBrackets = UpdateThreatBrackets
    end
end
-- name show/hide ##############################################################
function core:ShowNameUpdate(f)
    if  not FADE_UNTRACKED and
        not FADE_AVOID_TRACKED and
        not FADE_AVOID_COMBAT and
        f.IN_NAMEONLY
    then
        -- no need to calculate when in name-only (unless fade rules are used)
        return
    end

    if f.state.target or
       f.state.threat or
       UnitShouldDisplayName(f.unit)
    then
        f.state.tracked = true
        f.state.no_name = nil
    else
        f.state.tracked = nil
        f.state.no_name = HIDE_NAMES
    end

    if SHOW_ARENA_ID and f.state.arenaid then
        f.state.no_name = nil
    elseif f.state.personal or not SHOW_NAME_TEXT then
        f.state.no_name = true
    end

    if FADE_UNTRACKED or FADE_AVOID_TRACKED or FADE_AVOID_COMBAT then
        plugin_fading:UpdateFrame(f)
    end
end
-- nameonly ####################################################################
do
    local NAMEONLY_ENABLED,NAMEONLY_NO_FONT_STYLE,NAMEONLY_HEALTH_COLOUR
    local NAMEONLY_TARGET,NAMEONLY_ALL_ENEMIES,NAMEONLY_ON_NEUTRAL,
          NAMEONLY_HOSTILE_NPCS,NAMEONLY_DAMAGED_ENEMIES,NAMEONLY_FRIENDLY_NPCS,
          NAMEONLY_DAMAGED_FRIENDS,NAMEONLY_COMBAT_HOSTILE,
          NAMEONLY_COMBAT_FRIENDLY,NAMEONLY_HOSTILE_PLAYERS,
          NAMEONLY_FRIENDLY_PLAYERS,NAMEONLY_COMBAT_HOSTILE_PLAYER

    function core:configChangedNameOnly()
        NAMEONLY_ENABLED = self.profile.nameonly
        NAMEONLY_NO_FONT_STYLE = self.profile.nameonly_no_font_style
        NAMEONLY_HEALTH_COLOUR = self.profile.nameonly_health_colour

        NAMEONLY_TARGET = self.profile.nameonly_target
        NAMEONLY_ALL_ENEMIES = self.profile.nameonly_all_enemies
        NAMEONLY_ON_NEUTRAL = self.profile.nameonly_neutral
        NAMEONLY_HOSTILE_NPCS = self.profile.nameonly_enemies
        NAMEONLY_HOSTILE_PLAYERS = self.profile.nameonly_hostile_players
        NAMEONLY_DAMAGED_ENEMIES = self.profile.nameonly_damaged_enemies
        NAMEONLY_FRIENDLY_NPCS = self.profile.nameonly_friends
        NAMEONLY_FRIENDLY_PLAYERS = self.profile.nameonly_friendly_players
        NAMEONLY_DAMAGED_FRIENDS = self.profile.nameonly_damaged_friends
        NAMEONLY_COMBAT_HOSTILE = self.profile.nameonly_combat_hostile
        NAMEONLY_COMBAT_HOSTILE_PLAYER = self.profile.nameonly_combat_hostile_player
        NAMEONLY_COMBAT_FRIENDLY = self.profile.nameonly_combat_friends

        -- create target/threat glow
        for _,f in addon:Frames() do
            self:CreateNameOnlyGlow(f)
        end
    end

    do
        local function UpdateNameOnlyGlowSize(f)
            if not f.NameOnlyGlow then return end
            f.NameOnlyGlow:SetPoint('TOPLEFT',f.NameText,
                -6-FRAME_GLOW_SIZE,  FRAME_GLOW_SIZE)
            f.NameOnlyGlow:SetPoint('BOTTOMRIGHT',f.NameText,
                 6+FRAME_GLOW_SIZE, -FRAME_GLOW_SIZE)
        end
        function core:CreateNameOnlyGlow(f)
            if f.NameOnlyGlow then return end

            local g = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            g:SetTexture(KUI_MEDIA..'t/spark-flat')
            g:Hide()

            f.NameOnlyGlow = g
            f.UpdateNameOnlyGlowSize = UpdateNameOnlyGlowSize

            f:UpdateNameOnlyGlowSize()
        end
    end

    function core:NameOnlyUpdateFunctions(f)
        -- update elements affected by nameonly
        f:UpdateNameText()
        f:UpdateHealthText()
        f:UpdateFrameGlow()
        f:UpdateStateIcon()
        f:UpdateRaidIcon()
        f:UpdateCastBar()
        f:UpdateGuildText()

        if f.TargetArrows then
            f:UpdateTargetArrows()
        end
        if f.ThreatBrackets then
            f:UpdateThreatBrackets()
        end

        if f.NameOnlyGlow and addon.ClassPowersFrame and plugin_classpowers.enabled then
            -- force-update classpowers position (to run our post)
            plugin_classpowers:TargetUpdate()
        end
    end

    local function NameOnlyEnable(f)
        if f.IN_NAMEONLY then return end
        f.IN_NAMEONLY = true

        f.bg:Hide()
        f.HealthBar:Hide()
        f.HealthBar.fill:Hide()
        f.ThreatGlow:Hide()
        f.ThreatBrackets:Hide()

        f.NameText:SetParent(f)
        f.NameText:ClearAllPoints()
        f.NameText:SetPoint('CENTER',.5,0+FRAME_VERTICAL_OFFSET)
        f.NameText:Show()

        f.NameText.fontobject_shadow = true
        f.GuildText.fontobject_shadow = true
        f.NameText.fontobject_no_style = NAMEONLY_NO_FONT_STYLE
        f.GuildText.fontobject_no_style = NAMEONLY_NO_FONT_STYLE

        UpdateFontObject(f.NameText)
        UpdateFontObject(f.GuildText)

        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    local function NameOnlyDisable(f)
        if not f.IN_NAMEONLY then return end
        f.IN_NAMEONLY = nil

        f.NameText:SetText(f.state.name)
        f.NameText:SetTextColor(1,1,1,1)
        f.NameText:ClearAllPoints()
        f.NameText:SetParent(f.HealthBar)
        f:UpdateNameTextPosition()

        f.GuildText:SetTextColor(1,1,1,1)

        f.bg:Show()
        f.HealthBar:Show()
        f.HealthBar.fill:Show()

        -- nil fontobject overrides
        f.NameText.fontobject_shadow = nil
        f.NameText.fontobject_no_style = nil
        f.GuildText.fontobject_shadow = nil
        f.GuildText.fontobject_no_style = nil

        UpdateFontObject(f.NameText)
        UpdateFontObject(f.GuildText)

        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    function core:NameOnlySetNameTextToHealth(f)
        -- set name text colour to approximate health
        if not f.IN_NAMEONLY or not NAMEONLY_HEALTH_COLOUR then return end

        if f.state.health_cur and f.state.health_cur > 0 and
           f.state.health_max and f.state.health_max > 0
        then
            local health_len =
                strlen(f.state.name) *
                (f.state.health_cur / f.state.health_max)

            f.NameText:SetText(
                kui.utf8sub(f.state.name, 0, health_len)..
                '|cff666666'..kui.utf8sub(f.state.name, health_len+1)
            )
        end
    end
    function core:NameOnlyHealthUpdate(f)
        if NAMEONLY_DAMAGED_FRIENDS or not f.state.friend then
            self:NameOnlySetNameTextToHealth(f)
        else
            -- disable/enable based on health
            self:NameOnlyUpdate(f)
            self:NameOnlyUpdateFunctions(f)
        end
    end

    local function NameOnlyFilterFrame(f)
        if not NAMEONLY_ENABLED then return end
        -- disable on personal frame
        if f.state.personal then return end
        -- disable on target
        if not NAMEONLY_TARGET and f.state.target then return end

        if not f.state.attackable and f.state.reaction >= 4 then
            -- friendly;
            -- disable on friends in combat
            if not NAMEONLY_COMBAT_FRIENDLY and f.state.combat then
                return
            end
            if f.state.player then
                -- disable on friendly players
                if not NAMEONLY_FRIENDLY_PLAYERS then
                    return
                end
            else
                -- disable on friendly NPCs
                if not NAMEONLY_FRIENDLY_NPCS then
                    return
                end
            end
            -- disable on damaged friends
            if not NAMEONLY_DAMAGED_FRIENDS and f.state.health_deficit > 0 then
                return
            end
        else
            if f.state.reaction == 4 then
                -- neutral;
                -- disable on neutral
                if not NAMEONLY_ON_NEUTRAL then
                    return
                end
            else
                -- hostile;
                if f.state.player then
                    -- disable on hostile players
                    if not NAMEONLY_HOSTILE_PLAYERS then
                        return
                    end
                else
                    -- disable on hostile NPCS
                    if not NAMEONLY_HOSTILE_NPCS then
                        return
                    end
                end
                -- disable on attackable units
                if not NAMEONLY_ALL_ENEMIES and f.state.attackable then
                    return
                end
            end
            -- neutral & hostile;
            -- disable on damaged enemies
            if not NAMEONLY_DAMAGED_ENEMIES and f.state.health_deficit > 0 then
                return
            end
            if f.state.combat then
                -- disable on enemies in combat
                if not NAMEONLY_COMBAT_HOSTILE then
                    return
                end
                -- disable on enemies the player has threat with
                -- (and hostile players in any combat, since we can't check
                -- if they're in combat with the player)
                if not NAMEONLY_COMBAT_HOSTILE_PLAYER and
                   (f.state.threat or f.state.player)
                then
                    return
                end
            end
        end
        -- enable
        return true
    end

    function core:NameOnlyCombatUpdate(f)
        self:NameOnlyUpdate(f)
        self:NameOnlyUpdateFunctions(f)
    end
    function core:NameOnlyUpdate(f,hide)
        if not hide and NameOnlyFilterFrame(f) then
            NameOnlyEnable(f)
        else
            NameOnlyDisable(f)
        end
    end
end
-- init elements ###############################################################
function core:InitialiseElements()
    plugin_fading = addon:GetPlugin('Fading')
    plugin_classpowers = addon:GetPlugin('ClassPowers')

    -- initialise classpowers...
    self.ClassPowers = {
        on_target = self.profile.classpowers_on_target,
        icon_size = Scale(self.profile.classpowers_size),
        bar_width = Scale(self.profile.classpowers_bar_width),
        bar_height = Scale(self.profile.classpowers_bar_height),
        icon_texture = MEDIA..'combopoint-round',
        icon_sprite = MEDIA..'combopoint',
        icon_glow_texture = MEDIA..'combopoint-glow',
        cd_texture = 'interface/playerframe/classoverlay-runecooldown',
        bar_texture = BAR_TEXTURE,
        point = { 'CENTER','bg','BOTTOM',0,1 },
        colours = {
            overflow = self.profile.classpowers_colour_overflow,
            inactive = self.profile.classpowers_colour_inactive,
        }
    }

    local class = select(2,UnitClass('player'))
    if self.profile['classpowers_colour_'..strlower(class)] then
        self.ClassPowers.colours[class] = self.profile['classpowers_colour_'..strlower(class)]
    end

    local plugin_pb = addon:GetPlugin('PowerBar')
    if plugin_pb then
        -- set custom power colours
        plugin_pb.colours['MANA'] = { .30, .37, .74 }
    end

    -- initialise boss mods...
    self.BossModIcon = {
        icon_size = Scale(self.profile.bossmod_icon_size),
        icon_x_offset = self.profile.bossmod_x_offset,
        icon_y_offset = self.profile.bossmod_y_offset,
        control_visibility = self.profile.bossmod_control_visibility,
        clickthrough = self.profile.bossmod_clickthrough,
    }
end
