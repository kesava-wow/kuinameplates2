--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Base element script handler & base frame element registrar
-- Update registered elements and dispatch messages
--------------------------------------------------------------------------------
local addon = KuiNameplates
local wipe = wipe

addon.Nameplate = {}
addon.Nameplate.__index = addon.Nameplate

-- Element registrar
function addon.Nameplate.RegisterElement(frame, element_name, element_frame)
    frame = frame.parent
    if frame[element_name] then return end
    frame.elements[element_name] = true
    frame[element_name] = element_frame

    -- approximate provider;
    -- can't find elements with different names to their parent plugin
    local provider = addon:GetPlugin(element_name)
    if provider and type(provider.PostRegister) == 'function' then
        provider:PostRegister(frame,element_name)
    end
end
-- Disable/enable an element on a per-frame basis:
-- XXX important to note that once an element is disabled, it must be manually
-- re-enabled for that frame; it does not re-enable when a frame is re-used.
function addon.Nameplate.DisableElement(frame, element_name)
    if not element_name then return end
    frame = frame.parent

    if frame and frame.elements[element_name] then
        frame.elements[element_name] = false

        local provider = addon:GetPlugin(element_name)
        if provider and type(provider.DisableOnFrame) == 'function' then
            provider:DisableOnFrame(frame,element_name)
        end
    end
end
function addon.Nameplate.EnableElement(frame, element_name)
    if not element_name then return end
    frame = frame.parent

    if frame and frame.elements[element_name] == false then
        frame.elements[element_name] = true

        local provider = addon:GetPlugin(element_name)
        if provider and type(provider.EnableOnFrame) == 'function' then
            provider:EnableOnFrame(frame,element_name)
        end
    end
end
-------------------------------------------------------- Frame event handlers --
function addon.Nameplate.OnUnitAdded(f,unit)
    f = f.parent
    if not unit then
        addon:print('NO UNIT: '..f:GetName())
        return
    else
        f.state.personal = UnitIsUnit(unit,'player')
        f.unit = unit
        f.guid = UnitGUID(unit)
        f.handler:OnShow()
    end
end
------------------------------------------------------- Frame script handlers --
function addon.Nameplate.OnShow(f)
    f = f.parent
    f:Show()
    addon:DispatchMessage('Show', f)
end
function addon.Nameplate.OnHide(f)
    f = f.parent
    if not f:IsShown() then return end

    f:Hide()
    addon:DispatchMessage('Hide', f)

    f.unit = nil
    f.guid = nil
    wipe(f.state)
end
function addon.Nameplate.Create(f)
    f = f.parent
    addon:DispatchMessage('Create', f)
end
