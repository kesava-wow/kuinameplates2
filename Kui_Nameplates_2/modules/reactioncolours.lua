--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Replaces default reaction colours
--------------------------------------------------------------------------------
-- TODO this is obsolete and should probably just be moved into healthbar
local addon = KuiNameplates
local reaction = addon:NewPlugin('ReactionColours')

-- replacement reaction colours
-- (should be configurable, so this is placeholder)
local colours = {
    hated    = { .7, .2, .1 },
    neutral  = {  1, .8,  0 },
    friendly = { .2, .6, .1 },
    tapped   = { .5, .5, .5 },
    player   = { .2, .5, .9 }
}

local abs = abs
local function eq(t,v)
    if abs(t-v) < .1 then
        return true
    end
end

function reaction:Show(f)
    self:HealthColourChange(f)
end
function reaction:HealthColourChange(f)
    if not f.state.healthColour then return end
    local r,g,b = unpack(f.state.healthColour)

    if eq(g, 1) and r == 0 and b == 0 then
        -- friendly npc
        r,g,b = unpack(colours.friendly)
    elseif eq(b, 1) and r == 0 and g == 0 then
        -- friendly player
        r,g,b = unpack(colours.player)
    elseif eq(r, 1) and g == 0 and b == 0 then
        -- enemy NPC
        r,g,b = unpack(colours.hated)
    elseif eq(r, 1) and eq(g, 1) and b == 0 then
        -- netural
        r,g,b = unpack(colours.neutral)
    elseif eq(r, .5) and eq(g, .5) and eq(b, .5) then
        -- tapped
        r,g,b = unpack(colours.tapped)
    end

    f.state.reactionColour = { r, g, b }

    if f.elements.HealthBar then
        f.HealthBar:SetStatusBarColor(unpack(f.state.reactionColour))
    end
end

function reaction:Initialise()
    self:RegisterMessage('Show')
    self:RegisterMessage('HealthColourChange')
end
