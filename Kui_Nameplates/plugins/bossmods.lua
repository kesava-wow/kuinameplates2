-- Boss mod callback handlers
-- Please contact me on Curse or IRC (freenode, #wowace) if you want me to
-- add support for your messages.
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

local function ShowNameplateAura(f, icon_tbl)
    if not f or not icon_tbl or not f.BossModIcon then return end

    f.BossModIcon:SetTexture(icon_tbl[1])
    f.BossModIcon:Show()
end
local function HideNameplateAura(f)
    if not f or not f.BossModIcon then return end

    f.BossModIcon:Hide()
end
-- callbacks ###################################################################
do
    -- Show/hide friendly nameplates ###########################################
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    local prev_val
    function mod:BigWigs_EnableFriendlyNameplates()
        plugin_ct:Disable()

        if not InCombatLockdown() then
            -- skip CombatToggle into combat mode
            plugin_ct:PLAYER_REGEN_DISABLED()

            prev_val = GetCVar('nameplateShowFriends')
            SetCVar('nameplateShowFriends',1)
        end
    end
    function mod:BigWigs_DisableFriendlyNameplates()
        plugin_ct:Enable()

        if not InCombatLockdown() then
            SetCVar('nameplateShowFriends',prev_val)

            -- restore CombatToggle's desired out-of-combat settings
            plugin_ct:PLAYER_REGEN_ENABLED()
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

do
    -- Show/hide icon on nameplate belonging to given GUID #####################
    -- Duration is used to draw a cooldown on the icon
    --     If left nil, icon is treated as timeless
    -- The icon will not be hidden until HideNameplateAura is called
    function mod:BigWigs_ShowNameplateAura(sender,guid,icon,duration)
        -- store to show/hide when relevant frame's visibility changes
        if not active_boss_auras then
            active_boss_auras = {}
        end

        active_boss_auras[guid] = {icon,duration}

        -- immediately show if they already have a frame
        ShowNameplateAura(GetFrameByGUID(guid), active_boss_auras[guid])
    end
    function mod:BigWigs_HideNameplateAura(sender,guid)
        if active_boss_auras then
            -- remove from guid list
            active_boss_auras[guid] = nil
        end

        -- immediately hide
        HideNameplateAura(GetFrameByGUID(guid))
    end
end
-- messages ####################################################################
function mod:Show(f)
    if not active_boss_auras then return end

    local guid = UnitGUID(f.unit)
    if not guid then return end

    local icon_tbl = active_boss_auras[guid]
    if not icon_tbl then return end

    ShowNameplateAura(f,icon_tbl)
end
function mod:Hide(f)
    HideNameplateAura(f)
end
function mod:Create(f)
    -- TODO create icon for testing
    -- size & position in layout
    -- possibly also want stacks, cd frame?
    local icon = f:CreateTexture(nil,'ARTWORK',nil,1)
    icon:SetTexture('interface/buttons/white8x8')
    icon:SetSize(30,30)

    icon:SetPoint('BOTTOMLEFT',f,'TOPLEFT',
        floor((f:GetWidth() / 2) - (icon:GetWidth() / 2)),
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

        -- TODO conflict if both are enabled
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

            DBM:RegisterCallback('BossMod_ShowNameplateAura',function(msg,...)
                mod:BigWigs_ShowNameplateAura(nil,...)
            end)
            DBM:RegisterCallback('BossMod_HideNameplateAura',function(msg,...)
                mod:BigWigs_HideNameplateAura(nil,...)
            end)
        end
    end
end
