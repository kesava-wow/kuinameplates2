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
local function OnUnitAdded(frame)
    frame.unit = frame.parent.namePlateUnitToken

    frame.handler:Update()
    frame.handler:OnHealthUpdate()
    frame.handler:OnShow()
end
local function OnFrameHide(frame)
    frame.kui.handler:OnHide()
end
------------------------------------------------------- Core OnUpdate handler --
-- sets position of the base frame
local function OnFrameUpdate(frame)
    local x,y = frame:GetCenter()

    -- align to pixel-perfect centre of the real nameplate frame
    frame.kui:SetPoint('CENTER', WorldFrame, 'BOTTOMLEFT',
        floor(x / addon.uiscale), floor(y / addon.uiscale))

    if frame.kui.DoShow then
        -- show the frame after it's been moved
        frame.kui:Show()
        frame.kui.DoShow = nil
    end
end
------------------------------------------------------------ Nameplate hooker --
-- hook into nameplate frame and element scripts
function addon.HookNameplate(frame)
    frame.kui = CreateFrame('Frame', nil, WorldFrame)
    frame.kui:Hide()
    frame.kui:SetFrameLevel(0)
    frame.kui.state = {}
    frame.kui.elements = {}
    frame.kui.parent = frame

    -- hide blizzard's nameplate TODO obviously
    frame.UnitFrame:SetAlpha(0)
    frame.UnitFrame:Hide()

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

    -- base frame
    frame:HookScript('OnUpdate', OnFrameUpdate)
    frame:HookScript('OnHide', OnFrameHide)
    frame.kui.OnUnitAdded = OnUnitAdded

    frame.kui.handler:Create()

    if frame.UnitFrame.unit and frame:IsShown() then
        -- force the first OnShow
        OnFrameShow(frame)
    end
end
