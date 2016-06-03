-- listen for power events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('PowerBar')

local colours = {}

-- prototype additions #########################################################
function addon.Nameplate.UpdatePower(f,show,power_type)
    f = f.parent

    f.state.power_type = power_type

    if f.elements.PowerBar then
        if power_type then
            f.PowerBar:SetMinMaxValues(0,UnitPowerMax(f.unit,power_type))
            f.PowerBar:SetValue(UnitPower(f.unit,power_type))

            if colours[power_type] and power_type ~= 'STAGGER' then
                f.PowerBar:SetStatusBarColor(unpack(colours[power_type]))
            end
        else
            f.PowerBar:SetValue(0)
            f.PowerBar:SetStatusBarColor(.5,.5,.5)
        end
    end

    if not show then
        addon:DispatchMessage('PowerUpdate', f)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdatePower(true,select(2,UnitPowerType(f.unit)))
end
-- events ######################################################################
function ele:UNIT_POWER(event,f,power_type)
    f.handler:UpdatePower(nil,power_type)
end
-- register ####################################################################
function ele:Initialise()
    -- get default colours
    for p,c in next, PowerBarColor do
        if p == 'STAGGER' then
            -- stagger has different colours for levels of stagger
            colours[p] = c
        else
            colours[p] = {c.r,c.g,c.b}
        end
    end
end
-- #############################################################################
ele:RegisterMessage('Show')
ele:RegisterUnitEvent('UNIT_DISPLAYPOWER','UNIT_POWER')
ele:RegisterUnitEvent('UNIT_MAXPOWER','UNIT_POWER')
ele:RegisterUnitEvent('UNIT_POWER_FREQUENT','UNIT_POWER')
ele:RegisterUnitEvent('UNIT_POWER')
