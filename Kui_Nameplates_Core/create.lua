local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local test = addon:Layout()

if not test then
    -- a layout is already registered
    return
end

local sizes = {
    width = 130,
    height = 11,
    trivial_width = 70,
    trivial_height = 7,
    glow = 8,
    no_name = 7
}
local x,y

-- texture coords for the frame glow
local glow_coords = {
    { .05, .95,  0,  .24 }, -- top
    { .05, .95, .76,  1 },  -- bottom
    {  0,  .04,  0,   1 },  -- left
    { .96,  1,   0,   1 }   -- right
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
--##############################################################################
function test:Create(f)
    local healthbar
    do
        local fill = f:CreateTexture(nil,'ARTWORK',nil,1)
        fill:SetTexture(kui.m.t.bar)
        fill:SetAlpha(.2)

        local bg = f:CreateTexture(nil,'ARTWORK',nil,0)
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)

        healthbar = CreateFrame('StatusBar', nil, f)
        healthbar:SetStatusBarTexture(kui.m.t.bar)

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
            side = f:CreateTexture(nil,'BACKGROUND',nil,0)
            side:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\FrameGlow')
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

    local overlay = CreateFrame('Frame', nil, f)
    overlay:SetAllPoints(healthbar)
    overlay:SetFrameLevel(healthbar:GetFrameLevel() + 1)

    local highlight = overlay:CreateTexture(nil, 'ARTWORK')
    highlight:SetTexture(kui.m.t.bar)
    highlight:SetAllPoints(healthbar)
    highlight:SetVertexColor(1,1,1)
    highlight:SetBlendMode('ADD')
    highlight:SetAlpha(.4)
    highlight:Hide()

    local name = overlay:CreateFontString(nil, 'OVERLAY')
    name:SetFont(kui.m.f.francois, 11, 'OUTLINE')
    name:SetPoint('BOTTOM', healthbar, 'TOP', 0, -3)

    -- castbar
    do
        local bg = f:CreateTexture(nil, 'ARTWORK')
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)
        bg:SetHeight(4)
        bg:SetPoint('TOPLEFT', healthbar, 'BOTTOMLEFT', -1, -2)
        bg:SetPoint('TOPRIGHT', healthbar, 'BOTTOMRIGHT', 1, 0)

        local castbar = CreateFrame('StatusBar', nil, f)
        castbar:SetStatusBarTexture(kui.m.t.bar)
        castbar:SetStatusBarColor(.6, .6, .75)
        castbar:SetHeight(2)
        castbar:SetPoint('TOPLEFT', bg, 1, -1)
        castbar:SetPoint('BOTTOMRIGHT', bg, -1, 1)

        local spellname = overlay:CreateFontString(nil, 'OVERLAY')
        spellname:SetFont(kui.m.f.francois, 9, 'OUTLINE')
        spellname:SetPoint('TOP', castbar, 'BOTTOM', 0, -3)

        -- spell icon
        local spelliconbg = f:CreateTexture(nil, 'ARTWORK')
        spelliconbg:SetTexture(kui.m.t.solid)
        spelliconbg:SetVertexColor(0,0,0,.8)
        spelliconbg:SetPoint('BOTTOMRIGHT', bg, 'BOTTOMLEFT', -1, 0)
        spelliconbg:SetPoint('TOPRIGHT', healthbar.bg, 'TOPLEFT', -1, 0)
        spelliconbg:SetWidth(9)

        local spellicon = castbar:CreateTexture(nil, 'ARTWORK')
        spellicon:SetTexCoord(.1, .9, .25, .75)
        spellicon:SetPoint('TOPLEFT', spelliconbg, 1, -1)
        spellicon:SetPoint('BOTTOMRIGHT', spelliconbg, -1, 1)

        -- cast shield
        local spellshield = overlay:CreateTexture(nil, 'ARTWORK')
        spellshield:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\Shield')
        spellshield:SetTexCoord(0, .84375, 0, 1)
        spellshield:SetSize(16 * .84375, 16)
        spellshield:SetPoint('LEFT', bg, -5, 0)
        spellshield:SetVertexColor(.5, .5, .7)

        -- spark
        local spark = castbar:CreateTexture(nil, 'ARTWORK')
        spark:SetDrawLayer('ARTWORK', 7)
        spark:SetVertexColor(1,1,.8)
        spark:SetTexture('Interface\\AddOns\\Kui_Media\\t\\spark')
        spark:SetPoint('CENTER', castbar:GetRegions(), 'RIGHT', 1, 0)
        spark:SetSize(6, 2 + 6)

        -- hide elements by default
        bg:Hide()
        castbar:Hide()
        spelliconbg:Hide()
        spellshield:Hide()

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
function test:Show(f)
    if f.state.minus then
        -- set elements to micro sizes
        f.HealthBar:SetSize(sizes.trivial_width, sizes.trivial_height)
    else
        -- set elements to normal sizes
        f.HealthBar:SetSize(sizes.width, sizes.height)
    end

    if UnitShouldDisplayName(f.unit) then
        f.NameText:Show()
    else
        f.NameText:Hide()
        f.HealthBar:SetHeight(sizes.no_name)
    end

    -- calculate where the health bar needs to go to be visually centred
    -- while remaining pixel-perfect ('CENTER' does not)
    x = floor((addon.width / 2) - (f.HealthBar:GetWidth() / 2))
    y = floor((addon.height / 2) - (f.HealthBar:GetHeight() / 2))

    f.HealthBar:SetPoint('BOTTOMLEFT', x, y)

    -- set initial glow colour
    self:GlowColourChange(f)
end
function test:GlowColourChange(f)
    if not f.state.glowing then
        -- we want a shadow when there's no threat state
        f.ThreatGlow:SetVertexColor(0, 0, 0, .6)
    end
end
function test:CastBarShow(f)
    f.CastBar.bg:Show()
    f.SpellIcon.bg:Show()
    f.SpellName:Show()

    local icon_width = f.SpellIcon.bg:GetHeight()
    f.SpellIcon.bg:SetWidth(floor(icon_width*1.5))
end
function test:CastBarHide(f)
    f.CastBar.bg:Hide()
    f.SpellIcon.bg:Hide()
    f.SpellName:Hide()
end
-- #############################################################################
local target
function test:PLAYER_TARGET_CHANGED()
    -- TODO obviously target state, messages and target glow should be handled
    -- by an element
    if UnitExists('target') then
        if target and not UnitShouldDisplayName(target.unit) then
            target.NameText:Hide()
            target.HealthBar:SetHeight(sizes.no_name)
        end

        target = C_NamePlate.GetNamePlateForUnit('target')

        if target then
            target = target.kui
            target.NameText:Show()

            if target.state.minus then
                target.HealthBar:SetHeight(sizes.trivial_height)
            else
                target.HealthBar:SetHeight(sizes.height)
            end
        end
    else
        if target and not UnitShouldDisplayName(target.unit) then
            target.NameText:Hide()
            target.HealthBar:SetHeight(sizes.no_name)
        end
    end
end
-- #############################################################################
function test:Initialise()
    test.ClassPowers = {} -- TODO
    test.Auras = true

    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('GlowColourChange')
    self:RegisterMessage('CastBarShow')
    self:RegisterMessage('CastBarHide')

    self:RegisterEvent('PLAYER_TARGET_CHANGED')
end
