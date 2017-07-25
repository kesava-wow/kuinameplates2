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
local UnitIsUnit = UnitIsUnit
--------------------------------------------------------------------------------
-------------------------------------------------------- Core script handlers --
local function FrameOnHide(self)
    self.kui.handler:OnHide()
end
local function FrameOnShow(self)
    if not addon.USE_BLIZZARD_PERSONAL or
       not self.unit or
       not UnitIsUnit(self.unit,'player')
    then
        -- hide blizzard's nameplate
        self:Hide()
    end
end
--------------------------------------------------------- frame level monitor --
local function FrameOnUpdate(self)
    self.kui:SetFrameLevel(self:GetFrameLevel())
end
----------------------------------------------------------------------- Sizer --
local function SizerOnSizeChanged(self,x,y)
    -- If you're poking around here trying to find what's causing the extra CPU
    -- usage, this is it.
    self.f:SetPoint('CENTER',WorldFrame,'BOTTOMLEFT',floor(x),floor(y))
end
------------------------------------------------------------ Nameplate hooker --
-- hook into nameplate frame and element scripts
function addon:HookNameplate(frame)
    local name = 'Kui'..frame:GetName()

    frame.kui = CreateFrame('Frame',name,WorldFrame)
    frame.kui:Hide()
    frame.kui:SetFrameStrata('BACKGROUND')
    frame.kui:SetFrameLevel(0)
    frame.kui.state = {}
    frame.kui.elements = {}
    frame.kui.parent = frame

    -- semlar's non-laggy positioning
    local sizer = CreateFrame('Frame',name..'PositionHelper',frame.kui)
    sizer:SetPoint('BOTTOMLEFT',WorldFrame)
    sizer:SetPoint('TOPRIGHT',frame,'CENTER')
    sizer:SetScript('OnSizeChanged',SizerOnSizeChanged)
    sizer.f = frame.kui

    frame.kui:SetScale(self.uiscale)
    frame.kui:SetSize(self.width,self.height)

    if self.draw_frames then
        -- debug; visible frame sizes
        frame:SetBackdrop({bgFile=kui.m.t.solid})
        frame:SetBackdropColor(0,0,0)
        frame.kui:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
        frame.kui:SetBackdropBorderColor(1,1,1)
    end

    frame.kui.handler = { parent = frame.kui }
    setmetatable(frame.kui.handler, self.Nameplate)

    if frame.UnitFrame then
        frame.UnitFrame:HookScript('OnShow',FrameOnShow)
    end

    -- base frame
    frame:HookScript('OnHide',FrameOnHide)
    frame:HookScript('OnUpdate',FrameOnUpdate)

    frame.kui.handler:Create()
end
