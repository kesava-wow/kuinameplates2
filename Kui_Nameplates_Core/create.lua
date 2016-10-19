--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- element create/update functions
-- draw layers -----------------------------------------------------------------
--
-- HealthBar/CastBar ###########################################################
-- ARTWORK
-- castbar spark = 7
-- powerbar spark = 7
-- raid icon (bar) = 6
-- target arrows = 3
-- spell shield = 2
-- health bar highlight = 1
-- spell icon = 1
-- power bar = 0
-- health bar = 0
-- cast bar = 0
--
-- Frame #######################################################################
-- ARTWORK
-- raid icon (nameonly) = 1
--
-- BACKGROUND
-- healthbar fill background = 2
-- frame background = 1
-- castbar background = 1
-- spell icon bg = 1
-- threat brackets = 0
-- frame glow = -5
-- target glow = -5
--
--------------------------------------------------------------------------------
local folder,ns=...
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local core = KuiNameplatesCore

-- frame fading plugin - called by some update functions
local plugin_fading
-- class powers plugin - called by NameOnlyUpdateFunctions
local plugin_classpowers

local MEDIA = 'interface/addons/kui_nameplates_core/media/'
local CLASS_COLOURS = {
    DEATHKNIGHT = { .90, .22, .33 },
    DEMONHUNTER = { .74, .35, .95 },
    SHAMAN      = { .10, .54, .97 },
}

-- config locals
local FRAME_WIDTH,FRAME_HEIGHT,FRAME_WIDTH_MINUS,FRAME_HEIGHT_MINUS
local FRAME_WIDTH_PERSONAL,FRAME_HEIGHT_PERSONAL
local POWER_BAR_HEIGHT,CASTBAR_HEIGHT,TARGET_GLOW_COLOUR
local FONT,FONT_STYLE,FONT_SHADOW,FONT_SIZE_NORMAL,FONT_SIZE_SMALL
local TEXT_VERTICAL_OFFSET,NAME_VERTICAL_OFFSET,BOT_VERTICAL_OFFSET
local BAR_TEXTURE,BAR_ANIMATION,SHOW_STATE_ICONS
local FADE_AVOID_NAMEONLY,FADE_UNTRACKED,FADE_AVOID_TRACKED
local CASTBAR_COLOUR,CASTBAR_UNIN_COLOUR,CASTBAR_SHOW_NAME,CASTBAR_SHOW_ICON
local SHOW_HEALTH_TEXT,SHOW_NAME_TEXT
local AURAS_ON_PERSONAL
local GUILD_TEXT_NPCS,GUILD_TEXT_PLAYERS,TITLE_TEXT_PLAYERS
local CLASS_COLOUR_FRIENDLY_NAMES,CLASS_COLOUR_ENEMY_NAMES

local HEALTH_TEXT_FRIEND_MAX,HEALTH_TEXT_FRIEND_DMG
local HEALTH_TEXT_HOSTILE_MAX,HEALTH_TEXT_HOSTILE_DMG

local FRAME_GLOW_SIZE,FRAME_GLOW_TEXTURE_INSET

-- common globals
local UnitIsUnit,UnitIsFriend,UnitIsEnemy,UnitIsPlayer,UnitCanAttack,
      UnitHealth,UnitHealthMax,UnitShouldDisplayName,strlen,strformat,    pairs,
      ipairs,floor,ceil,unpack =
      UnitIsUnit,UnitIsFriend,UnitIsEnemy,UnitIsPlayer,UnitCanAttack,
      UnitHealth,UnitHealthMax,UnitShouldDisplayName,strlen,string.format,pairs,
      ipairs,floor,ceil,unpack

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

    local function FilledBar_SetStatusBarColor(self,...)
        self:orig_SetStatusBarColor(...)
        self.fill:SetVertexColor(...)

        if self.spark then
            local col = {...}
            self.spark:SetVertexColor(
                col[1]+.3,
                col[2]+.3,
                col[3]+.3
            )
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

    function CreateStatusBar(parent,spark)
        local bar = CreateFrame('StatusBar',nil,parent)
        bar:SetStatusBarTexture(BAR_TEXTURE)
        bar:SetFrameLevel(0)

        local fill = parent:CreateTexture(nil,'BACKGROUND',nil,2)
        fill:SetTexture(BAR_TEXTURE)
        fill:SetAllPoints(bar)
        fill:SetAlpha(.2)

        bar.fill = fill

        bar.orig_SetStatusBarColor = bar.SetStatusBarColor
        bar.SetStatusBarColor = FilledBar_SetStatusBarColor

        bar.orig_Show = bar.Show
        bar.Show = FilledBar_Show

        bar.orig_Hide = bar.Hide
        bar.Hide = FilledBar_Hide

        if spark then
            local texture = bar:GetStatusBarTexture()
            local spark = bar:CreateTexture(nil,'ARTWORK',nil,7)
            spark:SetTexture('interface/addons/kui_media/t/spark')
            spark:SetWidth(8)

            spark:SetPoint('TOP',texture,'TOPRIGHT',-1,4)
            spark:SetPoint('BOTTOM',texture,'BOTTOMRIGHT',-1,-4)

            bar.spark = spark

            bar:HookScript('OnValueChanged',FadeSpark)
            bar:HookScript('OnMinMaxChanged',FadeSpark)
        end

        return bar
    end
end
local function GetClassColour(f)
    -- return adjusted class colour (used in nameonly)
    local class = select(2,UnitClass(f.unit))
    if CLASS_COLOURS[class] then
        return unpack(CLASS_COLOURS[class])
    else
        return kui.GetClassColour(class,2)
    end
end
local function UpdateFontObject(object)
    if not object then return end
    object:SetFont(
        FONT,
        object.fontobject_small and FONT_SIZE_SMALL or FONT_SIZE_NORMAL,
        FONT_STYLE
    )

    if FONT_SHADOW then
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
    function core:SetLocals()
        -- set config locals to reduce table lookup
        BAR_TEXTURE = LSM:Fetch(LSM.MediaType.STATUSBAR,self.profile.bar_texture)
        BAR_ANIMATION = ANIM_ASSOC[self.profile.bar_animation]

        TARGET_GLOW_COLOUR = self.profile.target_glow_colour

        FRAME_WIDTH = self.profile.frame_width
        FRAME_HEIGHT = self.profile.frame_height
        FRAME_WIDTH_MINUS = self.profile.frame_width_minus
        FRAME_HEIGHT_MINUS = self.profile.frame_height_minus
        FRAME_WIDTH_PERSONAL = self.profile.frame_width_personal
        FRAME_HEIGHT_PERSONAL = self.profile.frame_height_personal
        POWER_BAR_HEIGHT = self.profile.powerbar_height

        FRAME_GLOW_SIZE = self.profile.frame_glow_size
        FRAME_GLOW_TEXTURE_INSET = .01 * (FRAME_GLOW_SIZE / 4)

        CASTBAR_HEIGHT = self.profile.castbar_height
        CASTBAR_COLOUR = self.profile.castbar_colour
        CASTBAR_UNIN_COLOUR = self.profile.castbar_unin_colour
        CASTBAR_SHOW_ICON = self.profile.castbar_icon
        CASTBAR_SHOW_NAME = self.profile.castbar_name

        TEXT_VERTICAL_OFFSET = self.profile.text_vertical_offset
        NAME_VERTICAL_OFFSET = TEXT_VERTICAL_OFFSET + self.profile.name_vertical_offset
        BOT_VERTICAL_OFFSET = TEXT_VERTICAL_OFFSET + self.profile.bot_vertical_offset

        FONT = LSM:Fetch(LSM.MediaType.FONT,self.profile.font_face)
        FONT_STYLE = FONT_STYLE_ASSOC[self.profile.font_style]
        FONT_SHADOW = self.profile.font_style == 3 or self.profile.font_style == 4
        FONT_SIZE_NORMAL = self.profile.font_size_normal
        FONT_SIZE_SMALL = self.profile.font_size_small

        FADE_AVOID_NAMEONLY = self.profile.fade_avoid_nameonly
        FADE_UNTRACKED = self.profile.fade_untracked
        FADE_AVOID_TRACKED = self.profile.fade_avoid_tracked

        SHOW_STATE_ICONS = self.profile.state_icons

        SHOW_HEALTH_TEXT = self.profile.health_text
        SHOW_NAME_TEXT = self.profile.name_text
        CLASS_COLOUR_FRIENDLY_NAMES = self.profile.class_colour_friendly_names
        CLASS_COLOUR_ENEMY_NAMES = self.profile.class_colour_enemy_names
        HEALTH_TEXT_FRIEND_MAX = self.profile.health_text_friend_max
        HEALTH_TEXT_FRIEND_DMG = self.profile.health_text_friend_dmg
        HEALTH_TEXT_HOSTILE_MAX = self.profile.health_text_hostile_max
        HEALTH_TEXT_HOSTILE_DMG = self.profile.health_text_hostile_dmg

        AURAS_ON_PERSONAL = self.profile.auras_on_personal

        GUILD_TEXT_NPCS = self.profile.guild_text_npcs
        GUILD_TEXT_PLAYERS = self.profile.guild_text_players
        TITLE_TEXT_PLAYERS = self.profile.title_text_players
    end
end
function core:configChangedFrameSize()
    for k,f in addon:Frames() do
        f:UpdateCastbarSize()

        if f.Auras and f.Auras.frames and f.Auras.frames.core_dynamic then
            -- force auras frame size update
            f.Auras.frames.core_dynamic.__width = nil
        end
    end
end
function core:configChangedTextOffset()
    for k,f in addon:Frames() do
        f:UpdateNameTextPosition()
        f:UpdateSpellNamePosition()

        if f.Auras and f.Auras.frames and f.Auras.frames.core_dynamic then
            -- update aura text
            for _,button in pairs(f.Auras.frames.core_dynamic.buttons) do
                self.Auras_PostCreateAuraButton(button)
            end
        end
    end
end
function core:configChangedTargetArrows()
    for k,f in addon:Frames() do
        if self.profile.target_arrows then
            if f.TargetArrows then
                f.TargetArrows:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
                f.TargetArrows:SetSize(self.profile.target_arrows_size)
            else
                self:CreateTargetArrows(f)
            end
        end
    end
end
function core:configChangedCombatAction()
    self.CombatToggle = {
        hostile = self.profile.combat_hostile,
        friendly = self.profile.combat_friendly
    }
end
do
    function core.AurasButton_SetFont(button)
        UpdateFontObject(button.cd)
        UpdateFontObject(button.count)
    end
    function core:configChangedFontOption()
        -- update font objects
        for i,f in addon:Frames() do
            UpdateFontObject(f.NameText)
            UpdateFontObject(f.GuildText)
            UpdateFontObject(f.SpellName)
            UpdateFontObject(f.HealthText)
            UpdateFontObject(f.LevelText)

            if f.Auras and f.Auras.frames and f.Auras.frames.core_dynamic then
                for _,button in pairs(f.Auras.frames.core_dynamic.buttons) do
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
        for i,f in addon:Frames() do
            UpdateStatusBar(f.CastBar)
            UpdateStatusBar(f.Highlight)
            UpdateStatusBar(f.HealthBar)
            UpdateStatusBar(f.PowerBar)
        end

        if addon.ClassPowersFrame then
            UpdateStatusBar(addon.ClassPowersFrame.bar)
            self.ClassPowers.bar_texture = BAR_TEXTURE
        end
    end
end
function core:SetBarAnimation()
    for i,f in addon:Frames() do
        f.handler:SetBarAnimation(f.HealthBar,BAR_ANIMATION)
        f.handler:SetBarAnimation(f.PowerBar,BAR_ANIMATION)
    end
end
-- #############################################################################
-- create/update functions #####################################################
-- frame background ############################################################
local function UpdateFrameSize(f)
    -- set frame size and position
    if f.state.minus then
        f.bg:SetSize(FRAME_WIDTH_MINUS,FRAME_HEIGHT_MINUS)
    elseif f.state.player then
        f.bg:SetSize(FRAME_WIDTH_PERSONAL,FRAME_HEIGHT_PERSONAL)
    else
        f.bg:SetSize(FRAME_WIDTH,FRAME_HEIGHT)
    end

    if f.state.no_name and not f.state.player then
        f.bg:SetHeight(FRAME_HEIGHT_MINUS)
    end

    -- calculate point to remain pixel-perfect
    f.x = floor((addon.width / 2) - (f.bg:GetWidth() / 2))
    f.y = floor((addon.height / 2) - (f.bg:GetHeight() / 2))

    f.bg:SetPoint('BOTTOMLEFT',f.x,f.y)

    f:UpdateMainBars()
    f:SpellIconSetWidth()
    f:UpdateAuras()
end
function core:CreateBackground(f)
    local bg = f:CreateTexture(nil,'BACKGROUND',nil,1)
    bg:SetTexture(kui.m.t.solid)
    bg:SetVertexColor(0,0,0,.9)

    f.bg = bg
    f.UpdateFrameSize = UpdateFrameSize
end
-- highlight ###################################################################
function core:CreateHighlight(f)
    local highlight = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,1)
    highlight:SetTexture(BAR_TEXTURE)
    highlight:SetAllPoints(f.HealthBar)
    highlight:SetVertexColor(1,1,1,.4)
    highlight:SetBlendMode('ADD')
    highlight:Hide()

    f.handler:RegisterElement('Highlight',highlight)
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
        if  f.state.player and
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
-- name text ###################################################################
do
    local function UpdateNameText(f)
        if f.IN_NAMEONLY then
            if TITLE_TEXT_PLAYERS then
                -- override name with title
                f.state.name = UnitPVPName(f.unit) or UnitName(f.unit)
                f.NameText:SetText(f.state.name)
            end

            f.NameText:Show()

            if not UnitCanAttack('player',f.unit) and
               f.state.reaction >= 4
            then
                -- friendly colour
                f.NameText:SetTextColor(.6,1,.6)
                f.GuildText:SetTextColor(.8,.9,.8,.9)
            else
                f.NameText:SetTextColor(1,.4,.3)
                f.GuildText:SetTextColor(1,.8,.7,.9)
            end

            if UnitIsPlayer(f.unit) then
                -- player class colour
                f.NameText:SetTextColor(GetClassColour(f))
            end

            -- set name text colour to health
            core:NameOnlySetNameTextToHealth(f)
        elseif SHOW_NAME_TEXT then
            if TITLE_TEXT_PLAYERS then
                -- reset name to title-less
                f.handler:UpdateName()
            end

            -- white name text by default
            f.NameText:SetTextColor(1,1,1,1)

            if not f.state.player and UnitIsPlayer(f.unit) then
                if f.state.friend then
                    if CLASS_COLOUR_FRIENDLY_NAMES then
                        f.NameText:SetTextColor(GetClassColour(f))
                    end
                elseif CLASS_COLOUR_ENEMY_NAMES then
                    f.NameText:SetTextColor(GetClassColour(f))
                end
            end

            if f.state.no_name then
                f.NameText:Hide()
            else
                f.NameText:Show()
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
        if not core.profile.level_text or f.state.minus or f.state.player then
            f.LevelText:Hide()
        else
            f.LevelText:ClearAllPoints()

            if f.state.no_name then
                f.LevelText:SetPoint('LEFT',3,TEXT_VERTICAL_OFFSET)
            else
                f.LevelText:SetPoint('BOTTOMLEFT',3,BOT_VERTICAL_OFFSET)
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
    local function GetHealthDisplay(f,key)
        if type(key) ~= 'number' or key >= 5 or key <= 0 then return '' end

        if key == 1 then
            return kui.num(f.state.health_cur)
        elseif key == 2 then
            return kui.num(f.state.health_max)
        elseif key == 3 then
            local v = f.state.health_per
            if v < 1 then
                return strformat('%.1f', v)
            else
                return ceil(v)
            end
        else
            return '-'..kui.num(f.state.health_deficit)
        end
    end

    local function UpdateHealthText(f)
        if f.IN_NAMEONLY then return end
        if not SHOW_HEALTH_TEXT or f.state.minus or f.state.player then
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
                f.HealthText:SetPoint('RIGHT',-3,TEXT_VERTICAL_OFFSET)
            else
                f.HealthText:SetPoint('BOTTOMRIGHT',-3,BOT_VERTICAL_OFFSET)
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
    -- frame glow texture coords (assuming a size of 0)
    local glow_coords = {
        { .03, .97,  0,  .24 }, -- top
        { .03, .97, .76,  1 },  -- bottom
        {  0,  .04,  0,   1 },  -- left
        { .96,  1,   0,   1 }   -- right
    }
    -- frame glow prototype
    local glow_prototype = {}
    glow_prototype.__index = glow_prototype
    function glow_prototype:SetVertexColor(...)
        for _,side in ipairs(self.sides) do
            side:SetVertexColor(...)
        end
    end
    function glow_prototype:Show(...)
        for _,side in ipairs(self.sides) do
            side:Show(...)
        end
    end
    function glow_prototype:Hide(...)
        for _,side in ipairs(self.sides) do
            side:Hide(...)
        end
    end
    function glow_prototype:SetSize(...)
        local size = ...
        if not tonumber(size) then return end

        for i,side in ipairs(self.sides) do
            if i > 2 then
                side:SetTexCoord(unpack(glow_coords[i]))
                side:SetWidth(...)
            else
                side:SetTexCoord(
                    glow_coords[i][1] + FRAME_GLOW_TEXTURE_INSET,
                    glow_coords[i][2] - FRAME_GLOW_TEXTURE_INSET,
                    glow_coords[i][3],
                    glow_coords[i][4]
                )
                side:SetHeight(...)
            end
        end
    end
    function glow_prototype:SetAlpha(...)
        for _,side in ipairs(self.sides) do
            side:SetAlpha(...)
        end
    end

    -- update
    local function UpdateFrameGlow(f)
        if f.IN_NAMEONLY then
            f.ThreatGlow:Hide()
            f.TargetGlow:Hide()

            if f.NameOnlyGlow then
                if f.state.target and core.profile.target_glow then
                    f.NameOnlyGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
                    f.NameOnlyGlow:SetAlpha(.8)
                    f.NameOnlyGlow:Show()
                elseif f.state.glowing then
                    f.NameOnlyGlow:SetVertexColor(unpack(f.state.glow_colour))
                    f.NameOnlyGlow:SetAlpha(.6)
                    f.NameOnlyGlow:Show()
                else
                    f.NameOnlyGlow:Hide()
                end
            end

            return
        end

        if f.NameOnlyGlow then
            f.NameOnlyGlow:Hide()
        end

        f.ThreatGlow:Show()

        if f.state.target and core.profile.target_glow then
            -- target glow colour
            f.ThreatGlow:SetAlpha(1)
            f.ThreatGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))

            f.TargetGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
            f.TargetGlow:Show()
        else
            if f.state.glowing then
                -- threat glow colour
                f.ThreatGlow:SetAlpha(1)
                f.ThreatGlow:SetVertexColor(unpack(f.state.glow_colour))
            else
                if core.profile.glow_as_shadow then
                    -- shadow
                    f.ThreatGlow:SetVertexColor(0,0,0,.6)
                else
                    f.ThreatGlow:SetVertexColor(0,0,0,0)
                end
            end

            f.TargetGlow:Hide()
        end
    end
    -- create
    function core:CreateFrameGlow(f)
        local glow = { sides = {} }
        setmetatable(glow,glow_prototype)

        for i=1,4 do
            side = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            side:SetTexture(MEDIA..'frameglow')
            -- texcoord set by SetSize

            tinsert(glow.sides,side)
        end

        glow:SetSize(FRAME_GLOW_SIZE)

        glow.sides[1]:SetPoint('BOTTOMLEFT', f.bg, 'TOPLEFT', 1, -1)
        glow.sides[1]:SetPoint('BOTTOMRIGHT', f.bg, 'TOPRIGHT', -1, -1)

        glow.sides[2]:SetPoint('TOPLEFT', f.bg, 'BOTTOMLEFT', 1, 1)
        glow.sides[2]:SetPoint('TOPRIGHT', f.bg, 'BOTTOMRIGHT', -1, 1)

        glow.sides[3]:SetPoint('TOPRIGHT', glow.sides[1], 'TOPLEFT')
        glow.sides[3]:SetPoint('BOTTOMRIGHT', glow.sides[2], 'BOTTOMLEFT')

        glow.sides[4]:SetPoint('TOPLEFT', glow.sides[1], 'TOPRIGHT')
        glow.sides[4]:SetPoint('BOTTOMLEFT', glow.sides[2], 'BOTTOMRIGHT')

        f.handler:RegisterElement('ThreatGlow',glow)

        f.UpdateFrameGlow = UpdateFrameGlow
    end
end
-- target glow #################################################################
-- updated by UpdateFrameGlow
function core:CreateTargetGlow(f)
    local targetglow = f:CreateTexture(nil,'BACKGROUND',nil,-5)
    targetglow:SetTexture(MEDIA..'target-glow')
    targetglow:SetTexCoord(0,.593,0,.875)
    targetglow:SetHeight(7)
    targetglow:SetPoint('TOPLEFT',f.bg,'BOTTOMLEFT',0,2)
    targetglow:SetPoint('TOPRIGHT',f.bg,'BOTTOMRIGHT')
    targetglow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
    targetglow:Hide()

    f.TargetGlow = targetglow
end
-- target arrows ###############################################################
do
    local function UpdateTargetArrows(f)
        if f.IN_NAMEONLY or not core.profile.target_arrows then
            f.TargetArrows:Hide()
            return
        end

        if f.state.target then
            f.TargetArrows:Show()
        else
            f.TargetArrows:Hide()
        end
    end
    function core:CreateTargetArrows(f)
        if not self.profile.target_arrows then
            return
        end

        local arrows = {}
        function arrows:Hide()
            self.l:Hide()
            self.r:Hide()
        end
        function arrows:Show()
            self.l:Show()
            self.r:Show()
        end
        function arrows:SetVertexColor(...)
            self.l:SetVertexColor(...)
            self.r:SetVertexColor(...)
        end
        function arrows:SetSize(size)
            self.l:SetSize(size*.72,size)
            self.l:SetPoint('RIGHT',f.bg,'LEFT',  3+(size*.12),-1)

            self.r:SetSize(size*.72,size)
            self.r:SetPoint('LEFT',f.bg,'RIGHT', -3-(size*.12),-1)
        end

        local left = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,3)
        left:SetTexture(MEDIA..'target-arrow')
        left:SetTexCoord(0,.72,0,1)
        arrows.l = left

        local right = f.HealthBar:CreateTexture(nil,'ARTWORK',nil,3)
        right:SetTexture(MEDIA..'target-arrow')
        right:SetTexCoord(.72,0,0,1)
        arrows.r = right

        arrows:SetSize(core.profile.target_arrows_size)
        arrows:SetVertexColor(unpack(TARGET_GLOW_COLOUR))

        f.TargetArrows = arrows
        f.UpdateTargetArrows = UpdateTargetArrows
    end
end
-- castbar #####################################################################
do
    local function SpellIconSetWidth(f)
        -- set spell icon width (based on height)
        -- this seems to convince it to calculate the actual height
        f.SpellIcon.bg:SetHeight(1)
        f.SpellIcon.bg:SetWidth(floor(f.SpellIcon.bg:GetHeight()*1.25))
    end
    local function ShowCastBar(f)
        if not f.elements.CastBar then
            -- keep attached elements hidden
            f:HideCastBar()
            return
        end

        if f.cast_state.interruptible then
            f.CastBar:SetStatusBarColor(unpack(CASTBAR_COLOUR))
        else
            f.CastBar:SetStatusBarColor(unpack(CASTBAR_UNIN_COLOUR))
        end

        -- also show attached elements
        f.CastBar.bg:Show()

        if CASTBAR_SHOW_ICON then
            f.SpellIcon.bg:Show()
        end

        if CASTBAR_SHOW_NAME then
            f.SpellName:Show()
        end

        f:SpellIconSetWidth()
    end
    local function HideCastBar(f)
        -- also hide attached elements
        f.CastBar:Hide()
        f.CastBar.bg:Hide()
        f.SpellIcon.bg:Hide()
        f.SpellName:Hide()
        f.SpellShield:Hide()
    end
    local function UpdateCastBar(f)
        if f.IN_NAMEONLY then
            f.handler:DisableElement('CastBar')
        else
            if CASTBAR_SHOW_ICON then
                f.SpellIcon:Show()
            else
                f.SpellIcon:Hide()
            end

            if f.state.player then
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
        f.SpellName:SetPoint('TOP',f.CastBar,'BOTTOM',0,-2+TEXT_VERTICAL_OFFSET)
    end
    local function UpdateCastbarSize(f)
        f.CastBar.bg:SetHeight(CASTBAR_HEIGHT)
        f.CastBar:SetHeight(CASTBAR_HEIGHT-2)
        f.CastBar.spark:SetHeight(CASTBAR_HEIGHT+4)
    end
    function core:CreateCastBar(f)
        local bg = f:CreateTexture(nil,'BACKGROUND',nil,1)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)
        bg:SetPoint('TOPLEFT', f.bg, 'BOTTOMLEFT', 0, -1)
        bg:SetPoint('TOPRIGHT', f.bg, 'BOTTOMRIGHT')

        local castbar = CreateFrame('StatusBar', nil, f)
        castbar:SetFrameLevel(0)
        castbar:SetStatusBarTexture(BAR_TEXTURE)
        castbar:SetPoint('TOPLEFT', bg, 1, -1)
        castbar:SetPoint('BOTTOMRIGHT', bg, -1, 1)

        local spellname = CreateFontString(f.HealthBar,FONT_SIZE_SMALL)
        spellname:SetWordWrap()

        -- spell icon
        local spelliconbg = f:CreateTexture(nil, 'BACKGROUND', nil, 1)
        spelliconbg:SetTexture(kui.m.t.solid)
        spelliconbg:SetVertexColor(0,0,0,.8)
        spelliconbg:SetPoint('BOTTOMRIGHT', bg, 'BOTTOMLEFT', -1, 0)
        spelliconbg:SetPoint('TOPRIGHT', f.bg, 'TOPLEFT', -1, 0)

        local spellicon = castbar:CreateTexture(nil, 'ARTWORK', nil, 1)
        spellicon:SetTexCoord(.1, .9, .2, .8)
        spellicon:SetPoint('TOPLEFT', spelliconbg, 1, -1)
        spellicon:SetPoint('BOTTOMRIGHT', spelliconbg, -1, 1)

        if not CASTBAR_SHOW_ICON then
            spellicon:Hide()
        end

        -- cast shield
        local spellshield = f.HealthBar:CreateTexture(nil, 'ARTWORK', nil, 2)
        spellshield:SetTexture(MEDIA..'Shield')
        spellshield:SetTexCoord(0, .84375, 0, 1)
        spellshield:SetSize(13.5, 16) -- 16 * .84375
        spellshield:SetPoint('LEFT', bg, -7, 0)
        spellshield:SetVertexColor(.5, .5, .7)

        -- spark
        local spark = castbar:CreateTexture(nil, 'ARTWORK', nil, 7)
        spark:SetVertexColor(1,1,.8)
        spark:SetTexture('Interface\\AddOns\\Kui_Media\\t\\spark')
        spark:SetPoint('CENTER', castbar:GetRegions(), 'RIGHT', 1, 0)
        spark:SetWidth(6)

        -- hide elements by default
        bg:Hide()
        castbar:Hide()
        spelliconbg:Hide()
        spellshield:Hide()
        spellname:Hide()

        castbar.bg = bg
        castbar.spark = spark
        spellicon.bg = spelliconbg

        f.handler:RegisterElement('CastBar', castbar)
        f.handler:RegisterElement('SpellName', spellname)
        f.handler:RegisterElement('SpellIcon', spellicon)
        f.handler:RegisterElement('SpellShield', spellshield)

        f.ShowCastBar = ShowCastBar
        f.HideCastBar = HideCastBar
        f.UpdateCastBar = UpdateCastBar
        f.SpellIconSetWidth = SpellIconSetWidth
        f.UpdateSpellNamePosition = UpdateSpellNamePosition
        f.UpdateCastbarSize = UpdateCastbarSize

        f:UpdateSpellNamePosition()
        f:UpdateCastbarSize()
    end
end
-- state icons #################################################################
do
    local BOSS = {0,.5,0,.5}
    local RARE = {.5,1,.5,1}

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
    function core:CreateStateIcon(f)
        local stateicon = f:CreateTexture(nil,'ARTWORK',nil,2)
        stateicon:SetTexture(MEDIA..'state-icons')
        stateicon:SetSize(20,20)
        stateicon:SetPoint('LEFT',f.HealthBar,'BOTTOMLEFT',0,1)

        f.StateIcon = stateicon
        f.UpdateStateIcon = UpdateStateIcon
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
    local AURAS_NORMAL_SIZE
    local AURAS_MINUS_SIZE
    local AURAS_MIN_LENGTH
    local AURAS_MAX_LENGTH
    local AURAS_CENTRED

    local function AuraFrame_SetFrameWidth(self)
        self:SetWidth(self.__width)
        self:SetPoint(
            'BOTTOMLEFT',
            self.parent.bg,
            'TOPLEFT',
            floor((self.parent.bg:GetWidth() - self.__width) / 2),
            15
        )
    end
    local function AuraFrame_SetDesiredWidth(self)
        if AURAS_CENTRED and
           self.visible and
           self.visible < self.num_per_row
        then
            self.__width = (self.size * self.visible) + ((1 * self.visible) - 1)
        else
            self.__width = (self.size * self.num_per_row) + (self.num_per_row - 1)
        end

        AuraFrame_SetFrameWidth(self)
    end
    local function AuraFrame_SetIconSize(self,minus)
        local size = minus and AURAS_MINUS_SIZE or AURAS_NORMAL_SIZE

        if self.__width and self.size == size then
            return
        end

        self.size = size
        self.num_per_row = minus and 4 or 5

        -- re-set frame width
        AuraFrame_SetDesiredWidth(self)
        AuraFrame_SetFrameWidth(self)

        -- resize & re-arrange buttons
        self:SetIconSize(size)
    end

    local function UpdateAuras(f)
        -- enable/disable on personal frame
        if not AURAS_ON_PERSONAL and f.state.player then
            f.Auras.frames.core_dynamic:Disable()
        else
            f.Auras.frames.core_dynamic:Enable(true)
        end

        -- set auras to normal/minus sizes
        AuraFrame_SetIconSize(f.Auras.frames.core_dynamic,f.state.minus)
    end
    function core:CreateAuras(f)
        local auras = f.handler:CreateAuraFrame({
            id = 'core_dynamic',
            max = 10,
            point = {'BOTTOMLEFT','LEFT','RIGHT'},
            x_spacing = 1,
            y_spacing = 1,
            rows = 2,

            vanilla_filter = self.profile.auras_vanilla_filter,
            kui_whitelist = self.profile.auras_whitelist,
            pulsate = self.profile.auras_pulsate,
            timer_threshold = self.profile.auras_time_threshold > 0 and self.profile.auras_time_threshold or nil,
            squareness = self.profile.auras_icon_squareness,
            sort = self.profile.auras_sort,
        })
        -- initial icon size set by AuraFrame_SetIconSize < UpdateAuras
        -- frame width & point set by AuraFrame_SetFrameWidth < _SetIconSize

        auras:SetFrameLevel(0)
        auras:SetHeight(10)

        f.UpdateAuras = UpdateAuras
    end

    -- callbacks
    function core.Auras_PostCreateAuraButton(button)
        -- move text to obey our settings
        button.cd:ClearAllPoints()
        button.cd:SetPoint('TOPLEFT',-2,2+TEXT_VERTICAL_OFFSET)
        button.cd:SetShadowOffset(1,-1)
        button.cd:SetShadowColor(0,0,0,1)

        button.count:ClearAllPoints()
        button.count:SetPoint('BOTTOMRIGHT',4,-2+TEXT_VERTICAL_OFFSET)
        button.count:SetShadowOffset(1,-1)
        button.count:SetShadowColor(0,0,0,1)

        core.AurasButton_SetFont(button)
    end
    function core.Auras_PostUpdateAuraFrame(frame)
        if frame.id == 'core_dynamic' and AURAS_CENTRED then
            -- with auras centred, we need to update the frame size each time a
            -- new button is made visible
            AuraFrame_SetDesiredWidth(frame)
            AuraFrame_SetFrameWidth(frame)
        end
    end
    function core.Auras_DisplayAura(name,spellid,duration)
        if  AURAS_MIN_LENGTH and
            duration ~= 0 and duration <= AURAS_MIN_LENGTH
        then
            return false
        end

        if  AURAS_MAX_LENGTH and
            (duration == 0 or duration > AURAS_MAX_LENGTH)
        then
            return false
        end

        return true
    end

    -- config changed
    function core:SetAurasConfig()
        AURAS_MIN_LENGTH = self.profile.auras_minimum_length
        if AURAS_MIN_LENGTH == 0 then
            AURAS_MIN_LENGTH = nil
        end

        AURAS_MAX_LENGTH = self.profile.auras_maximum_length
        if AURAS_MAX_LENGTH == -1 then
            AURAS_MAX_LENGTH = nil
        end

        AURAS_NORMAL_SIZE = self.profile.auras_icon_normal_size
        AURAS_MINUS_SIZE = self.profile.auras_icon_minus_size
        AURAS_CENTRED = self.profile.auras_centre

        local timer_threshold = self.profile.auras_time_threshold
        if timer_threshold < 0 then
            timer_threshold = nil
        end

        for k,f in addon:Frames() do
            if f.Auras and f.Auras.frames then
                local af = f.Auras.frames.core_dynamic

                if af then
                    af.pulsate = self.profile.auras_pulsate
                    af.timer_threshold = timer_threshold
                    af.squareness = self.profile.auras_icon_squareness
                    af.vanilla_filter = self.profile.auras_vanilla_filter

                    af:SetSort(self.profile.auras_sort)
                    af:SetWhitelist(nil,self.profile.auras_whitelist)

                    -- force size update
                    af.__width = nil
                end
            end
        end
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
    elseif parent.state.player then
        cpf:ClearAllPoints()
        cpf:SetPoint('CENTER',parent.HealthBar,'TOP',0,1)
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
do
    local orig_SetVertexColor,orig_Active,orig_Inactive,orig_ActiveOverflow,
          orig_Hide

    local function Icon_SetVertexColor(icon,...)
        -- also set glow colour
        icon.glow:SetVertexColor(...)
        icon.glow:SetAlpha(.8)

        orig_SetVertexColor(icon,...)
    end
    local function Icon_Active(icon)
        orig_Active(icon)
        icon.glow:Show()
    end
    local function Icon_Inactive(icon)
        orig_Inactive(icon)
        icon.glow:Hide()
    end
    local function Icon_ActiveOverflow(icon)
        orig_ActiveOverflow(icon)
        icon.glow:Show()
    end
    local function Icon_Hide(icon)
        orig_Hide(icon)
        icon.glow:Hide()
    end

    function core.ClassPowers_PostCreateIcon(icon)
        -- add icon glow
        local ig = addon.ClassPowersFrame:CreateTexture(nil,'ARTWORK',nil,0)
        ig:SetTexture(MEDIA..'combopoint-glow')
        ig:SetPoint('TOPLEFT',icon,-5,5)
        ig:SetPoint('BOTTOMRIGHT',icon,5,-5)
        ig:SetVertexColor(icon:GetVertexColor())
        ig:Hide()

        icon.glow = ig

        -- function overloads
        orig_Hide = icon.Hide
        orig_Active = icon.Active
        orig_Inactive = icon.Inactive
        orig_ActiveOverflow = icon.ActiveOverflow
        orig_SetVertexColor = icon.SetVertexColor

        icon.Hide = Icon_Hide
        icon.Active = Icon_Active
        icon.Inactive = Icon_Inactive
        icon.ActiveOverflow = Icon_ActiveOverflow
        icon.SetVertexColor = Icon_SetVertexColor
    end
end
function core.ClassPowers_PostRuneUpdate(icon)
    if icon.cd:IsShown() then
        icon.glow:Hide()
    else
        icon.glow:Show()
    end
end
-- threat brackets #############################################################
do
    local TB_TEXTURE = MEDIA..'threat-bracket'
    local TB_PIXEL_LEFTMOST = .28125
    local TB_RATIO = 2
    local TB_HEIGHT = 18
    local TB_WIDTH = TB_HEIGHT * TB_RATIO
    local TB_X_OFFSET = floor((TB_WIDTH * TB_PIXEL_LEFTMOST)-1)
    local TB_POINTS = {
        { 'BOTTOMLEFT', 'TOPLEFT',    -TB_X_OFFSET,  1.3 },
        { 'BOTTOMRIGHT','TOPRIGHT',    TB_X_OFFSET,  1.3 },
        { 'TOPLEFT',    'BOTTOMLEFT', -TB_X_OFFSET, -1.5 },
        { 'TOPRIGHT',   'BOTTOMRIGHT', TB_X_OFFSET, -1.5 }
    }
    -- threat bracket prototype
    local tb_prototype = {}
    tb_prototype.__index = tb_prototype
    function tb_prototype:SetVertexColor(...)
        for k,v in ipairs(self.textures) do
            v:SetVertexColor(...)
        end
    end
    function tb_prototype:Show(...)
        for k,v in ipairs(self.textures) do
            v:Show(...)
        end
    end
    function tb_prototype:Hide(...)
        for k,v in ipairs(self.textures) do
            v:Hide(...)
        end
    end
    -- update
    local function UpdateThreatBrackets(f)
        if not core.profile.threat_brackets or f.IN_NAMEONLY then
            f.ThreatBrackets:Hide()
            return
        end

        if f.state.glowing then
            f.ThreatBrackets:SetVertexColor(unpack(f.state.glow_colour))
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
            b:SetSize(TB_WIDTH, TB_HEIGHT)
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
        f.IN_NAMEONLY
    then
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
        f.state.no_name = true
    end

    if not core.profile.hide_names then
        f.state.no_name = nil
    end

    if f.state.player or
       not SHOW_NAME_TEXT
    then
        f.state.no_name = true
    end

    if FADE_UNTRACKED or FADE_AVOID_TRACKED then
        plugin_fading:UpdateFrame(f)
    end
end
-- nameonly ####################################################################
do
    local NAMEONLY_NO_FONT_STYLE,NAMEONLY_ENEMIES,NAMEONLY_DAMAGED_FRIENDS,
    NAMEONLY_ALL_ENEMIES,NAMEONLY_TARGET

    function core:configChangedNameOnly()
        NAMEONLY_NO_FONT_STYLE = self.profile.nameonly_no_font_style
        NAMEONLY_DAMAGED_FRIENDS = self.profile.nameonly_damaged_friends
        NAMEONLY_ALL_ENEMIES = self.profile.nameonly_all_enemies
        NAMEONLY_ENEMIES = NAMEONLY_ALL_ENEMIES or self.profile.nameonly_enemies
        NAMEONLY_TARGET = self.profile.nameonly_target

        if NAMEONLY_ALL_ENEMIES or NAMEONLY_TARGET then
            -- create target/threat glow
            for k,f in addon:Frames() do
                core:CreateNameOnlyGlow(f)
            end
        end
    end

    do
        local function UpdateNameOnlyGlowSize(f)
            local g = f.NameOnlyGlow
            if not g then return end

            g:SetPoint('TOPLEFT',f.NameText,
                -12-FRAME_GLOW_SIZE,  FRAME_GLOW_SIZE)
            g:SetPoint('BOTTOMRIGHT',f.NameText,
                 12+FRAME_GLOW_SIZE, -FRAME_GLOW_SIZE)
        end
        function core:CreateNameOnlyGlow(f)
            if not NAMEONLY_ALL_ENEMIES and not NAMEONLY_TARGET then return end
            if f.NameOnlyGlow then return end

            local g = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            g:SetTexture('interface/addons/kui_media/t/spark')
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
            -- show/hide arrows
            f:UpdateTargetArrows()
        end

        if f.NameOnlyGlow and addon.ClassPowersFrame then
            -- force-update classpowers position
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

        f.NameText:SetShadowOffset(1,-1)
        f.NameText:SetShadowColor(0,0,0,1)
        f.NameText:SetParent(f)
        f.NameText:ClearAllPoints()
        f.NameText:SetPoint('CENTER',.5,0)
        f.NameText:Show()

        f.GuildText:SetShadowOffset(1,-1)
        f.GuildText:SetShadowColor(0,0,0,1)


        if NAMEONLY_NO_FONT_STYLE then
            f.NameText:SetFont(FONT,FONT_SIZE_NORMAL,nil)
            f.GuildText:SetFont(FONT,FONT_SIZE_SMALL,nil)
        end
        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    local function NameOnlyDisable(f)
        if not f.IN_NAMEONLY then return end
        f.IN_NAMEONLY = nil

        f.NameText:SetText(f.state.name)
        f.NameText:SetTextColor(1,1,1,1)
        f.NameText:SetShadowColor(0,0,0,0)
        f.NameText:ClearAllPoints()
        f.NameText:SetParent(f.HealthBar)
        f:UpdateNameTextPosition()

        f.GuildText:SetTextColor(1,1,1,1)
        f.GuildText:SetShadowColor(0,0,0,0)

        f.bg:Show()
        f.HealthBar:Show()
        f.HealthBar.fill:Show()

        if NAMEONLY_NO_FONT_STYLE or FONT_SHADOW then
            UpdateFontObject(f.NameText)
            UpdateFontObject(f.GuildText)
        end
        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    function core:NameOnlySetNameTextToHealth(f)
        -- set name text colour to approximate health
        if not f.IN_NAMEONLY then return end

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

    local function UnattackableEnemyPlayer(f)
        -- never activate for enemy players
        return not NAMEONLY_ALL_ENEMIES and UnitIsPlayer(f.unit) and f.state.enemy
    end
    local function EnemyAndDisabled(f)
        -- don't show on unattackble enemies
        return not NAMEONLY_ENEMIES and f.state.enemy
    end
    local function FriendAndDisabled(f)
        if not NAMEONLY_DAMAGED_FRIENDS and f.state.friend then
            if f.state.health_deficit > 0 then
                -- don't show on damaged friends
                return true
            end
        end
    end
    function core:NameOnlyUpdate(f,hide)
        if  not hide and self.profile.nameonly and
            -- don't show on player frame
            not f.state.player and
            -- don't show on target
            (NAMEONLY_TARGET or not f.state.target) and
            -- don't show on attackable units
            (NAMEONLY_ALL_ENEMIES or not UnitCanAttack('player',f.unit)) and
            -- more complex filters;
            not UnattackableEnemyPlayer(f) and
            not EnemyAndDisabled(f) and
            not FriendAndDisabled(f)
        then
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

    self:configChangedCombatAction()

    self.Auras = {}

    self.ClassPowers = {
        on_target = self.profile.classpowers_on_target,
        icon_size = self.profile.classpowers_size or 10,
        bar_width = self.profile.classpowers_bar_width,
        bar_height = self.profile.classpowers_bar_height,
        icon_texture = MEDIA..'combopoint-round',
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
end
