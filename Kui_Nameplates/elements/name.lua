-- get unit name and provide to the NameText element
local addon = KuiNameplates
local ele = addon:NewElement('NameText')
-- prototype additions #########################################################
function addon.Nameplate.UpdateName(f)
    f = f.parent
    f.state.name = UnitName(f.unit) or ''

    if f.elements.NameText then
        f.NameText:SetText(f.state.name)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateName()
end
-- events ######################################################################
function ele:UNIT_NAME_UPDATE(event,f)
    f.handler:UpdateName()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')
end
