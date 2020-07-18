--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Create base frame and hook scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates
--------------------------------------------------------------------------------
-------------------------------------------------------- Core script handlers --
local function FrameOnHide(self)
    self.kui.handler:OnHide()
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

    -- XXX 901, .UnitFrame doesn't stay hidden when interface options is
    -- opened, and some other cases. Old OnShow script doesn't stick.
    parent:HookScript('OnHide',FrameOnHide)

    parent.kui = kui
    kui.handler:Create()
end
