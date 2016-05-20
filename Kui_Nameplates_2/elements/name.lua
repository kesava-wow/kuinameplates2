local addon = KuiNameplates
local ele = addon:NewElement('NameText')
-- prototype additions #########################################################
function addon.Nameplate.UpdateName(f)
    f = f.parent
    f.state.name = f.unit and UnitName(f.unit)

    if f.elements.Name then
        f.Name:SetText(f.state.name)
    end
end
-- messages ####################################################################
function ele.Show(f)
    f.handler:UpdateName()
end
-- events ######################################################################
function ele:UNIT_NAME_UPDATE(event,f)
    f.handler:UpdateName()
end
-- register ####################################################################
ele:RegisterMessage('Show')
ele:RegisterUnitEvent('UNIT_NAME_UPDATE')
