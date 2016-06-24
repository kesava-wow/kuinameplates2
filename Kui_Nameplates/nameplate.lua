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
-- TODO now that elements are external, element files should register which
-- elements they provide so that they can be called when disabled/enabled etc
function addon.Nameplate.RegisterElement(frame, element_name, element_frame)
    frame = frame.parent
    if frame[element_name] then return end
    frame.elements[element_name] = true
    frame[element_name] = element_frame
end
function addon.Nameplate.DisableElement(frame, element_name)
    frame = frame.parent
    if frame.elements[element_name] then
        frame.elements[element_name] = false

        -- TODO as above, addon:GetElementProvider(name) or something
        local provider = addon:GetPlugin(element_name)
        if provider and type(provider.DisableOnFrame) == 'function' then
            provider:DisableOnFrame(frame,element_name)
        end
    end
end
function addon.Nameplate.EnableElement(frame, element_name)
    frame = frame.parent
    if frame.elements[element_name] == false then
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
    f.unit = unit

    if not f.unit then
        addon:print('NO UNIT: '..f:GetName())
        return
    end

    f.handler:OnShow()
end
------------------------------------------------------- Frame script handlers --
function addon.Nameplate.OnShow(f)
    f = f.parent

    addon:DispatchMessage('Show', f)
    f:Show()
end
function addon.Nameplate.OnHide(f)
    f = f.parent
    if not f:IsShown() then return end

    f:Hide()
    addon:DispatchMessage('Hide', f)

    f.unit = nil
    wipe(f.state)
end
function addon.Nameplate.Create(f)
    f = f.parent
    addon:DispatchMessage('Create', f)
end
