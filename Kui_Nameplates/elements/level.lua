-- get unit name and provide to LevelText element
local addon = KuiNameplates
local ele = addon:NewElement('LevelText')
local kui = LibStub('Kui-1.0')
local instanced_pvp
-- prototype additions #########################################################
function addon.Nameplate.UpdateLevel(f)
    f = f.parent
    f.state.level = instanced_pvp and UnitLevel(f.unit) or UnitEffectiveLevel(f.unit) or 0

    if f.elements.LevelText then
        local l,cl,d = kui.UnitLevel(f.unit,nil,instanced_pvp)
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
function ele:PLAYER_ENTERING_WORLD()
    local in_instance,instance_type = IsInInstance()
    instanced_pvp = in_instance and
                    (instance_type == 'arena' or instance_type == 'pvp')
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterUnitEvent('UNIT_LEVEL')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
