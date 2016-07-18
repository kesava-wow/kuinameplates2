--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- element create/update functions
-- layers ----------------------------------------------------------------------
--
-- ARTWORK
-- spell shield = 2
-- healthbar highlight = 1
-- spell icon = 1
-- spell icon background = 0

-- BACKGROUND
-- healthbar fill background = 2
-- healthbar background = 1
-- castbar background = 1
-- threat brackets = 0
-- frame/target glow = -5
--
--------------------------------------------------------------------------------
local folder,ns=...
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local core = KuiNameplatesCore

-- frame fading plugin - called by some update functions
local plugin_fading

local MEDIA = 'interface/addons/kui_nameplates/media/'
local CLASS_COLOURS = {
    DEATHKNIGHT = { .90, .22, .33 },
    DEMONHUNTER = { .74, .35, .95 },
    SHAMAN      = { .10, .54, .97 },
}

local FRAME_WIDTH,FRAME_HEIGHT,FRAME_WIDTH_MINUS,FRAME_HEIGHT_MINUS
local CASTBAR_HEIGHT,TARGET_GLOW_COLOUR
local FONT,FONT_STYLE,FONT_SIZE_NORMAL,FONT_SIZE_SMALL
local TEXT_VERTICAL_OFFSET,NAME_VERTICAL_OFFSET,BOT_VERTICAL_OFFSET
local BAR_TEXTURE,BAR_ANIMATION
local NAMEONLY_NO_FONT_STYLE,FADE_AVOID_NAMEONLY,NAMEONLY_ENEMIES
local NAMEONLY_DAMAGED_FRIENDS,FADE_AVOID_RAIDICON

local FRAME_GLOW_SIZE = 8

-- common globals
local UnitIsUnit,UnitIsFriend,UnitIsEnemy,UnitIsPlayer,UnitCanAttack,
      UnitHealth,UnitHealthMax,strlen,pairs,ipairs,floor,unpack =
      UnitIsUnit,UnitIsFriend,UnitIsEnemy,UnitIsPlayer,UnitCanAttack,
      UnitHealth,UnitHealthMax,strlen,pairs,ipairs,floor,unpack

-- helper functions ############################################################
local CreateStatusBar
do
    local function FilledBar_SetStatusBarColor(self,...)
        self:orig_SetStatusBarColor(...)
        self.fill:SetVertexColor(...)
    end
    local function FilledBar_Show(self)
        self:orig_Show()
        self.fill:Show()
    end
    local function FilledBar_Hide(self)
        self:orig_Hide()
        self.fill:Hide()
    end
    function CreateStatusBar(parent)
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
        CASTBAR_HEIGHT = self.profile.castbar_height

        TEXT_VERTICAL_OFFSET = self.profile.text_vertical_offset
        NAME_VERTICAL_OFFSET = TEXT_VERTICAL_OFFSET + self.profile.name_vertical_offset
        BOT_VERTICAL_OFFSET = TEXT_VERTICAL_OFFSET + self.profile.bot_vertical_offset

        FONT = LSM:Fetch(LSM.MediaType.FONT,self.profile.font_face)
        FONT_STYLE = FONT_STYLE_ASSOC[self.profile.font_style]
        FONT_SIZE_NORMAL = self.profile.font_size_normal
        FONT_SIZE_SMALL = self.profile.font_size_small

        NAMEONLY_NO_FONT_STYLE = self.profile.nameonly_no_font_style
        NAMEONLY_ENEMIES = self.profile.nameonly_enemies
        NAMEONLY_DAMAGED_FRIENDS = self.profile.nameonly_damaged_friends

        FADE_AVOID_NAMEONLY = self.profile.fade_avoid_nameonly
        FADE_AVOID_RAIDICON = self.profile.fade_avoid_raidicon
    end
end
function core:configChangedFrameSize()
    for k,f in addon:Frames() do
        f:UpdateCastbarSize()

        if f.Auras and f.Auras.frames and f.Auras.frames[1] then
            -- force auras frame size update
            f.Auras.frames[1].__width = nil
        end
    end
end
function core:configChangedTextOffset()
    for k,f in addon:Frames() do
        f:UpdateNameTextPosition()
        f:UpdateSpellNamePosition()

        for _,button in pairs(f.Auras.frames[1].buttons) do
            self.Auras_PostCreateAuraButton(button)
        end
    end
end
do
    function core.AurasButton_SetFont(button)
        UpdateFontObject(button.cd)
        UpdateFontObject(button.count)
        UpdateFontObject(button.name)
    end
    function core:configChangedFontOption()
        -- update font objects
        for i,f in addon:Frames() do
            UpdateFontObject(f.NameText)
            UpdateFontObject(f.GuildText)
            UpdateFontObject(f.SpellName)
            UpdateFontObject(f.HealthText)
            UpdateFontObject(f.LevelText)

            for _,button in pairs(f.Auras.frames[1].buttons) do
                self.AurasButton_SetFont(button)
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
    bg:SetVertexColor(0,0,0,.8)

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
            hb_height = hb_height - 3
            f.PowerBar:SetHeight(2)
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
        local powerbar = CreateStatusBar(f.HealthBar)
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
        if f.state.nameonly then
            if UnitIsPlayer(f.unit) then
                -- player class colour
                f.NameText:SetTextColor(GetClassColour(f))
            else
                if f.state.reaction >= 4 then
                    -- friendly colour
                    f.NameText:SetTextColor(.6,1,.6)
                    f.GuildText:SetTextColor(.8,.9,.8,.9)
                else
                    f.NameText:SetTextColor(1,.4,.3)
                    f.GuildText:SetTextColor(1,.8,.7,.9)
                end
            end

            -- set name text colour to health
            core:NameOnlySetNameTextToHealth(f)
        else
            if  not f.state.player and
                UnitIsPlayer(f.unit) and
                f.state.friend
            then
                -- friendly player class colour
                f.NameText:SetTextColor(GetClassColour(f))
            else
                -- white by default
                f.NameText:SetTextColor(1,1,1,1)
            end

            if f.state.no_name then
                f.NameText:Hide()
            else
                f.NameText:Show()
            end
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
        if f.state.nameonly then return end
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
    local function UpdateHealthText(f)
        if f.state.nameonly then return end
        if not core.profile.health_text or f.state.minus or f.state.player then
            f.HealthText:Hide()
        else
            local cur,_,max = f.HealthBar:GetValue(),f.HealthBar:GetMinMaxValues()
            f.HealthText:SetText(kui.num(cur))
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
function core:CreateGuildText(f)
    local guildtext = CreateFontString(f,FONT_SIZE_SMALL)
    guildtext:SetPoint('TOP',f.NameText,'BOTTOM', 0, -2)
    guildtext:SetShadowOffset(1,-1)
    guildtext:SetShadowColor(0,0,0,1)
    guildtext:Hide()

    f.GuildText = guildtext
end
-- frame glow ##################################################################
do
    -- frame glow texture coords
    local glow_coords = {
        { .05, .95,  0,  .24 }, -- top
        { .05, .95, .76,  1 },  -- bottom
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
        for i,side in ipairs(self.sides) do
            if i > 2 then
                side:SetWidth(...)
            else
                side:SetHeight(...)
            end
        end
    end
    -- update
    local function UpdateFrameGlow(f)
        if f.state.nameonly then
            f.ThreatGlow:Hide()
            f.TargetGlow:Hide()
            return
        end

        f.ThreatGlow:Show()

        if f.state.target and core.profile.target_glow then
            -- target glow colour
            f.ThreatGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
            f.TargetGlow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
            f.TargetGlow:Show()
        else
            if f.state.glowing then
                -- threat glow colour
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

        for side,coords in ipairs(glow_coords) do
            side = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            side:SetTexture(MEDIA..'frameglow')
            side:SetTexCoord(unpack(coords))

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
    targetglow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-glow')
    targetglow:SetTexCoord(0,.593,0,.875)
    targetglow:SetHeight(7)
    targetglow:SetPoint('TOPLEFT',f.bg,'BOTTOMLEFT',0,2)
    targetglow:SetPoint('TOPRIGHT',f.bg,'BOTTOMRIGHT')
    targetglow:SetVertexColor(unpack(TARGET_GLOW_COLOUR))
    targetglow:Hide()

    f.TargetGlow = targetglow
end
-- castbar #####################################################################
do
    local function SpellIconSetWidth(f)
        -- set spell icon width (based on height)
        -- this seems to convice it to calculate the actual height
        f.SpellIcon.bg:SetHeight(1)
        --f.SpellIcon.bg:SetHeight(f.bg:GetHeight()+f.CastBar.bg:GetHeight()+1)
        f.SpellIcon.bg:SetWidth(floor(f.SpellIcon.bg:GetHeight()*1.5))
    end
    local function ShowCastBar(f)
        if not f.elements.CastBar then
            -- keep attached elements hidden
            f:HideCastBar()
            return
        end

        -- also show attached elements
        f.CastBar.bg:Show()
        f.SpellIcon.bg:Show()
        f.SpellName:Show()

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
        if f.state.nameonly then
            f.handler:DisableElement('CastBar')
        else
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
        castbar:SetStatusBarColor(.6, .6, .75)
        castbar:SetPoint('TOPLEFT', bg, 1, -1)
        castbar:SetPoint('BOTTOMRIGHT', bg, -1, 1)

        local spellname = CreateFontString(f.HealthBar,FONT_SIZE_SMALL)
        spellname:SetWordWrap()

        -- spell icon
        local spelliconbg = f:CreateTexture(nil, 'ARTWORK', nil, 0)
        spelliconbg:SetTexture(kui.m.t.solid)
        spelliconbg:SetVertexColor(0,0,0,.8)
        spelliconbg:SetPoint('BOTTOMRIGHT', bg, 'BOTTOMLEFT', -1, 0)
        spelliconbg:SetPoint('TOPRIGHT', f.bg, 'TOPLEFT', -1, 0)

        local spellicon = castbar:CreateTexture(nil, 'ARTWORK', nil, 1)
        spellicon:SetTexCoord(.1, .9, .25, .75)
        spellicon:SetPoint('TOPLEFT', spelliconbg, 1, -1)
        spellicon:SetPoint('BOTTOMRIGHT', spelliconbg, -1, 1)

        -- cast shield
        local spellshield = f.HealthBar:CreateTexture(nil, 'ARTWORK', nil, 2)
        spellshield:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\Shield')
        spellshield:SetTexCoord(0, .84375, 0, 1)
        spellshield:SetSize(13.5, 16) -- 16 * .84375
        spellshield:SetPoint('LEFT', bg, -7, 0)
        spellshield:SetVertexColor(.5, .5, .7)

        -- spark
        local spark = castbar:CreateTexture(nil, 'ARTWORK')
        spark:SetDrawLayer('ARTWORK', 7)
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
        if f.state.nameonly or (f.elements.LevelText and f.LevelText:IsShown()) then
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

        if f.state.nameonly then
            f.RaidIcon:SetPoint('LEFT',f.NameText,f.NameText:GetStringWidth()+2,0)
        else
            f.RaidIcon:SetPoint('LEFT',f.HealthBar,'RIGHT',5,0)
        end

        if FADE_AVOID_RAIDICON then
            plugin_fading:UpdateFrame(f)
        end
    end
    function core:CreateRaidIcon(f)
        local raidicon = f:CreateTexture(nil,'ARTWORK',nil,2)
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

    local function AuraFrame_SetFrameWidth(self)
        self:SetWidth(self.__width)
        self:SetPoint(
            'BOTTOMLEFT',
            self.parent.HealthBar,
            'TOPLEFT',
            floor((self.parent.bg:GetWidth() - self.__width) / 2),
            15
        )
    end
    local function AuraFrame_SetIconSize(self,minus)
        local size = minus and AURAS_MINUS_SIZE or AURAS_NORMAL_SIZE

        if self.__width and self.size == size then
            return
        end

        -- re-set frame vars
        self.size = size
        self.icon_height = floor(size * self.squareness)
        self.icon_ratio = (1 - (self.icon_height / size)) / 2
        self.num_per_row = minus and 4 or 5

        -- re-set frame width
        self.__width = (size * self.num_per_row) + (self.num_per_row - 1)
        AuraFrame_SetFrameWidth(self)

        if not addon.BarAuras then
            -- set buttons to new size
            for k,button in ipairs(self.buttons) do
                button:SetWidth(size)
                button:SetHeight(self.icon_height)
                button.icon:SetTexCoord(.1,.9,.1+self.icon_ratio,.9-self.icon_ratio)
            end

            if self.visible and self.visible > 0 then
                self:ArrangeButtons()
            end
        end
    end

    local function UpdateAuras(f)
        -- set auras to normal/minus sizes
        AuraFrame_SetIconSize(f.Auras.frames[1],f.state.minus)
    end
    function core:CreateAuras(f)
        local auras = f.handler:CreateAuraFrame({
            max = 10,
            point = {'BOTTOMLEFT','LEFT','RIGHT'},
            x_spacing = 1,
            y_spacing = 1,
            rows = 2,

            kui_whitelist = self.profile.auras_whitelist,
            pulsate = self.profile.auras_pulsate,
            timer_threshold = self.profile.auras_time_threshold > 0 and self.profile.auras_time_threshold or nil,
            squareness = self.profile.auras_icon_squareness
        })
        -- initial icon size set by AuraFrame_SetIconSize < UpdateAuras

        auras:SetFrameLevel(0)
        auras:SetHeight(10)

        f.UpdateAuras = UpdateAuras
    end
    function core.Auras_PostCreateAuraButton(button)
        -- move text slightly for our font
        button.cd:ClearAllPoints()
        button.cd:SetPoint('CENTER',1,TEXT_VERTICAL_OFFSET)
        button.cd:SetShadowOffset(1,-1)
        button.cd:SetShadowColor(0,0,0,1)

        button.count:ClearAllPoints()
        button.count:SetPoint('BOTTOMRIGHT',3,-2+TEXT_VERTICAL_OFFSET)
        button.count:SetShadowOffset(1,-1)
        button.count:SetShadowColor(0,0,0,1)

        if not addon.BarAuras then
            button.count.fontobject_small = true
        end

        core.AurasButton_SetFont(button)
    end
    function core.Auras_DisplayAura(name,spellid,duration)
        if AURAS_MIN_LENGTH and duration <= AURAS_MIN_LENGTH then
            return false
        end
        if AURAS_MAX_LENGTH and duration > AURAS_MAX_LENGTH then
            return false
        end

        return true
    end

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

        local timer_threshold = self.profile.auras_time_threshold
        if timer_threshold < 0 then
            timer_threshold = nil
        end

        for k,f in addon:Frames() do
            if f.Auras and f.Auras.frames and f.Auras.frames[1] then
                local af = f.Auras.frames[1]
                af.kui_whitelist = self.profile.auras_whitelist
                af.pulsate = self.profile.auras_pulsate
                af.timer_threshold = timer_threshold
                af.squareness = self.profile.auras_icon_squareness

                -- force size update
                af.__width = nil
            end
        end
    end
end
-- class powers ################################################################
function core.ClassPowers_PostPositionFrame()
    if not addon.ClassPowersFrame:IsShown() then return end
    if UnitIsUnit(addon.ClassPowersFrame:GetParent().unit,'player') then
        -- change position when on the player's nameplate
        addon.ClassPowersFrame:ClearAllPoints()
        addon.ClassPowersFrame:SetPoint(
            'CENTER',
            addon.ClassPowersFrame:GetParent().HealthBar,
            'TOP',
            0,
            1
        )
    end
end
-- threat brackets #############################################################
do
    local TB_TEXTURE = 'interface/addons/kui_nameplates/media/threat-bracket'
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
        if not core.profile.threat_brackets or f.state.nameonly then
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
    if f.state.nameonly then return end

    if f.state.player then
        f.state.no_name = true
    elseif
        not core.profile.hide_names or
        f.state.target or
        f.state.threat or
        UnitShouldDisplayName(f.unit)
    then
        f.state.no_name = nil
    else
        f.state.no_name = true
    end
end
-- nameonly ####################################################################
do
    function core:NameOnlyUpdateFunctions(f)
        -- update elements affected by nameonly
        f:UpdateNameText()
        f:UpdateHealthText()
        f:UpdateFrameGlow()
        f:UpdateStateIcon()
        f:UpdateRaidIcon()
        f:UpdateCastBar()
    end

    local function NameOnlyEnable(f)
        if f.state.nameonly then return end
        f.state.nameonly = true

        f.bg:Hide()
        f.HealthBar:Hide()
        f.HealthBar.fill:Hide()
        f.ThreatGlow:Hide()
        f.ThreatBrackets:Hide()

        f.NameText:SetShadowOffset(1,-1)
        f.NameText:SetShadowColor(0,0,0,1)

        f.NameText:ClearAllPoints()
        f.NameText:SetParent(f)

        if f.state.guild_text then
            f.GuildText:SetText(f.state.guild_text)
            f.GuildText:Show()
            f.NameText:SetPoint('CENTER',.5,6)
        else
            f.NameText:SetPoint('CENTER',.5,0)
        end

        f.NameText:Show()

        if NAMEONLY_NO_FONT_STYLE then
            f.NameText:SetFont(FONT,FONT_SIZE_NORMAL,nil)
            f.GuildText:SetFont(FONT,FONT_SIZE_SMALL,nil)
        end
        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    local function NameOnlyDisable(f)
        if not f.state.nameonly then return end
        f.state.nameonly = nil

        f.NameText:SetText(f.state.name)
        f.NameText:SetTextColor(1,1,1,1)
        f.NameText:SetShadowColor(0,0,0,0)

        f.NameText:ClearAllPoints()
        f.NameText:SetParent(f.HealthBar)
        f:UpdateNameTextPosition()

        f.GuildText:Hide()

        f.bg:Show()
        f.HealthBar:Show()
        f.HealthBar.fill:Show()

        if NAMEONLY_NO_FONT_STYLE then
            UpdateFontObject(f.NameText)
        end
        if FADE_AVOID_NAMEONLY then
            plugin_fading:UpdateFrame(f)
        end
    end
    function core:NameOnlySetNameTextToHealth(f)
        -- set name text colour to approximate health
        if not f.state.nameonly then return end

        local cur,max = UnitHealth(f.unit),UnitHealthMax(f.unit)
        if cur and cur > 0 and max and max > 0 then
            local health_len = strlen(f.state.name) * (cur / max)
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

    local function UnattackableEnemyPlayer(unit)
        -- don't show on unattackable enemy players (ice block etc)
        return UnitIsPlayer(unit) and UnitIsEnemy('player',unit)
    end
    local function EnemyAndDisabled(unit)
        if  not NAMEONLY_ENEMIES and
            UnitIsEnemy('player',unit)
        then
            -- don't show on unattackble enemies
            return true
        end
    end
    local function FriendAndDisabled(unit)
        if  not NAMEONLY_DAMAGED_FRIENDS and
            UnitIsFriend('player',unit)
        then
            if UnitHealth(unit) ~= UnitHealthMax(unit) then
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
            not f.state.target and
            -- don't show on attackable units
            not UnitCanAttack('player',f.unit) and
            -- more complex filters;
            not UnattackableEnemyPlayer(f.unit) and
            not EnemyAndDisabled(f.unit) and
            not FriendAndDisabled(f.unit)
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

    self.Auras = {}

    self.ClassPowers = {
        icon_size = 10,
        icon_texture = 'interface/addons/kui_nameplates/media/combopoint-round',
        glow_texture = 'interface/addons/kui_nameplates/media/combopoint-glow',
        cd_texture = 'interface/playerframe/classoverlay-runecooldown',
        point = { 'TOP','bg','BOTTOM',0,4 }
    }

    local plugin_pb = addon:GetPlugin('PowerBar')
    if plugin_pb then
        -- set custom power colours
        plugin_pb.colours['MANA'] = { .30, .37, .74 }
    end
end
