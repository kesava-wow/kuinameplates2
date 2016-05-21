local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('Classification',1)
-- prototype additions #########################################################
-- messages ####################################################################
function ele:Show(f)
    local c = UnitClassification(f.unit)
    f.state.minus = c == "minus"

    if c ~= 'minus' and c ~= 'normal' then
        addon:print((f.state.name or 'nil')..' is c:'..c)
    end

    -- TODO elite, boss, rare icons etc
end
-- events ######################################################################
function ele:UNIT_CLASSIFICATION_CHANGED(event,f)
    self:Show(f)
end
-- register ####################################################################
ele:RegisterMessage('Show')
ele:RegisterUnitEvent('UNIT_CLASSIFICATION_CHANGED')
