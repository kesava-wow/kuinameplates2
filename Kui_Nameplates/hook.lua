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

    frame.kui:SetScale(self.uiscale)
    frame.kui:SetSize(self.width,self.height)

    -- XXX no longer flashes text as of 80100
    -- however, we still don't want to inherit the alpha or scale of the
    -- default nameplates
    frame.kui:SetPoint('CENTER',frame)

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
