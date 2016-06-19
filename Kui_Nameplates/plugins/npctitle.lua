-- parse npc tooltips to get their "guild" name and provide to frame.state
local addon = KuiNameplates
local mod = addon:NewPlugin('NPCTitle')

local tooltip = CreateFrame('GameTooltip','KNPNPCTitleTooltip',UIParent,'GameTooltipTemplate')
-- messages ####################################################################
function mod:Show(f)
    if not UnitIsPlayer(f.unit) and not UnitPlayerControlled(f.unit) then
        tooltip:SetOwner(UIParent,ANCHOR_NONE)
        tooltip:SetUnit(f.unit)

        local gtext = KNPNPCTitleTooltipTextLeft2:GetText()
        tooltip:Hide()

        if not gtext or gtext:find('^Level ') then return end
        f.state.guild_text = gtext
    end
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('Show')
end
