-- boss mod callback handlers
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local active_boss_auras
local bw_loader
local plugin_ct

-- callbacks ###################################################################
do
    local prev_val
    function mod:BigWigs_EnableFriendlyNameplates()
        -- override CombatToggle
        plugin_ct:PLAYER_REGEN_DISABLED()
        plugin_ct:Disable()

        prev_val = GetCVar('nameplateShowFriends')
        SetCVar('nameplateShowFriends',1)
    end
    function mod:BigWigs_DisableFriendlyNameplates()
        plugin_ct:Enable()

        if not InCombatLockdown() then
            SetCVar('nameplateShowFriends',prev_val)
            plugin_ct:PLAYER_REGEN_ENABLED()
        end
    end
end

function mod:BigWigs_ShowNameplateAura(unit,icon)
    -- store icon by guid so we can show/hide icons if the frame isn't
    -- already visible
    local guid = UnitGUID(unit)

    if not active_boss_auras then
        active_boss_auras = {}
    end

    active_boss_auras[guid] = icon

    -- immediately show if they already have a frame
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if f and f.kui and f.kui.BossModIcon then
        f.kui.BossModIcon:SetTexture(icon)
        f.kui.BossModIcon:Show()
    end
end
function mod:BigWigs_HideNameplateAura(unit)
    if active_boss_auras then
        -- remove from guid list
        local guid = UnitGUID(unit)
        active_boss_auras[guid] = nil
    end

    -- immediately hide
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if f and f.kui and f.kui.BossModIcon then
        f.kui.BossModIcon:Hide()
    end
end
-- messages ####################################################################
function mod:Show(f)
    if not active_boss_auras then return end

    local guid = UnitGUID(f.unit)
    local icon = active_boss_auras[guid]

    if icon then
        f.BossModIcon:SetTexture(icon)
        f.BossModIcon:Show()
    end
end
function mod:Hide(f)
    f.BossModIcon:Hide()
end
function mod:Create(f)
    -- TODO create icon for testing
    -- size & position in layout
    -- possibly also want stacks, cd frame?
    local icon = f:CreateTexture(nil,'ARTWORK',nil,1)
    icon:SetTexture('interface/buttons/white8x8')
    icon:SetSize(30,30)

    icon:SetPoint('BOTTOMLEFT',f,'TOPLEFT',
        (f:GetWidth() / 2) - (icon:GetWidth() / 2),
        10)

    icon:Hide()

    f.BossModIcon = icon
end
-- register ####################################################################
function mod:OnEnable()
    bw_loader = BigWigsLoader

    if bw_loader then
        self:RegisterMessage('Show')
        self:RegisterMessage('Hide')
        self:RegisterMessage('Create')

        plugin_ct = addon:GetPlugin('CombatToggle')

        bw_loader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates')
        bw_loader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates')

        bw_loader.RegisterMessage(mod,'BigWigs_ShowNameplateAura')
        bw_loader.RegisterMessage(mod,'BigWigs_HideNameplateAura')
    end
end
