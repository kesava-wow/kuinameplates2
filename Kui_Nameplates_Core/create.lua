local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local test = addon:Layout()

if not test then
    -- a layout is already registered
    return
end

local FONT = kui.m.f.francois
local sizes = {
    width = 130,
    height = 11,
    trivial_width = 70,
    trivial_height = 7,
    glow = 8,
    no_name = 7
}
local x,y

local target_glow_colour = { .3, .7, 1, 1 }
-- texture coords for the frame glow
local glow_coords = {
    { .05, .95,  0,  .24 }, -- top
    { .05, .95, .76,  1 },  -- bottom
    {  0,  .04,  0,   1 },  -- left
    { .96,  1,   0,   1 }   -- right
}

-- threat brackets
local TB_TEXTURE = 'interface/addons/kui_nameplates/media/threat-bracket'
local TB_PIXEL_LEFTMOST = .28125
local TB_RATIO = 2
local TB_HEIGHT = 18
local TB_WIDTH = TB_HEIGHT * TB_RATIO
local TB_X_OFFSET = TB_WIDTH * TB_PIXEL_LEFTMOST
local TB_POINTS = {
    { 'BOTTOMLEFT', 'TOPLEFT',    -TB_X_OFFSET,    2   },
    { 'BOTTOMRIGHT','TOPRIGHT',    TB_X_OFFSET-1,  2   },
    { 'TOPLEFT',    'BOTTOMLEFT', -TB_X_OFFSET,   -2.5 },
    { 'TOPRIGHT',   'BOTTOMRIGHT', TB_X_OFFSET-1, -2.5 }
}

-- frame glow functions
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
-- healthbar background fill
local function HealthBar_SetStatusBarColor(self,...)
    self:orig_SetStatusBarColor(...)
    self.fill:SetVertexColor(...)
end
-- threat brackets texture colours
local function TB_SetVertexColor(self,...)
    for k,v in ipairs(self.textures) do
        v:SetVertexColor(...)
    end
end
local function TB_Show(self)
    for k,v in ipairs(self.textures) do
        v:Show()
    end
end
local function TB_Hide(self)
    for k,v in ipairs(self.textures) do
        v:Hide()
    end
end

local function CastBar_SpellIconSetWidth(f)
    -- set spell icon width
    f.HealthBar:GetHeight() -- calling this seems to coax it into calculating the height ¯\_(ツ)_/¯
    f.SpellIcon.bg:SetWidth(floor(f.SpellIcon.bg:GetHeight()*1.5))
end
-- nameonly functions ##########################################################
local function NameOnly_On(f)
    -- update name text colour
    if UnitIsPlayer(f.unit) then
        -- player class colour
        f.NameText:SetTextColor(kui.GetClassColour(f.unit,2))
    else
        -- reaction colour
        if f.state.reaction >= 4 then
            f.NameText:SetTextColor(.6,1,.6)
        else
            f.NameText:SetTextColor(1,.4,.4)
        end
    end

    if f.state.nameonly then return end
    f.state.nameonly = true

    test:HealthUpdate(f)

    f.HealthBar:Hide()
    f.HealthBar.bg:Hide()
    f.HealthBar.fill:Hide()
    f.ThreatGlow:Hide()
    f.ThreatBrackets:Hide()
    f.TargetGlow:Hide()

    f.NameText:SetShadowOffset(0,-2)
    f.NameText:SetShadowColor(0,0,0,.3)

    f.NameText:ClearAllPoints()
    f.NameText:SetParent(f)
    f.NameText:SetPoint('CENTER')

    f.NameText:Show()

    f.handler:CastBarHide()
    f.handler:DisableElement('CastBar')
end
local function NameOnly_Off(f,skip_messages)
    if not f.state.nameonly then return end
    f.state.nameonly = nil

    f.NameText:SetText(f.state.name)
    f.NameText:SetTextColor(1,1,1,1)
    f.NameText:SetShadowColor(0,0,0,0)

    f.NameText:ClearAllPoints()
    f.NameText:SetParent(f.HealthBar)
    f.NameText:SetPoint('BOTTOM', f.HealthBar, 'TOP', 0, -3.5)

    f.HealthBar:Show()
    f.HealthBar.bg:Show()
    f.HealthBar.fill:Show()

    if not skip_messages then
        test:GlowColourChange(f)
        test:ShowNameUpdate(f)
    end

    f.handler:EnableElement('CastBar')
end
local function NameOnly_Update(f)
    if  f.state.reaction >= 4 and
        not UnitIsUnit('player',f.unit) and
        not UnitCanAttack('player',f.unit) and
        not UnitIsUnit('target',f.unit)
    then
        NameOnly_On(f)
    else
        NameOnly_Off(f)
    end
end
local function NameOnly_HealthUpdate(f)
    -- set name text colour to approximate health
    if not f.state.nameonly then return end

    local health_len = strlen(f.state.name) * (UnitHealth(f.unit) / UnitHealthMax(f.unit))
    f.NameText:SetText(
        kui.utf8sub(f.state.name, 0, health_len)..
        '|cff666666'..kui.utf8sub(f.state.name, health_len+1)
    )
end
--##############################################################################
--[[

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

--]]
function test:Create(f)
    local healthbar
    do
        local fill = f:CreateTexture(nil,'BACKGROUND',nil,2)
        fill:SetTexture(kui.m.t.bar)
        fill:SetAlpha(.2)

        local bg = f:CreateTexture(nil,'BACKGROUND',nil,1)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)

        healthbar = CreateFrame('StatusBar', nil, f)
        healthbar:SetStatusBarTexture(kui.m.t.bar)
        healthbar:SetFrameLevel(0)

        bg:SetPoint('TOPLEFT', healthbar, -1, 1)
        bg:SetPoint('BOTTOMRIGHT', healthbar, 1, -1)

        fill:SetAllPoints(healthbar)

        healthbar.bg = bg
        healthbar.fill = fill

        healthbar.orig_SetStatusBarColor = healthbar.SetStatusBarColor
        healthbar.SetStatusBarColor = HealthBar_SetStatusBarColor

        f.handler:SetBarAnimation(healthbar,'cutaway')

        local glow = { sides = {} }
        setmetatable(glow,glow_prototype)

        for side,coords in ipairs(glow_coords) do
            side = f:CreateTexture(nil,'BACKGROUND',nil,-5)
            side:SetTexture('interface/addons/kui_nameplates/media/frameglow')
            side:SetTexCoord(unpack(coords))

            tinsert(glow.sides, side)
        end

        glow.sides[1]:SetPoint('BOTTOMLEFT', bg, 'TOPLEFT', 1, -1)
        glow.sides[1]:SetPoint('BOTTOMRIGHT', bg, 'TOPRIGHT', -1, -1)
        glow.sides[1]:SetHeight(sizes.glow)

        glow.sides[2]:SetPoint('TOPLEFT', bg, 'BOTTOMLEFT', 1, 1)
        glow.sides[2]:SetPoint('TOPRIGHT', bg, 'BOTTOMRIGHT', -1, 1)
        glow.sides[2]:SetHeight(sizes.glow)

        glow.sides[3]:SetPoint('TOPRIGHT', glow.sides[1], 'TOPLEFT')
        glow.sides[3]:SetPoint('BOTTOMRIGHT', glow.sides[2], 'BOTTOMLEFT')
        glow.sides[3]:SetWidth(sizes.glow)

        glow.sides[4]:SetPoint('TOPLEFT', glow.sides[1], 'TOPRIGHT')
        glow.sides[4]:SetPoint('BOTTOMLEFT', glow.sides[2], 'BOTTOMRIGHT')
        glow.sides[4]:SetWidth(sizes.glow)

        f.handler:RegisterElement('HealthBar', healthbar)
        f.handler:RegisterElement('ThreatGlow', glow)
    end

    -- target glow
    local targetglow = f:CreateTexture(nil,'BACKGROUND',nil,-5)
    targetglow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-glow')
    targetglow:SetTexCoord(0,.593,0,.875)
    targetglow:SetHeight(7)
    targetglow:SetPoint('TOPLEFT',healthbar,'BOTTOMLEFT',0,1)
    targetglow:SetPoint('TOPRIGHT',healthbar,'BOTTOMRIGHT',0,1)
    targetglow:SetVertexColor(unpack(target_glow_colour))
    targetglow:Hide()

    f.TargetGlow = targetglow

    -- health bar highlight
    local highlight = healthbar:CreateTexture(nil,'ARTWORK',nil,1)
    highlight:SetTexture(kui.m.t.bar)
    highlight:SetAllPoints(healthbar)
    highlight:SetVertexColor(1,1,1)
    highlight:SetBlendMode('ADD')
    highlight:SetAlpha(.4)
    highlight:Hide()

    -- name text
    local name = healthbar:CreateFontString(nil, 'OVERLAY')
    name:SetFont(FONT, 11, 'THINOUTLINE')
    name:SetPoint('BOTTOM', healthbar, 'TOP', 0, -3.5)

    -- threat brackets
    local tb = {
        Hide = TB_Hide,
        Show = TB_Show,
        SetVertexColor = TB_SetVertexColor,
        textures = {}
    }

    for i,p in ipairs(TB_POINTS) do
        local b = f:CreateTexture(nil,'BACKGROUND',nil,0)
        b:SetTexture(TB_TEXTURE)
        b:SetSize(TB_WIDTH, TB_HEIGHT)
        b:SetPoint(p[1], healthbar, p[2], p[3], p[4])
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

    -- castbar
    do
        local bg = f:CreateTexture(nil,'BACKGROUND',nil,1)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)
        bg:SetHeight(5)
        bg:SetPoint('TOPLEFT', healthbar, 'BOTTOMLEFT', -1, -2)
        bg:SetPoint('TOPRIGHT', healthbar, 'BOTTOMRIGHT', 1, 0)

        local castbar = CreateFrame('StatusBar', nil, f)
        castbar:SetFrameLevel(0)
        castbar:SetStatusBarTexture(kui.m.t.bar)
        castbar:SetStatusBarColor(.6, .6, .75)
        castbar:SetHeight(3)
        castbar:SetPoint('TOPLEFT', bg, 1, -1)
        castbar:SetPoint('BOTTOMRIGHT', bg, -1, 1)

        local spellname = healthbar:CreateFontString(nil, 'OVERLAY')
        spellname:SetFont(FONT, 9, 'THINOUTLINE')
        spellname:SetPoint('TOP', castbar, 'BOTTOM', 0, -3.5)

        -- spell icon
        local spelliconbg = f:CreateTexture(nil, 'ARTWORK', nil, 0)
        spelliconbg:SetTexture(kui.m.t.solid)
        spelliconbg:SetVertexColor(0,0,0,.8)
        spelliconbg:SetPoint('BOTTOMRIGHT', bg, 'BOTTOMLEFT', -1, 0)
        spelliconbg:SetPoint('TOPRIGHT', healthbar.bg, 'TOPLEFT', -1, 0)

        local spellicon = castbar:CreateTexture(nil, 'ARTWORK', nil, 1)
        spellicon:SetTexCoord(.1, .9, .25, .75)
        spellicon:SetPoint('TOPLEFT', spelliconbg, 1, -1)
        spellicon:SetPoint('BOTTOMRIGHT', spelliconbg, -1, 1)

        -- cast shield
        local spellshield = healthbar:CreateTexture(nil, 'ARTWORK', nil, 2)
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
        spark:SetSize(6,9)

        -- hide elements by default
        bg:Hide()
        castbar:Hide()
        spelliconbg:Hide()
        spellshield:Hide()
        spellname:Hide()

        castbar.bg = bg
        spellicon.bg = spelliconbg

        f.handler:RegisterElement('CastBar', castbar)
        f.handler:RegisterElement('SpellName', spellname)
        f.handler:RegisterElement('SpellIcon', spellicon)
        f.handler:RegisterElement('SpellShield', spellshield)
    end

    -- auras
    local auras = f.handler:CreateAuraFrame({
        kui_whitelist = true,
        max = 10,
        point = {'BOTTOMLEFT','LEFT','RIGHT'},
        x_spacing = 1,
        y_spacing = 1,
        rows = 2
    })
    auras:SetWidth(124)
    auras:SetHeight(10)
    auras:SetPoint('BOTTOMLEFT',healthbar.bg,'TOPLEFT',4,15)

    f.handler:RegisterElement('NameText', name)
    f.handler:RegisterElement('Highlight', highlight)
end
-- messages ####################################################################
function test:Show(f)
    if f.state.minus then
        -- set elements to micro sizes
        f.HealthBar:SetSize(sizes.trivial_width, sizes.trivial_height)
    else
        -- set elements to normal sizes
        f.HealthBar:SetSize(sizes.width, sizes.height)
    end

    -- calculate where the health bar needs to go to be visually centred
    -- while remaining pixel-perfect ('CENTER' does not)
    x = floor((addon.width / 2) - (f.HealthBar:GetWidth() / 2))
    y = floor((addon.height / 2) - (f.HealthBar:GetHeight() / 2))

    f.HealthBar:SetPoint('BOTTOMLEFT', x, y)

    -- go into nameonly mode if desired
    NameOnly_Update(f)
    -- set initial glow colour
    self:GlowColourChange(f)
    -- hide name if desired
    self:ShowNameUpdate(f)
end
function test:Hide(f)
    NameOnly_Off(f,true)
    f.TargetGlow:Hide()
end
function test:HealthUpdate(f)
    NameOnly_HealthUpdate(f)
end
function test:HealthColourChange(f)
    NameOnly_Update(f)
end
function test:GlowColourChange(f)
    if f.state.nameonly then return end

    -- force show threat glow because we use it as a shadow
    f.ThreatGlow:Show()

    if f.state.glowing then
        f.ThreatBrackets:Show()
        f.ThreatBrackets:SetVertexColor(unpack(f.state.glowColour))
    else
        f.ThreatBrackets:Hide()
    end

    if f.handler:IsTarget() then
        f.ThreatGlow:SetVertexColor(unpack(target_glow_colour))
        return
    end

    if not f.state.glowing then
        -- we want a shadow when there's no threat state
        f.ThreatGlow:SetVertexColor(0, 0, 0, .6)
    end
end
function test:CastBarShow(f)
    if f.state.nameonly then return end

    -- show attached elements
    f.CastBar.bg:Show()
    f.SpellIcon.bg:Show()
    f.SpellName:Show()

    CastBar_SpellIconSetWidth(f)
end
function test:CastBarHide(f)
    f.CastBar.bg:Hide()
    f.SpellIcon.bg:Hide()
    f.SpellName:Hide()
end
function test:GainedTarget(f)
    NameOnly_Off(f,true)

    f.TargetGlow:Show()
    f.ThreatGlow:Show()
    f.ThreatGlow:SetVertexColor(unpack(target_glow_colour))

    -- target name is always shown
    self:ShowNameUpdate(f)
end
function test:LostTarget(f)
    NameOnly_Update(f)
    if f.state.nameonly then return end

    f.TargetGlow:Hide()

    if f.state.glowing then
        -- revert glow to threat colour
        f.ThreatGlow:SetVertexColor(unpack(f.state.glowColour))
    else
        -- or to shadow
        self:GlowColourChange(f)
    end

    -- hide name again depending on state
    self:ShowNameUpdate(f)
end
-- events ######################################################################
function test:ShowNameUpdate(f)
    if f.state.nameonly then return end

    if  f.handler:IsTarget() or
        f.state.threat or
        UnitShouldDisplayName(f.unit)
    then
        f.NameText:Show()

        if f.state.minus then
            f.HealthBar:SetHeight(sizes.trivial_height)
        else
            f.HealthBar:SetHeight(sizes.height)
        end
    else
        f.NameText:Hide()
        f.HealthBar:SetHeight(sizes.no_name)
    end

    if f.state.casting then
        CastBar_SpellIconSetWidth(f)
    end
end
function test:QUESTLINE_UPDATE()
    for _,frame in addon:Frames() do
        if frame:IsShown() then
            self:ShowNameUpdate(frame)
        end
    end
end
function test:UNIT_THREAT_LIST_UPDATE(event,f)
    self:ShowNameUpdate(f)
end
-- register ####################################################################
function test:Initialise()
    -- TODO resets upon chaning nameplate options
    C_NamePlate.SetNamePlateOtherSize(100,20)

    test.Auras = true

    test.ClassPowers = {
        icon_size = 10,
        icon_texture = 'interface/addons/kui_nameplates/media/combopoint-round',
        glow_texture = 'interface/addons/kui_nameplates/media/combopoint-glow',
        cd_texture = 'interface/playerframe/classoverlay-runecooldown',
        point = { 'TOP','HealthBar','BOTTOM',0,3 }
    }

    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterMessage('HealthUpdate')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('GlowColourChange')
    self:RegisterMessage('CastBarShow')
    self:RegisterMessage('CastBarHide')
    self:RegisterMessage('GainedTarget')
    self:RegisterMessage('LostTarget')

    self:RegisterEvent('QUESTLINE_UPDATE')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
end
