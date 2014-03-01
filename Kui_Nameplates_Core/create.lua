local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local test = {}

local sizes = {
	width = 142,
	height = 12
}
local x,y

test.Create = function(f)
	local bg = f:CreateTexture(nil, 'ARTWORK')
	bg:SetTexture(kui.m.t.solid)
	bg:SetVertexColor(0,0,0,.8)

	local glow = f:CreateTexture(nil, 'ARTWORK')
	glow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\FrameGlow')
	glow:SetTexCoord(0, .469, 0, .625)
	glow:SetPoint('BOTTOMLEFT', bg, -6, -6)
	glow:SetPoint('TOPRIGHT', bg, 6, 6)

	local healthbar = CreateFrame('StatusBar', nil, f)
	healthbar:SetStatusBarTexture(kui.m.t.bar)
	healthbar:SetPoint('BOTTOMLEFT', x, y)
	healthbar:SetSize(sizes.width, sizes.height)

	bg:SetPoint('TOPLEFT', healthbar, -1, 1)
	bg:SetPoint('BOTTOMRIGHT', healthbar, 1, -1)

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
	name:SetFont(kui.m.f.expressway, 11, 'OUTLINE')
	name:SetPoint('BOTTOM', healthbar, 'TOP', 0, -3)

	local castbar = CreateFrame('StatusBar', nil, f)
	castbar:SetStatusBarTexture(kui.m.t.bar)
	castbar:SetHeight(4)
	castbar:SetPoint('TOPLEFT', healthbar, 'BOTTOMLEFT', 0, -2)
	castbar:SetPoint('TOPRIGHT', healthbar, 'BOTTOMRIGHT', 0, 0)
	castbar:Hide()

	f.handler:RegisterElement('Healthbar', healthbar)
	f.handler:RegisterElement('Castbar', castbar)
	f.handler:RegisterElement('Name', name)
	f.handler:RegisterElement('ThreatGlow', glow)
	f.handler:RegisterElement('Highlight', highlight)
end

test.GlowColourChange = function(f)
	if not f.state.glowing then
		-- we want a shadow when there's no threat state
		f.ThreatGlow:SetVertexColor(0, 0, 0, .5)
	end
end

function test:Initialise()
	-- calculate where the health bar needs to go to be visually centred
	-- while remaining pixel-perfect ('CENTER' does not)
	x = floor((addon.width / 2) - (sizes.width / 2))
	y = floor((addon.height / 2) - (sizes.height / 2))
end

addon:RegisterLayout(test)