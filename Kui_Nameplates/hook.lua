--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Create base frame and hook scripts
--------------------------------------------------------------------------------
local addon = KuiNameplates
local function UnitFrame_OnShow(self)
    -- hide blizzard nameplate frames
    if addon.debug_units then
        addon:print('default unit frame shown',self:GetParent():GetName())
    end
    if self:GetParent().kui and self:GetParent().kui:IsShown() then
        self:Hide()
    end
end
local function FrameOnHide(self)
    self.kui.handler:OnHide()
end
function addon.NamePlateDriverFrame_AcquireUnitFrame(_,frame)
    if not frame.UnitFrame:IsForbidden() and not frame.UnitFrame.kui then
        frame.UnitFrame.kui = true
        frame.UnitFrame:HookScript('OnShow',UnitFrame_OnShow)
    end
end
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
        if not parent.SetBackdrop then
            Mixin(parent,BackdropTemplateMixin)
            Mixin(kui,BackdropTemplateMixin)
        end
        parent:SetBackdrop({bgFile='interface/buttons/white8x8'})
        parent:SetBackdropColor(0,0,0)
        kui:SetBackdrop({edgeFile='interface/buttons/white8x8',edgeSize=1})
        kui:SetBackdropBorderColor(1,1,1)
    end

    if parent.UnitFrame then
        -- XXX holdover for 8.3.x/9.x cross-compatibility
        self.NamePlateDriverFrame_AcquireUnitFrame(nil,parent)
    end

    parent:HookScript('OnHide',FrameOnHide)
    -- API event NAME_PLATE_UNIT_ADDED shows frames via OnUnitAdded

    parent.kui = kui
    kui.handler:Create()
end
