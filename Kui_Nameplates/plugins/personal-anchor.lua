-- provides the KuiNameplatesPlayerAnchor frame on the personal nameplate.
local mod = KuiNameplates:NewPlugin('PlayerAnchor')

local anchor
-- messages ####################################################################
function mod:Show(f)
    if f.state.personal then
        anchor:SetParent(f)
        anchor:SetAllPoints(f)
        anchor:Show()
    end
end
function mod:Hide(f)
    if f.state.personal then
        anchor:ClearAllPoints()
        anchor:Hide()
    end
end
-- register ####################################################################
function mod:OnEnable()
    if not anchor then
        anchor = CreateFrame('Frame','KuiNameplatesPlayerAnchor')
        anchor:Hide()

        -- TMW needs the parent to have a point set initially
        anchor:SetSize(1,1)
        anchor:SetPoint('CENTER',UIParent)

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
