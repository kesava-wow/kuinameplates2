-- provides frame.state[...]: guild_text
--   guild_text = player guilds, NPC vendor/tooltip titles, pet owners
local addon = KuiNameplates
local mod = addon:NewPlugin('GuildText')

local UnitIsPlayer,UnitIsOtherPlayersPet,GetGuildInfo=
      UnitIsPlayer,UnitIsOtherPlayersPet,GetGuildInfo

local tooltip = CreateFrame('GameTooltip','KNPNPCTitleTooltip',nil,'GameTooltipTemplate')
local cb_tooltips
local pattern,pattern_type

-- messages ####################################################################
function mod:Show(f)
    f.state.guild_text = nil

    if UnitIsPlayer(f.unit) then
        local guild = GetGuildInfo(f.unit)

        if guild and guild ~= 0 then
            f.state.guild_text = guild
        end
    elseif not UnitIsOtherPlayersPet(f.unit) then
        -- parse NPC tooltip
        tooltip:SetOwner(WorldFrame,'ANCHOR_NONE')
        tooltip:SetUnit(f.unit)

        -- luacheck:globals KNPNPCTitleTooltipTextLeft2 KNPNPCTitleTooltipTextLeft3
        local gtext = cb_tooltips and
                      KNPNPCTitleTooltipTextLeft3:GetText() or
                      KNPNPCTitleTooltipTextLeft2:GetText()

        -- ignore strings matching TOOLTIP_UNIT_LEVEL
        if not gtext or
           (pattern and gtext:find(pattern)) or
           (pattern_type and gtext:find(pattern_type))
        then
            return
        end

        f.state.guild_text = gtext
    end
end
-- events ######################################################################
function mod:CVAR_UPDATE()
    cb_tooltips = GetCVarBool('colorblindmode')
end
-- register ####################################################################
function mod:Initialise()
    -- generate matching pattern for locale
    -- replace format substitution with match anything
    local function FixPattern(source)
        if not source then return end
        return "^"..source:gsub("%%.%$?s?",".+").."$"
    end
    pattern = FixPattern(TOOLTIP_UNIT_LEVEL)
    pattern_type = FixPattern(TOOLTIP_UNIT_LEVEL_TYPE)
end
function mod:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterEvent('CVAR_UPDATE')
    self:CVAR_UPDATE()
end
