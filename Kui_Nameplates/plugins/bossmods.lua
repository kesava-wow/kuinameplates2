-- boss mod callback handlers
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local bw_loader
local plugin_ct

-- callbacks ###################################################################
do
    local prev_val
    local function BigWigs_EnableFriendlyNameplates()
        -- override CombatToggle
        plugin_ct:PLAYER_REGEN_DISABLED()
        plugin_ct:Disable()

        prev_val = GetCVar('nameplateShowFriends')
        SetCVar('nameplateShowFriends',1)
    end
    local function BigWigs_DisableFriendlyNameplates()
        plugin_ct:Enable()

        if not InCombatLockdown() then
            SetCVar('nameplateShowFriends',prev_val)
            plugin_ct:PLAYER_REGEN_ENABLED()
        end
    end
end
-- register ####################################################################
function mod:OnEnable()
    bw_loader = BigWigsLoader

    if bw_loader then
        plugin_ct = addon:GetPlugin('CombatToggle')

        bw_loader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates',BigWigs_EnableFriendlyNameplates)
        bw_loader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates',BigWigs_DisableFriendlyNameplates)
    end
end
