-- listen for power events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('PowerBar')

local colours = {}

-- prototype additions #########################################################
function addon.Nameplate.UpdatePower(f,on_show)
    f = f.parent

    if f.elements.PowerBar then
        if f.state.power_type then
            local power_type = f.state.power_type

            f.PowerBar:SetMinMaxValues(0,UnitPowerMax(f.unit,power_type))
            f.PowerBar:SetValue(UnitPower(f.unit,power_type))

            -- TODO stagger
            if colours[power_type] and power_type ~= 'STAGGER' then
                f.PowerBar:SetStatusBarColor(unpack(colours[power_type]))
            end
        else
            f.PowerBar:SetStatusBarColor(0,0,0)
            f.PowerBar:SetValue(0)
        end
    end

    if not on_show then
        addon:DispatchMessage('PowerUpdate', f)
    end
end
-- messages ####################################################################
function ele:Show(f)
    -- get unit's primary power type
    local power_type = select(2,UnitPowerType(f.unit))
    local power_max = UnitPowerMax(f.unit,power_type)

    if power_max == 0 then
        power_type = nil
    end

    f.state.power_type = power_type

    -- and update display
    f.handler:UpdatePower(true)
end
-- events ######################################################################
function ele:PowerTypeEvent(event,f)
    self:Show(f)
end
function ele:PowerEvent(event,f)
    f.handler:UpdatePower()
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
ele:RegisterUnitEvent('UNIT_DISPLAYPOWER','PowerTypeEvent')
ele:RegisterUnitEvent('UNIT_MAXPOWER','PowerTypeEvent')
ele:RegisterUnitEvent('UNIT_POWER_FREQUENT','PowerEvent')
ele:RegisterUnitEvent('UNIT_POWER','PowerEvent')
