-- listen for health events and dispatch to nameplates
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('HealthBar')
local RMH

-- prototype additions #########################################################
function addon.Nameplate.UpdateHealthColour(f,show)
    f = f.parent

    local r,g,b
    local react = UnitReaction(f.unit,'player') or 4

    if UnitIsTapDenied(f.unit) then
        r,g,b = unpack(ele.colours.tapped)
    elseif UnitIsPlayer(f.unit) then
        if f.state.personal then
            -- personal nameplate
            if ele.colours.self then
                r,g,b = unpack(ele.colours.self)
            else
                r,g,b = kui.GetClassColour(f.unit,2)
            end
        elseif UnitCanAttack('player',f.unit) then
            -- hostile players
            if ele.colours.enemy_player then
                r,g,b = unpack(ele.colours.enemy_player)
            else
                r,g,b = kui.GetClassColour(f.unit,2)
            end
        else
            -- friendly players
            if ele.colours.player then
                r,g,b = unpack(ele.colours.player)
            else
                r,g,b = kui.GetClassColour(f.unit,2)
            end
        end
    else
        if react == 4 then
            -- neutral NPCs
            r,g,b = unpack(ele.colours.neutral)
        elseif react > 4 then
            -- friendly NPCs
            if UnitPlayerControlled(f.unit) and ele.colours.friendly_pet then
                -- friendly pet
                r,g,b = unpack(ele.colours.friendly_pet)
            else
                r,g,b = unpack(ele.colours.friendly)
            end
        else
            -- hostile NPCs
            if UnitPlayerControlled(f.unit) and ele.colours.enemy_pet then
                -- hostile player pet
                r,g,b = unpack(ele.colours.enemy_pet)
            else
                r,g,b = unpack(ele.colours.hated)
            end
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

    if RMH then
        f.state.health_cur, f.state.health_max = RMH.GetUnitHealth(f.unit)
    else
        f.state.health_cur = UnitHealth(f.unit)
        f.state.health_max = UnitHealthMax(f.unit)
    end

    f.state.health_deficit = f.state.health_max - f.state.health_cur
    f.state.health_per =
        f.state.health_cur > 0 and f.state.health_max > 0 and
        (f.state.health_cur / f.state.health_max) * 100 or
        0

    if f.elements.HealthBar then
        f.HealthBar:SetMinMaxValues(0,f.state.health_max)
        f.HealthBar:SetValue(f.state.health_cur)
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
function ele:FactionUpdate(f)
    f.handler:UpdateHealthColour()
end
-- events ######################################################################
function ele:UNIT_HEALTH(_,f)
    f.handler:UpdateHealth()
end
-- register ####################################################################
function ele:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterMessage('FactionUpdate')
    self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT','UNIT_HEALTH')
end
function ele:Initialise()
    if kui.CLASSIC and RealMobHealth then
        RMH = RealMobHealth
    end
    self.colours = {
        hated    = { .7, .2, .1 },
        neutral  = {  1, .8,  0 },
        friendly = { .2, .6, .1 },
        tapped   = { .5, .5, .5 },
        player   = { .2, .5, .9 }
    }
end
