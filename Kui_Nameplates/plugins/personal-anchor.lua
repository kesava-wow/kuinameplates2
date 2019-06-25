-- provides the KuiNameplatesPlayerAnchor frame on the personal nameplate.
local mod = KuiNameplates:NewPlugin('PlayerAnchor')
local anchor
-- local functions #############################################################
local function Reset()
    -- reset anchor position & parent
    anchor:ClearAllPoints()
    anchor:SetParent(UIParent)
    anchor:Hide()

    -- set a default point
    anchor:SetPoint('CENTER')
    anchor:SetSize(1,1)
end
-- messages ####################################################################
function mod:Show(f)
    if f.state.personal then
        anchor:ClearAllPoints()
        anchor:SetParent(f.parent)
        anchor:SetAllPoints(f.parent)
        anchor:Show()
    end
end
function mod:Hide(f)
    if f.state.personal then
        Reset()
    end
end
-- register ####################################################################
function mod:OnEnable()
    if not anchor then
        anchor = CreateFrame('Frame','KuiNameplatesPlayerAnchor')
        anchor:Hide()
        Reset()

        if KuiNameplates.draw_frames then
            anchor:SetBackdrop({
                edgeFile = 'interface/buttons/white8x8',
                edgeSize = 1
            })
            anchor:SetBackdropBorderColor(0,0,1)
        end
    end

    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
end
function mod:OnDisable()
    self:Hide()
end
