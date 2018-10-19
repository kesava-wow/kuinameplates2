--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Create base frame and hook scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates
-------------------------------------------------------- Core script handlers --
local function FrameOnHide(self)
    self.kui.handler:OnHide()
end
local function FrameOnShow(self)
    if not addon.USE_BLIZZARD_PERSONAL or
       not self.unit or
       not UnitIsUnit(self.unit,'player')
    then
        self:Hide()
    end
end
------------------------------------------------------------ Nameplate hooker --
-- hook into nameplate frame and element scripts
function addon:HookNameplate(frame)
    frame.kui = CreateFrame('Frame','Kui'..frame:GetName(),frame)
    frame.kui:Hide()
    frame.kui:SetAllPoints(frame)
    frame.kui:SetFrameLevel(0)
    frame.kui:SetScale(self.uiscale)

    -- apply Nameplate prototype (from nameplate.lua)
    frame.kui.handler = { parent = frame.kui }
    setmetatable(frame.kui.handler, self.Nameplate)

    frame.kui.state = {}
    frame.kui.elements = {}
    frame.kui.parent = frame

    if self.draw_frames then
        -- debug; visible frame sizes
        frame:SetBackdrop({bgFile='interface/buttons/white8x8'})
        frame:SetBackdropColor(0,0,0)
        frame.kui:SetBackdrop({edgeFile='interface/buttons/white8x8',edgeSize=1})
        frame.kui:SetBackdropBorderColor(1,1,1)
    end

    if frame.UnitFrame then
        -- hide the vanilla ui
        -- TODO this is terrible
        frame.UnitFrame:HookScript('OnShow',FrameOnShow)
    end

    frame:HookScript('OnHide',FrameOnHide)
    frame.kui.handler:Create()
end
