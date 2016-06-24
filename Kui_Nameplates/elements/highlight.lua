-- check mouseover and fire OnEnter/OnLeave messages, Show/Hide Highlight
local addon = KuiNameplates
local ele = addon:NewElement('Highlight')
-- hightlight checker frame ####################################################
local HighlightUpdateFrame = CreateFrame('Frame')
local function HighlightUpdate(self)
    if not self.current or not self.current.unit then
        -- currently highlighted frame no longer exists
        self.current = nil
        self:SetScript('OnUpdate',nil)
    elseif
        not UnitExists('mouseover') or
        not UnitIsUnit('mouseover',self.current.unit)
    then
        -- currently highlighted frame no longer has mouseover
        self.current.handler:HighlightHide()
        self.current = nil
        self:SetScript('OnUpdate',nil)
    end
end
function HighlightUpdateFrame:Highlight(f)
    if self.current then
        self.current.handler:HighlightHide()
    end

    self.current = f
    self:SetScript('OnUpdate',HighlightUpdate)
end
-- prototype additions #########################################################
function addon.Nameplate.HighlightShow(f)
    f = f.parent
    if f.state.highlight then return end
    f.state.highlight = true

    if f.elements.Highlight then
        f.Highlight:Show()
    end

    HighlightUpdateFrame:Highlight(f)

    addon:DispatchMessage('OnEnter', f)
end
function addon.Nameplate.HighlightHide(f)
    f = f.parent
    if not f.state.highlight then return end
    f.state.highlight = nil

    if f.elements.Highlight then
        f.Highlight:Hide()
    end

    addon:DispatchMessage('OnLeave', f)
end
-- messages ####################################################################
function ele:Show(f)
    -- this could of course cause problems if, for whatever reason, multiple
    -- nameplates have the same unit. at some point.
    if UnitIsUnit('mouseover',f.unit) then
        f.handler:HighlightShow()
    end
end
function ele:Hide(f)
    f.handler:HighlightHide()
end
-- events ######################################################################
function ele:UPDATE_MOUSEOVER_UNIT(event)
    local f = C_NamePlate.GetNamePlateForUnit('mouseover')
    if not f then return end
    f = f.kui

    f.handler:HighlightShow()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
end
