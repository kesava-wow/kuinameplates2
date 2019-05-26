-- check mouseover and fire OnEnter/OnLeave messages, Show/Hide Highlight
local addon = KuiNameplates
local ele = addon:NewElement('Highlight')
-- highlight checker frame #####################################################
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
    if f.parent.state.highlight then return end

    f = f.parent
    f.state.highlight = true

    if f.elements.Highlight and
       (f.unit and not UnitIsUnit(f.unit,'target'))
    then
        f.Highlight:Show()
    end

    HighlightUpdateFrame:Highlight(f)

    addon:DispatchMessage('OnEnter', f)
end
function addon.Nameplate.HighlightHide(f)
    if not f.parent.state.highlight then return end

    f = f.parent
    f.state.highlight = nil

    if f.elements.Highlight then
        f.Highlight:Hide()
    end

    addon:DispatchMessage('OnLeave', f)
end
-- messages ####################################################################
function ele:Show(f)
    if UnitIsUnit('mouseover',f.unit) then
        f.handler:HighlightShow()
    end
end
function ele:Hide(f)
    f.handler:HighlightHide()
end
function ele:GainedTarget(f)
    if f.elements.Highlight and f.state.highlight then
        f.Highlight:Hide()
    end
end
function ele:LostTarget(f)
    if f.elements.Highlight and f.state.highlight then
        f.Highlight:Show()
    end
end
-- events ######################################################################
function ele:UPDATE_MOUSEOVER_UNIT()
    local f = addon:GetActiveNameplateForUnit('mouseover')
    if not f then return end
    f.handler:HighlightShow()
end
-- register ####################################################################
function ele:EnableOnFrame(f)
    if not f.Highlight then return end
    if f.state.highlight then
        f.Highlight:Show()
    else
        f.Highlight:Hide()
    end
end
function ele:DisableOnFrame(f)
    if not f.Highlight then return end
    f.Highlight:Hide()
end
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterMessage('GainedTarget')
    self:RegisterMessage('LostTarget')
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
end
