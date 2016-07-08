-- provide unit classification to frame state
-- provide RareIcon and BossIcon elements
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('Classification',1)
-- prototype additions #########################################################
-- messages ####################################################################
function ele:Show(f,on_show)
    local c = UnitClassification(f.unit)
    f.state.minus = c == "minus"
    f.state.classification = c

    if f.elements.BossIcon then
        if c == 'worldboss' then
            f.BossIcon:Show()
        else
            f.BossIcon:Hide()
        end
    end

    if f.elements.RareIcon then
        if c == 'rare' or c == 'rareelite' then
            f.RareIcon:Show()
        else
            f.RareIcon:Hide()
        end
    end

    if not on_show then
        addon:DispatchMessage('ClassificationChanged', f)
    end
end
-- events ######################################################################
function ele:UNIT_CLASSIFICATION_CHANGED(event,f)
    self:Show(f,true)
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_CLASSIFICATION_CHANGED')
end
