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
local kui = LibStub('Kui-1.0')
local wipe = wipe

addon.Nameplate = {}
addon.Nameplate.__index = addon.Nameplate

-- Element registrar
-- elements used by the default scripts (below) are:
-- Castbar, Healthbar, Name, Level, SpellName, SpellIcon, SpellShield, RaidIcon,
-- BossIcon, Highlight, ThreatGlow
function addon.Nameplate.RegisterElement(frame, element, element_frame)
    frame = frame.parent
    if frame[element] then return end
    frame.elements[element] = true
    frame[element] = element_frame
end
function addon.Nameplate.DisableElement(frame, element)
    frame = frame.parent
    if frame.elements[element] then
        frame.elements[element] = false
    end
end
function addon.Nameplate.EnableElement(frame, element)
    frame = frame.parent
    if frame.elements[element] == false then
        frame.elements[element] = true
    end
end
-------------------------------------------------------- Frame event handlers --
function addon.Nameplate.OnUnitAdded(f,unit)
    f = f.parent
    f.unit = unit
    f.handler:OnShow()
end
------------------------------------------------------- Frame script handlers --
function addon.Nameplate.OnShow(f)
    f = f.parent
    f.state.name = f.unit and UnitName(f.unit)
    f.state.level = f.unit and UnitLevel(f.unit)
    f.state.micro = nil

    --[[ TODO
    if f.default.eliteIcon:IsVisible() then
        if f.default.eliteIcon:GetTexture() == "Interface\Tooltips\EliteNameplateIcon"
        then
            f.state.elite = true
        else
            f.state.rare = true
        end
    end
    ]]

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
    f:Show()
end
function addon.Nameplate.OnHide(f)
    f = f.parent
    if not f:IsShown() then return end

    f:Hide()
    addon:DispatchMessage('Hide', f)

    wipe(f.state)
end
function addon.Nameplate.Create(f)
    f = f.parent
    addon:DispatchMessage('Create', f)
end
------------------------------------------------------------ update functions --
-- watch for glow colour changes
--[[
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
]]
