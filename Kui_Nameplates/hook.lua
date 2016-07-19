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
local function FrameOnHide(self)
    self.kui.handler:OnHide()
end
--------------------------------------------------------- frame level monitor --
local function FrameOnUpdate(self)
    self.kui:SetFrameLevel(self:GetFrameLevel())
end
----------------------------------------------------------------------- Sizer --
local function SizerOnSizeChanged(self,x,y)
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

    -- hide blizzard's nameplate
    frame.UnitFrame:Hide()
    frame.UnitFrame:HookScript('OnShow',function(self)
        self:Hide()
    end)

    frame.kui:SetScale(self.uiscale)
    frame.kui:SetSize(self.width,self.height)

    if self.draw_frames then
        -- debug; visible frame sizes
        frame:SetBackdrop({ edgeFile = kui.m.t.solid, edgeSize = 1 })
        frame:SetBackdropBorderColor(0,0,0)
        frame.kui:SetBackdrop({ edgeFile = kui.m.t.solid, edgeSize = 1 })
        frame.kui:SetBackdropBorderColor(1,1,1)
    end

    frame.kui.handler = { parent = frame.kui }
    setmetatable(frame.kui.handler, self.Nameplate)

    -- base frame
    frame:HookScript('OnHide',FrameOnHide)
    frame:HookScript('OnUpdate',FrameOnUpdate)

    frame.kui.handler:Create()

    if frame.namePlateUnitToken and frame:IsShown() then
        -- force the first OnShow
        frame.kui.handler:OnUnitAdded(frame.namePlateUnitToken)
    end
end
