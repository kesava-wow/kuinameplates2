--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Find nameplates and hook the base frame scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')

local WorldFrame = WorldFrame
local select, strfind, setmetatable, floor
	= select, strfind, setmetatable, floor
--------------------------------------------------------------------------------
-------------------------------------------------------- Core script handlers --
-- base frame
local function OnFrameShow(frame)
	frame.kui.handler:Update()
	frame.kui.handler:OnHealthUpdate()
	frame.kui.handler:OnShow()
end
local function OnFrameHide(frame)
	frame.kui.handler:OnHide()
end
-- health bar
local function OnHealthUpdate(bar)
	if bar.kuiParent:IsShown() then
		bar.kuiParent.handler:OnHealthUpdate()
	end
end
-- cast bar
local function OnCastbarShow(bar)
	bar.kuiParent.handler:OnCastbarShow()
end
local function OnCastbarHide(bar)
	bar.kuiParent.handler:OnCastbarHide()
end
local function OnCastbarUpdate(bar)
	if bar.kuiParent:IsShown() then
		bar.kuiParent.handler:OnCastbarUpdate()
	end
end
------------------------------------------------------- Core OnUpdate handler --
-- sets position of the base frame
local function OnFrameUpdate(frame)
	local x,y = frame:GetCenter()

	-- align to pixel-perfect centre of the real nameplate frame
	frame.kui:SetPoint('CENTER', WorldFrame, 'BOTTOMLEFT',
		floor(x / addon.uiscale), floor(y / addon.uiscale))

	if frame.kui.DoShow then
		-- show the frame after its been moved
		frame.kui:Show()
	end
end
---------------------------------------------------- Hide default UI elements --
local function GetDefaultFrameElements(frame, f)
	local overlayChild, nameTextChild = frame:GetChildren()
	local healthbar, castbar = overlayChild:GetChildren()

	local _, castbarBorder, castbarShield,
	      spellIcon, spellNameText, spellNameShadow
	    = castbar:GetRegions()

	local nameText = nameTextChild:GetRegions()
	local glow, border, highlight, levelText, bossIcon, raidIcon, eliteIcon
	    = overlayChild:GetRegions()

	-- store default elements
	f.default = {
		healthbar = healthbar,
		nameText  = nameText,
		levelText = levelText,

		castbar         = castbar,
		castbarBorder   = castbarBorder,
		castbarShield   = castbarShield,
		spellIcon       = spellIcon,
		spellNameText   = spellNameText,
		spellNameShadow = spellNameShadow,

		glow      = glow,
		border    = border,
		highlight = highlight,
		bossIcon  = bossIcon,
		raidIcon  = raidIcon,
		eliteIcon = eliteIcon
	}

	healthbar.kuiParent = f
	castbar.kuiParent = f

	-- hide default elements in a way that doesn't interfere with other addons
	healthbar:SetStatusBarTexture(kui.m.t.empty)
	castbar:SetStatusBarTexture(kui.m.t.empty)

	nameText:SetWidth(.1)
	levelText:SetWidth(.1)

	raidIcon:SetAlpha(0)

	glow:SetTexCoord(0,0,0,0)
	border:SetTexCoord(0,0,0,0)
	highlight:SetTexCoord(0,0,0,0)
	bossIcon:SetTexCoord(0,0,0,0)
	eliteIcon:SetTexCoord(0,0,0,0)
	castbarBorder:SetTexCoord(0,0,0,0)
	castbarShield:SetTexCoord(0,0,0,0)

	spellIcon:SetTexCoord(0,0,0,0)
	spellIcon:SetWidth(.01)

	spellNameShadow:SetTexture(kui.m.t.empty)
	
	-- this seems to be the only sane way to hide these
	spellNameShadow:Hide()
	spellNameText:Hide()
end

------------------------------------------------------------ Nameplate hooker --
-- hook into nameplate frame and element scripts
function addon.HookNameplate(frame)
	frame.kui = CreateFrame('Frame', nil, WorldFrame)
	frame.kui:SetFrameLevel(0)
	frame.kui.state = {}
	frame.kui.elements = {}
	frame.kui.parent = frame

	frame.kui:SetScale(addon.uiscale)
	frame.kui:SetSize(addon.width, addon.height)

	if addon.debug then
		-- debug; visible frame sizes
		frame:SetBackdrop({ bgFile = kui.m.t.solid })
		frame:SetBackdropColor(0,0,0,.5)
		frame.kui:SetBackdrop({ bgFile = kui.m.t.solid })
		frame.kui:SetBackdropColor(1,1,1,.5)
	end

	frame.kui.handler = { parent = frame.kui }
	setmetatable(frame.kui.handler, addon.Nameplate)

	GetDefaultFrameElements(frame, frame.kui)

	-- base frame
	frame:HookScript('OnShow', OnFrameShow)
	frame:HookScript('OnHide', OnFrameHide)
	frame:HookScript('OnUpdate', OnFrameUpdate)

	-- health bar
	frame.kui.default.healthbar:HookScript('OnValueChanged', OnHealthUpdate)
	frame.kui.default.healthbar:HookScript('OnMinMaxChanged', OnHealthUpdate)

	-- cast bar
	frame.kui.default.castbar:HookScript('OnShow', OnCastbarShow)
	frame.kui.default.castbar:HookScript('OnHide', OnCastbarHide)
	frame.kui.default.castbar:HookScript('OnValueChanged', OnCastbarUpdate)
	frame.kui.default.castbar:HookScript('OnMinMaxChanged', OnCastbarUpdate)

	frame.kui.handler:Create()

	if frame:IsShown() then
		-- force the first OnShow
		OnFrameShow(frame)
	end
end
