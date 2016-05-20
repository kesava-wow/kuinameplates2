local addon = KuiNameplates
local ele = addon:NewElement('LevelText')
-- prototype additions #########################################################
function addon.Nameplate.UpdateLevel(f)
    f = f.parent
    f.state.level = f.unit and UnitLevel(f.unit)

    if f.elements.level then
        f.Level:SetText(f.state.level)
    end
end
-- messages ####################################################################
function ele.Show(f)
    f.handler:UpdateLevel()
end
-- events ######################################################################
function ele:UNIT_LEVEL(event,f)
    f.handler:UpdateLevel()
end
-- register ####################################################################
ele:RegisterMessage('Show')
ele:RegisterUnitEvent('UNIT_LEVEL')
