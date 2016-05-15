--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Create base frame and hook scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')

local WorldFrame = WorldFrame
local select, strfind, setmetatable, floor
    = select, strfind, setmetatable, floor
--------------------------------------------------------------------------------
-------------------------------------------------------- Core script handlers --
local function OnFrameHide(frame)
    frame.kui.handler:OnHide()
end
----------------------------------------------------------------------- Sizer --
local function SizerOnSizeChanged(self,x,y)
    --self.f:Hide() TODO external textures flash with this
    self.f:SetPoint('CENTER',WorldFrame,'BOTTOMLEFT',floor(x),floor(y))
    --self.f:Show()
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

    -- semlar's non-laggy positioning
    local sizer = CreateFrame('Frame',nil,frame.kui)
    sizer:SetPoint('BOTTOMLEFT',WorldFrame)
    sizer:SetPoint('TOPRIGHT',frame,'CENTER')
    sizer:SetScript('OnSizeChanged',SizerOnSizeChanged)
    sizer.f = frame.kui

    -- hide blizzard's nameplate
    frame.UnitFrame:Hide()
    frame.UnitFrame:HookScript('OnShow',function(self)
        self:Hide()
    end)

    frame.kui:SetScale(addon.uiscale)
    frame.kui:SetSize(addon.width, addon.height)

    if addon.draw_frames then
        -- debug; visible frame sizes
        frame:SetBackdrop({ bgFile = kui.m.t.solid })
        frame:SetBackdropColor(0,0,0,.5)
        frame.kui:SetBackdrop({ bgFile = kui.m.t.solid })
        frame.kui:SetBackdropColor(1,1,1,.5)
    end

    frame.kui.handler = { parent = frame.kui }
    setmetatable(frame.kui.handler, addon.Nameplate)

    -- base frame
    frame:HookScript('OnHide', OnFrameHide)

    frame.kui.handler:Create()

    if frame.namePlateUnitToken and frame:IsShown() then
        -- force the first OnShow
        OnFrameShow(frame)
    end
end
