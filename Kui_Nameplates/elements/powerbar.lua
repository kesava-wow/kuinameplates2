-- listen for power events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('PowerBar')
-- prototype additions #########################################################
function addon.Nameplate.UpdatePower(f,on_show)
    f = f.parent
    if f.elements.PowerBar then
        if f.state.power_type then
            f.PowerBar:SetMinMaxValues(0,UnitPowerMax(f.unit,f.state.power_type))
            f.PowerBar:SetValue(UnitPower(f.unit,f.state.power_type))
        else
            f.PowerBar:SetValue(0)
        end

        if not on_show then
            addon:DispatchMessage('PowerUpdate', f)
        end
    end
end
function addon.Nameplate.UpdatePowerType(f,on_show)
    f = f.parent

    -- get unit's primary power type
    local power_type, power_token = UnitPowerType(f.unit)
    local power_max = UnitPowerMax(f.unit,power_type)

    if power_max == 0 then
        power_type = nil
    end

    f.state.power_type = power_type

    if f.elements.PowerBar then
        -- update bar colour
        if power_token then
            local colour = ele.colours[power_token] or ele.colours['MANA']
            f.PowerBar:SetStatusBarColor(unpack(colour))
        else
            f.PowerBar:SetStatusBarColor(0,0,0)
            f.PowerBar:SetValue(0)
        end
    end

    if not on_show then
        addon:DispatchMessage('PowerTypeUpdate', f)
    end

    -- and bar values
    f.handler:UpdatePower(on_show)
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdatePowerType(true)
end
-- events ######################################################################
function ele:PowerTypeEvent(event,f)
    f.handler:UpdatePowerType()
end
function ele:PowerEvent(event,f)
    f.handler:UpdatePower()
end
-- enable/disable per frame ####################################################
function ele:EnableOnFrame(frame)
    frame.PowerBar:Show()
    frame.handler:UpdatePowerType(true)
end
function ele:DisableOnFrame(frame)
    frame.PowerBar:Hide()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')

    self:RegisterUnitEvent('UNIT_DISPLAYPOWER','PowerTypeEvent')
    self:RegisterUnitEvent('UNIT_MAXPOWER','PowerTypeEvent')
    self:RegisterUnitEvent('UNIT_POWER_FREQUENT','PowerEvent')
    self:RegisterUnitEvent('UNIT_POWER','PowerEvent')
end
function ele:Initialise()
    self.colours = {}

    -- get default colours
    for p,c in next, PowerBarColor do
        if c.r and c.g and c.b then
            self.colours[p] = {c.r,c.g,c.b}
        end
    end
end
