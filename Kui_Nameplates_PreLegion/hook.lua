local folder,ns=...
local addon = KuiNameplates

KuiNameplatesPreLegion = addon:Layout()
local layout = KuiNameplatesPreLegion
if not layout then return end

-- messages ####################################################################
function layout:Create(f)
    self:CreateBorder(f)
    self:CreateHealthBar(f)
    self:CreateCastBar(f)
    self:CreateStateIcon(f)
end
function layout:Show(f)
    self:UNIT_LEVEL(nil,f)
    self:ClassificationChanged(f)
end
function layout:CastBarShow(f)
    -- show attached elements
    f.CastBar.bg:Show()
    f.CastBar.icon:Show()

    -- set bg texture
    self:UpdateCastBar(f)
end
function layout:CastBarHide(f)
    -- hide attached elements
    f.CastBar.bg:Hide()
    f.CastBar.icon:Hide()
end
function layout:ClassificationChanged(f)
    self:UpdateStateIcon(f)
end
-- events ######################################################################
function layout:UNIT_LEVEL(event,f)
    local c = GetQuestDifficultyColor(f.state.level <= 0 and 999 or f.state.level)
    f.LevelText:SetText(f.state.level == -1 and '??' or f.state.level)
    f.LevelText:SetTextColor(c.r,c.g,c.b)
end
-- initialise ##################################################################
function layout:Initialise()
    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('CastBarShow')
    self:RegisterMessage('CastBarHide')
    self:RegisterMessage('ClassificationChanged')

    self:RegisterUnitEvent('UNIT_LEVEL')
end
