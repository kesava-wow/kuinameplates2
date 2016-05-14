-- check mouseover
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('highlight')
-- local functions #############################################################
local HighlightUpdateFrame = CreateFrame('Frame')
local function HighlightUpdate(self)
    if not UnitExists('mouseover') then
        self.current.handler:HighlightHide()
    end
end
-- prototype additions #########################################################
function addon.Nameplate.HighlightShow(f)
    f = f.parent
    f.state.highlight = true

    if f.elements.Highlight then
        f.Highlight:Show()
    end

    HighlightUpdateFrame.current = f
    HighlightUpdateFrame:SetScript('Onupdate',HighlightUpdate)

    addon:DispatchMessage('OnEnter', f)
end
function addon.Nameplate.HighlightHide(f)
    f = f.parent
    f.state.highlight = nil

    if f.elements.Highlight then
        f.Highlight:Hide()
    end

    HighlightUpdateFrame.current = nil
    HighlightUpdateFrame:SetScript('OnUpdate',nil)

    addon:DispatchMessage('OnLeave', f)
end
-- messages ####################################################################
function ele.Hide(f)
    if f.elements.Highlight then
        f.Highlight:Hide()
    end
end
-- events ######################################################################
function ele:UPDATE_MOUSEOVER_UNIT(event)
    local f = C_NamePlate.GetNamePlateForUnit('mouseover')
    if not f then return end
    f = f.kui

    f.handler:HighlightShow()
end
-- register ####################################################################
ele:RegisterMessage('Hide')

ele:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
