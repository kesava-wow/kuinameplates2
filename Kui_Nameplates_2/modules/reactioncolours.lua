--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Replaces default reaction colours
--------------------------------------------------------------------------------
local addon = KuiNameplates
local reaction = {}

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

reaction.HealthColourChange = function(f)
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

    if f.elements.Healthbar then
        f.Healthbar:SetStatusBarColor(unpack(f.state.reactionColour))
    end
end

function reaction:Initialise()
    self:RegisterMessage('HealthColourChange')
end

addon:RegisterPlugin(reaction)
