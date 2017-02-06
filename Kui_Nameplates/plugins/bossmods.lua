-- Boss mod callback handlers
-- Please contact me on Curse or IRC (freenode, #wowace) if you want me to
-- add support for your messages.
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local ICON_SIZE, ICON_X_OFFSET, ICON_Y_OFFSET = 30,0,0
local CONTROL_FRIENDLY = true

local initialised
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

    local texture,start,expiry = unpack(icon_tbl)
    if not texture then return end

    if start and expiry then
        f.BossModIcon.cd:SetCooldown(start,expiry-start)
        f.BossModIcon.cd:Show()
    end

    f.BossModIcon.tex:SetTexture(texture)
    f.BossModIcon:Show()
end
local function HideNameplateAura(f)
    if not f or not f.BossModIcon then return end

    f.BossModIcon:Hide()
end
local function HideAllAuras()
    active_boss_auras = nil

    for k,f in addon:Frames() do
        if f:IsShown() then
            f.BossModIcon:Hide()
        end
    end
end
-- callbacks ###################################################################
do
    -- Show/hide friendly nameplates ###########################################
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    local prev_val
    function mod:BigWigs_EnableFriendlyNameplates()
        if not self.enabled or not CONTROL_FRIENDLY then return end

        plugin_ct:Disable()

        if addon.debug then
            addon:print('received EnableFriendlyNameplates')
            if InCombatLockdown() then
                addon:print('during combat')
            end
        end

        if not InCombatLockdown() then
            -- skip CombatToggle into combat mode
            plugin_ct:PLAYER_REGEN_DISABLED()

            prev_val = GetCVar('nameplateShowFriends')
            SetCVar('nameplateShowFriends',1)
        end
    end
    function mod:BigWigs_DisableFriendlyNameplates()
        if not self.enabled or not CONTROL_FRIENDLY then return end

        plugin_ct:Enable()

        if addon.debug then
            addon:print('received DisableFriendlyNameplates')
            if InCombatLockdown() then
                addon:print('during combat')
            end
        end

        if not InCombatLockdown() then
            SetCVar('nameplateShowFriends',prev_val)

            -- restore CombatToggle's desired out-of-combat settings
            plugin_ct:PLAYER_REGEN_ENABLED()
        end

        -- we're assuming this is out of combat after the end of a boss, so we
        -- can also use it to clear all auras
        HideAllAuras()
    end
end

do
    -- Show/hide icon on nameplate belonging to given GUID #####################
    -- Duration is used to draw a cooldown on the icon
    --     If left nil, icon is treated as timeless
    -- The icon will not be hidden until HideNameplateAura is called
    function mod:BigWigs_ShowNameplateAura(msg,sender,guid,icon,duration)
        if not self.enabled then return end

        -- store to show/hide when relevant frame's visibility changes
        if not active_boss_auras then
            active_boss_auras = {}
        end

        active_boss_auras[guid] = {
            icon,
            duration and GetTime(),
            duration and GetTime()+duration
        }

        -- immediately show if they already have a frame
        ShowNameplateAura(GetFrameByGUID(guid), active_boss_auras[guid])
    end
    function mod:BigWigs_HideNameplateAura(msg,sender,guid)
        if not self.enabled then return end

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
    local icon = CreateFrame('Frame',nil,f)
    icon:SetFrameStrata('LOW') -- above all nameplates
    icon:Hide()

    local tex = icon:CreateTexture(nil,'ARTWORK')
    tex:SetTexCoord(.1,.9,.1,.9)
    tex:SetAllPoints(icon)

    local cd = CreateFrame('Cooldown',nil,icon,'CooldownFrameTemplate')
    cd:SetAllPoints(tex)
    cd:SetReverse(true)
    cd:SetDrawEdge(false)
    cd:SetDrawBling(false)
    cd:SetHideCountdownNumbers(true)
    cd.noCooldownCount = true

    icon.tex = tex
    icon.cd = cd

    f.BossModIcon = icon

    self:UpdateIcon(f)
end
-- mod functions ###############################################################
function mod:UpdateIcon(f)
    -- set size, position based on config
    if not f.BossModIcon then return end

    f.BossModIcon:SetSize(ICON_SIZE,ICON_SIZE)
    f.BossModIcon:SetPoint('BOTTOMLEFT', f, 'TOPLEFT',
        floor((f:GetWidth() / 2) - (ICON_SIZE / 2)) + ICON_X_OFFSET,
        ICON_Y_OFFSET)
end
function mod:UpdateConfig()
    if not self.enabled then return end

    if type(addon.layout.BossModIcon) == 'table' then
        ICON_SIZE = addon.layout.BossModIcon.icon_size or ICON_SIZE
        ICON_X_OFFSET = addon.layout.BossModIcon.icon_x_offset or ICON_X_OFFSET
        ICON_Y_OFFSET = addon.layout.BossModIcon.icon_y_offset or ICON_Y_OFFSET
        CONTROL_FRIENDLY = addon.layout.BossModIcon.control_friendly or CONTROL_FRIENDLY
    end

    for i,f in addon:Frames() do
        -- update icons on existing frames
        self:UpdateIcon(f)
    end
end
-- callback registrars for different addons ####################################
local RegisterAddon
do
    local registered
    local cb_registrar = {
        ['BigWigs'] = function()
            BigWigsLoader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates')
            BigWigsLoader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates')

            BigWigsLoader.RegisterMessage(mod,'BigWigs_ShowNameplateAura')
            BigWigsLoader.RegisterMessage(mod,'BigWigs_HideNameplateAura')

            return true
        end,
        ['DBM'] = function()
            DBM:RegisterCallback('BossMod_EnableFriendlyNameplates',function()
                mod:BigWigs_EnableFriendlyNameplates()
            end)
            DBM:RegisterCallback('BossMod_DisableFriendlyNameplates',function()
                mod:BigWigs_DisableFriendlyNameplates()
            end)

            DBM:RegisterCallback('BossMod_ShowNameplateAura',function(msg,...)
                mod:BigWigs_ShowNameplateAura(msg,nil,...)
            end)
            DBM:RegisterCallback('BossMod_HideNameplateAura',function(msg,...)
                mod:BigWigs_HideNameplateAura(msg,nil,...)
            end)

            return true
        end,
    }
    function RegisterAddon(name)
        if registered and not addon.debug then return end
        if cb_registrar[name] then
            if cb_registrar[name]() then
                if addon.debug then
                    addon:print('registered '..name)
                end

                registered = name
            end
        end
    end
end
-- register ####################################################################
-- TODO OnDisable
function mod:OnEnable()
    if not initialised then return end
    if BigWigsLoader or DBM then
        self:RegisterMessage('Show')
        self:RegisterMessage('Hide')
        self:RegisterMessage('Create')

        self:UpdateConfig()

        for i,f in addon:Frames() do
            -- create on existing frames
            if not f.BossModIcon then
                self:Create(f)
            end
        end

        plugin_ct = addon:GetPlugin('CombatToggle')

        -- Register addon callbacks
        -- TODO conflict if both are enabled
        -- temporarily ignore one until both have settings
        -- DBM.Options.DontShowNameplateIcons
        if BigWigsLoader then
            RegisterAddon('BigWigs')
        end

        if DBM then
            RegisterAddon('DBM')
        end
    end
end
function mod:OnDisable()
    HideAllAuras()
end
function mod:Initialised()
    initialised = true

    if addon.layout.BossModIcon then
        -- re-enable to get config from layout table
        self:OnEnable()
    else
        -- layout didn't initialise us
        self:Disable()
    end
end
