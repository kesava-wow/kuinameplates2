-- boss mod callback handlers
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local active_boss_auras
local plugin_ct

-- local functions #############################################################
local function GetFrameByGUID(guid)
    -- TODO store guids => frames OnShow/Hide
    for k,f in addon:Frames() do
        if f:IsShown() and UnitGUID(f.unit) == guid then
            return f
        end
    end
end
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

            -- TODO won't restore to previous setting if this is triggered
            -- during combat + CombatToggle isn't set up
        end

        -- we're assuming this is out of combat after the end of a boss, so we
        -- can also use it to clear all auras
        active_boss_auras = nil

        for k,f in addon:Frames() do
            if f:IsShown() then
                f.BossModIcon:Hide()
            end
        end
    end
end

function mod:BigWigs_ShowNameplateAura(guid,icon,duration)
    -- store icon so we can show/hide icons if the frame isn't already visible
    if not active_boss_auras then
        active_boss_auras = {}
    end

    active_boss_auras[guid] = icon

    -- immediately show if they already have a frame
    local f = GetFrameByGUID(guid)
    if f and f.BossModIcon then
        f.BossModIcon:SetTexture(icon)
        f.BossModIcon:Show()
    end
end
function mod:BigWigs_HideNameplateAura(guid)
    if active_boss_auras then
        -- remove from guid list
        active_boss_auras[guid] = nil
    end

    -- immediately hide
    local f = GetFrameByGUID(guid)
    if f and f.BossModIcon then
        f.BossModIcon:Hide()
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
    local BigWigsLoader = BigWigsLoader
    local DBM = DBM
    if BigWigsLoader or DBM then
        self:RegisterMessage('Show')
        self:RegisterMessage('Hide')
        self:RegisterMessage('Create')

        plugin_ct = addon:GetPlugin('CombatToggle')

        if BigWigsLoader then
            BigWigsLoader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates')
            BigWigsLoader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates')

            BigWigsLoader.RegisterMessage(mod,'BigWigs_ShowNameplateAura')
            BigWigsLoader.RegisterMessage(mod,'BigWigs_HideNameplateAura')
        end

        if DBM then
            DBM:RegisterCallback('BossMod_EnableFriendlyNameplates',function()
                mod:BigWigs_EnableFriendlyNameplates()
            end)
            DBM:RegisterCallback('BossMod_DisableFriendlyNameplates',function()
                mod:BigWigs_DisableFriendlyNameplates()
            end)

            DBM:RegisterCallback('BossMod_ShowNameplateAura',function(msg,guid,texture,duration)
                mod:BigWigs_ShowNameplateAura(guid,texture,duration)
            end)
            DBM:RegisterCallback('BossMod_HideNameplateAura',function(msg,guid,texture)
                mod:BigWigs_HideNameplateAura(guid)
            end)
        end
    end
end
