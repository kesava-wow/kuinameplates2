-- parse npc tooltips to get their "guild" name and provide to frame.state
local addon = KuiNameplates
local mod = addon:NewPlugin('NPCTitle')

local tooltip = CreateFrame('GameTooltip','KNPNPCTitleTooltip',UIParent,'GameTooltipTemplate')
GameTooltip_SetDefaultAnchor(tooltip,UIParent)
-- messages ####################################################################
function mod:Show(f)
    if not UnitIsPlayer(f.unit) then
        tooltip:SetUnit(f.unit)
        local gtext = KNPNPCTitleTooltipTextLeft2:GetText()
        if not gtext or gtext:find('^Level ') then return end
        f.state.guild_text = gtext
    end
end
-- register ####################################################################
function mod:Initialise()
    mod:RegisterMessage('Show')
end
