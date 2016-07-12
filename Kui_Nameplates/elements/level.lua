-- get unit name and provide to LevelText element
local addon = KuiNameplates
local ele = addon:NewElement('LevelText')
local kui = LibStub('Kui-1.0')
-- prototype additions #########################################################
function addon.Nameplate.UpdateLevel(f)
    f = f.parent
    f.state.level = UnitLevel(f.unit) or 0

    if f.elements.LevelText then
        local l,cl,d = kui.UnitLevel(f.unit)
        f.LevelText:SetText(l..cl)
        f.LevelText:SetTextColor(d.r,d.g,d.b)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateLevel()
end
-- events ######################################################################
function ele:UNIT_LEVEL(event,f)
    f.handler:UpdateLevel()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_LEVEL')
end
