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
    trivial_height = 7
}
local x,y

test.Create = function(f)
    local glow,healthbar
    do
        local bg = f:CreateTexture(nil, 'ARTWORK')
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)

        glow = f:CreateTexture(nil, 'BACKGROUND')
        glow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\FrameGlow')
        glow:SetTexCoord(0, .469, 0, .625)

        healthbar = CreateFrame('StatusBar', nil, f)
        healthbar:SetStatusBarTexture(kui.m.t.bar)

        bg:SetPoint('TOPLEFT', healthbar, -1, 1)
        bg:SetPoint('BOTTOMRIGHT', healthbar, 1, -1)
        healthbar.bg = bg
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
    local castbar, spellname, spellicon, spellshield
    do
        local bg = f:CreateTexture(nil, 'ARTWORK')
        bg:SetTexture(kui.m.t.solid)
        bg:SetVertexColor(0,0,0,.8)
        bg:SetHeight(4)
        bg:SetPoint('TOPLEFT', healthbar, 'BOTTOMLEFT', -1, -2)
        bg:SetPoint('TOPRIGHT', healthbar, 'BOTTOMRIGHT', 1, 0)

        castbar = CreateFrame('StatusBar', nil, f)
        castbar:SetStatusBarTexture(kui.m.t.bar)
        castbar:SetStatusBarColor(.6, .6, .75)
        castbar:SetHeight(2)
        castbar:SetPoint('TOPLEFT', bg, 1, -1)
        castbar:SetPoint('BOTTOMRIGHT', bg, -1, 1)

        spellname = overlay:CreateFontString(nil, 'OVERLAY')
        spellname:SetFont(kui.m.f.francois, 9, 'OUTLINE')
        spellname:SetPoint('TOP', castbar, 'BOTTOM', 0, -3)

        -- spell icon
        local spelliconbg = f:CreateTexture(nil, 'ARTWORK')
        spelliconbg:SetTexture(kui.m.t.solid)
        spelliconbg:SetVertexColor(0,0,0,.8)
        spelliconbg:SetPoint('BOTTOMRIGHT', bg, 'BOTTOMLEFT', -1, 0)
        spelliconbg:SetPoint('TOPRIGHT', healthbar.bg, 'TOPLEFT', -1, 0)
        spelliconbg:SetWidth(9)

        spellicon = castbar:CreateTexture(nil, 'ARTWORK')
        spellicon:SetTexCoord(.1, .9, .25, .75)
        spellicon:SetPoint('TOPLEFT', spelliconbg, 1, -1)
        spellicon:SetPoint('BOTTOMRIGHT', spelliconbg, -1, 1)

        -- cast shield
        spellshield = overlay:CreateTexture(nil, 'ARTWORK')
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
    end

    f.handler:RegisterElement('Healthbar', healthbar)
    f.handler:RegisterElement('Name', name)
    f.handler:RegisterElement('ThreatGlow', glow)
    f.handler:RegisterElement('Highlight', highlight)

    f.handler:RegisterElement('Castbar', castbar)
    f.handler:RegisterElement('SpellName', spellname)
    f.handler:RegisterElement('SpellIcon', spellicon)
    f.handler:RegisterElement('SpellShield', spellshield)
end

test.Show = function(f)
    if f.state.micro then
        -- set elements to micro sizes
        f.Healthbar:SetSize(sizes.trivial_width, sizes.trivial_height)

        f.ThreatGlow:SetPoint('BOTTOMLEFT', f.Healthbar.bg, -3, -3)
        f.ThreatGlow:SetPoint('TOPRIGHT', f.Healthbar.bg, 3, 3)
    else
        -- set elements to normal sizes
        f.Healthbar:SetSize(sizes.width, sizes.height)

        f.ThreatGlow:SetPoint('BOTTOMLEFT', f.Healthbar.bg, -6, -6)
        f.ThreatGlow:SetPoint('TOPRIGHT', f.Healthbar.bg, 6, 6)
    end

    -- calculate where the health bar needs to go to be visually centred
    -- while remaining pixel-perfect ('CENTER' does not)
    x = floor((addon.width / 2) - (f.Healthbar:GetWidth() / 2))
    y = floor((addon.height / 2) - (f.Healthbar:GetHeight() / 2))

    f.Healthbar:SetPoint('BOTTOMLEFT', x, y)
end

test.GlowColourChange = function(f)
    if not f.state.glowing then
        -- we want a shadow when there's no threat state
        f.ThreatGlow:SetVertexColor(0, 0, 0, .5)
    end
end

test.CastbarShow = function(f)
    f.Castbar.bg:Show()
    f.SpellIcon.bg:Show()
    f.SpellName:Show()

    local icon_width = f.SpellIcon.bg:GetHeight()
    f.SpellIcon.bg:SetWidth(floor(icon_width*1.5))
end

test.CastbarHide = function(f)
    f.Castbar.bg:Hide()
    f.SpellIcon.bg:Hide()
    f.SpellName:Hide()
end
