-- listen for health events and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('HealthBar')
-- prototype additions #########################################################
function addon.Nameplate.UpdateHealthColour(f,show)
    f = f.parent

    local r,g,b
    local react = UnitReaction(f.unit,'player')

    if UnitIsTapDenied(f.unit) then
        r,g,b = unpack(ele.colours.tapped)
    elseif UnitIsPlayer(f.unit) then
        if  not UnitIsUnit('player',f.unit) and
            UnitIsFriend('player',f.unit)
        then
            r,g,b = unpack(ele.colours.player)
        else
            r,g,b = kui.GetClassColour(f.unit,2)
        end
    else
        if react == 4 then
            r,g,b = unpack(ele.colours.neutral)
        elseif react > 4 then
            r,g,b = unpack(ele.colours.friendly)
        else
            r,g,b = unpack(ele.colours.hated)
        end
    end

    f.state.healthColour = { r,g,b }
    f.state.reaction = react

    if f.elements.HealthBar then
        f.HealthBar:SetStatusBarColor(r,g,b)
    end

    if not show then
        addon:DispatchMessage('HealthColourChange', f)
    end
end
function addon.Nameplate.UpdateHealth(f,show)
    f = f.parent

    if f.elements.HealthBar then
        f.HealthBar:SetMinMaxValues(0,UnitHealthMax(f.unit))
        f.HealthBar:SetValue(UnitHealth(f.unit))
    end

    if not show then
        addon:DispatchMessage('HealthUpdate', f)
    end
end
-- messages ####################################################################
function ele:Show(f)
    f.handler:UpdateHealth(true)
    f.handler:UpdateHealthColour(true)
end
-- events ######################################################################
function ele:UNIT_FACTION(event,f)
    f.handler:UpdateHealthColour()
end
function ele:UNIT_HEALTH(event,f)
    f.handler:UpdateHealth()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')

    self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT','UNIT_HEALTH')
    self:RegisterUnitEvent('UNIT_FACTION')
end
function ele:Initialise()
    self.colours = {
        hated    = { .7, .2, .1 },
        neutral  = {  1, .8,  0 },
        friendly = { .2, .6, .1 },
        tapped   = { .5, .5, .5 },
        player   = { .2, .5, .9 }
    }
end
