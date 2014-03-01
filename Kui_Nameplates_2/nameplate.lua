--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Base element script handler & base frame element registrar
-- Fetch state of the base nameplate elements, update registered elements
-- and dispatch messages
--------------------------------------------------------------------------------
local addon = KuiNameplates
local wipe = wipe

addon.Nameplate = {}
addon.Nameplate.__index = addon.Nameplate

-- list of valid elements
local elements = {
	['Castbar']     = true,
	['Healthbar']   = true,
	['Name']        = true,
	['Level']       = true,
	['SpellName']   = true,
	['SpellIcon']   = true,
	['SpellShield'] = true,
	['RaidIcon']    = true,
	['BossIcon']    = true,
	['Highlight']   = true,
	['ThreatGlow']  = true,
}
function addon.Nameplate.RegisterElement(frame, element, element_frame)
	if not elements[element] then return end
	frame = frame.parent
	if frame[element] then return end

	frame.elements[element] = true
	frame[element] = element_frame
end

------------------------------------------------------- Frame script handlers --
function addon.Nameplate.OnShow(f)
	f = f.parent
	f.state.name = f.default.nameText:GetText()
	f.state.level = f.default.levelText:GetText()

	if f.default.eliteIcon:IsVisible() then
		if f.default.eliteIcon:GetTexture() == [[Interface\Tooltips\EliteNameplateIcon]]
		then
			f.state.elite = true
		else
			f.state.rare = true
		end
	end

	if f.elements.Name then
		f.Name:SetText(f.state.name)
	end

	if f.elements.Level then
		f.Level:SetText(f.state.level)
	end

	if f.elements.BossIcon then
		f.BossIcon:Show()
	end

	addon:DispatchMessage('Show', f)
	f.DoShow = true
end
function addon.Nameplate.OnHide(f)
	f = f.parent
	f.DoShow = nil
	f:Hide()
	addon:DispatchMessage('Hide', f)

	-- reset highlight
	if f.elements.Highlight then
		f.Highlight:Hide()
	end

	wipe(f.state)
end
function addon.Nameplate.Create(f)
	f = f.parent
	addon:DispatchMessage('Create', f)
end

function addon.Nameplate.OnHealthUpdate(f)
	f = f.parent

	if f.elements.Healthbar then
		f.Healthbar:SetMinMaxValues(f.default.healthbar:GetMinMaxValues())
		f.Healthbar:SetValue(f.default.healthbar:GetValue())
	end

	addon:DispatchMessage('HealthUpdate', f)
end

function addon.Nameplate.OnCastbarShow(f)
	f = f.parent
	f.state.casting = true

	if f.elements.Castbar then
		f.Castbar:SetMinMaxValues(f.default.castbar:GetMinMaxValues())
		f.Castbar:SetValue(f.default.castbar:GetValue())
		f.Castbar:Show()
	end

	if f.elements.SpellName then
		f.SpellName:SetText(f.default.spellNameText:GetText())
	end

	if f.elements.SpellIcon then
		f.SpellIcon:SetTexture(f.default.spellIcon:GetTexture())
	end

	if f.elements.SpellShield then
		f.SpellShield:Show()
	end

	addon:DispatchMessage('CastbarShow', f)
end
function addon.Nameplate.OnCastbarHide(f)
	f = f.parent
	f.state.casting = false

	if f.elements.Castbar then
		f.Castbar:Hide()
	end

	if f.elements.SpellShield then
		f.SpellShield:Hide()
	end

	addon:DispatchMessage('CastbarHide', f)
end
function addon.Nameplate.OnCastbarUpdate(f)
	if not f.parent.state.casting then return end
	f = f.parent

	if f.elements.Castbar then
		f.Castbar:SetMinMaxValues(f.default.castbar:GetMinMaxValues())
		f.Castbar:SetValue(f.default.castbar:GetValue())
	end
end
------------------------------------------------------------ update functions --
-- watch for health colour changes
local function UpdateHealthColour(f)
	local r,g,b = f.default.healthbar:GetStatusBarColor()
	if not f.state.healthColour or
	   f.state.healthColour[1] ~= r or
	   f.state.healthColour[2] ~= g or
	   f.state.healthColour[3] ~= b
	then
		f.state.healthColour = { r,g,b }

		if f.elements.Healthbar then
			f.Healthbar:SetStatusBarColor(unpack(f.state.healthColour))
		end

		addon:DispatchMessage('HealthColourChange', f)
	end
end
-- watch for glow colour changes
local function UpdateGlowColour(f)
	if f.default.glow:IsShown() then
		f.state.glowing = true
		local r,g,b,a = f.default.glow:GetVertexColor()
		if not f.state.glowColour or
		   f.state.glowColour[1] ~= r or
		   f.state.glowColour[2] ~= g or
		   f.state.glowColour[3] ~= b or
		   f.state.glowColour[4] ~= a
		then
			f.state.glowColour = { r,g,b,a }

			if f.elements.ThreatGlow then
				f.ThreatGlow:SetVertexColor(unpack(f.state.glowColour))
			end

			addon:DispatchMessage('GlowColourChange', f)
		end
	elseif f.state.glowing or not f.state.glowColour then
		f.state.glowing = false
		f.state.glowColour = { 0, 0, 0, 0 }
		addon:DispatchMessage('GlowColourChange', f)
	end
end
-- check for mouseover highlight
local function UpdateMouseover(f)
	if f.default.highlight:IsShown() then
		if not f.state.highlight then
			f.state.highlight = true

			if f.elements.Highlight then
				f.Highlight:Show()
			end

			addon:DispatchMessage('OnEnter', f)
		end
	else
		if f.state.highlight then
			f.state.highlight = false

			if f.elements.Highlight then
				f.Highlight:Hide()
			end

			addon:DispatchMessage('OnLeave', f)
		end
	end
end
-------------------------------------------------------- frame update handler --
function addon.Nameplate.Update(f)
	f = f.parent
	UpdateHealthColour(f)
	UpdateGlowColour(f)
	UpdateMouseover(f)
end
