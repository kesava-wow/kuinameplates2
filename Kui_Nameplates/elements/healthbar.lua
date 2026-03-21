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
function addon.Nameplate.UpdateHealth(f, show)
    f = f.parent

    local cur, max
    if RMH then
        cur, max = RMH.GetUnitHealth(f.unit)
    else
        cur = UnitHealth(f.unit)
        max = UnitHealthMax(f.unit)
    end

    -- Always allow the actual bar to update.
    if f.elements.HealthBar then
        f.HealthBar:SetMinMaxValues(0, max)
        f.HealthBar:SetValue(cur)
    end

    -- Store raw values only if they are safe to use in Lua arithmetic.
    local ok_deficit, deficit = pcall(function()
        return max - cur
    end)

    local ok_percent, percent = pcall(function()
        if cur > 0 and max > 0 then
            return (cur / max) * 100
        else
            return 0
        end
    end)

    if ok_deficit and ok_percent then
        f.state.health_cur = cur
        f.state.health_max = max
        f.state.health_deficit = deficit
        f.state.health_per = percent
    else
        -- Secret / protected values, so disable derived text logic safely.
        f.state.health_cur = nil
        f.state.health_max = nil
        f.state.health_deficit = 0
        f.state.health_per = nil
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
    self:RegisterUnitEvent(kui.UNIT_HEALTH,'UNIT_HEALTH')
end
function ele:Initialise()
    if kui.CLASSIC and RealMobHealth and RealMobHealth.GetUnitHealth then
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
