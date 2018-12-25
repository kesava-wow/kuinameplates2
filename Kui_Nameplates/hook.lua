--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Create base frame and hook scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates

local WorldFrame = WorldFrame
local select, strfind, setmetatable, floor
    = select, strfind, setmetatable, floor
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
function addon:HookNameplate(parent)
    local kui = CreateFrame('Frame','Kui'..parent:GetName(),parent)

    kui:Hide()
    kui:SetAllPoints()
    kui:SetFrameStrata('BACKGROUND')
    kui:SetFrameLevel(0)
    kui:SetScale(addon.uiscale)

    kui.state = {}
    kui.elements = {}
    kui.parent = parent

    kui.handler = { parent = kui }
    setmetatable(kui.handler,addon.Nameplate)

    if self.draw_frames then
        -- debug; visible frames
        parent:SetBackdrop({bgFile='interface/buttons/white8x8'})
        parent:SetBackdropColor(0,0,0)
        kui:SetBackdrop({edgeFile='interface/buttons/white8x8',edgeSize=1})
        kui:SetBackdropBorderColor(1,1,1)
    end

    if parent.UnitFrame then
        parent.UnitFrame:HookScript('OnShow',FrameOnShow)
    end

    parent:HookScript('OnHide',FrameOnHide)
    parent:HookScript('OnUpdate',FrameOnUpdate)

    parent.kui = kui
    kui.handler:Create()
end
