-- Boss mod callback handlers
-- Please contact me on Curse or IRC (freenode, #wowace) if you want me to
-- add support for your messages.
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local ICON_SIZE, ICON_X_OFFSET, ICON_Y_OFFSET = 30,0,0
local CONTROL_FRIENDLY = true
local DECIMAL_THRESHOLD = 1

local initialised
local active_boss_auras, guid_was_used, any_auras_hidden
local GetNamePlateForUnit
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
local function GetFrameByName(name)
    -- wrapper for GetNamePlateForUnit, return kui frame
    local f = GetNamePlateForUnit(name)
    if f then
        return f.kui
    end
end
local function aura_OnUpdate(self,elapsed)
    self.cd_elap = (self.cd_elap or 0) - elapsed
    if self.cd_elap <= 0 then
        self.remaining = self.expiry - GetTime()

        if self.remaining <= 0 then
            self.cd:SetText(0)
            self:SetScript('OnUpdate',nil)
            return
        end

        if self.remaining <= DECIMAL_THRESHOLD+1 then
            self.cd_elap = .05
        else
            self.cd_elap = .5
        end

        if self.remaining <= DECIMAL_THRESHOLD then
            self.cd:SetText(format("%.1f",self.remaining))
        else
            self.cd:SetText(format("%.f",self.remaining))
        end
    end
end
local function ShowNameplateAura(f, icon_tbl)
    if not f or not icon_tbl or not f.BossModIcon then return end

    local texture,expiry = unpack(icon_tbl)
    if not texture then return end

    if expiry then
        f.BossModIcon.expiry = expiry
        f.BossModIcon:SetScript('OnUpdate',aura_OnUpdate)
        f.BossModIcon.cd:Show()
    end

    f.BossModIcon.tex:SetTexture(texture)
    f.BossModIcon:Show()
end
local function HideNameplateAura(f)
    if not f or not f.BossModIcon then return end

    f.BossModIcon:SetScript('OnUpdate',nil)
    f.BossModIcon:Hide()

    f.BossModIcon.cd_elap = nil
    f.BossModIcon.remaining = nil
    f.BossModIcon.expiry = nil
    f.BossModIcon.cd:Hide()
end
local function HideAllAuras()
    for k,f in addon:Frames() do
        if f:IsShown() then
            HideNameplateAura(f)
        end
    end

    if active_boss_auras then
        wipe(active_boss_auras)
    end

    any_auras_hidden = nil
    guid_was_used = nil
end
-- callbacks ###################################################################
do
    -- Show/hide friendly nameplates ###########################################
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    local prev_val
    local function DisableFriendlyNameplates()
        mod:UnregisterEvent('PLAYER_REGEN_ENABLED')

        SetCVar('nameplateShowFriends',prev_val)

        -- restore CombatToggle's desired out-of-combat settings
        plugin_ct:Enable()
        plugin_ct:PLAYER_REGEN_ENABLED()
    end
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

        if addon.debug then
            addon:print('received DisableFriendlyNameplates')
            if InCombatLockdown() then
                addon:print('during combat')
            end
        end

        if InCombatLockdown() then
            -- wait until after combat to reset display
            self:RegisterEvent('PLAYER_REGEN_ENABLED',DisableFriendlyNameplates)
        else
            DisableFriendlyNameplates()
        end

        -- immediately clear all auras
        HideAllAuras()
    end
end

do
    -- Show/hide icon on nameplate belonging to given name #####################
    -- Duration is used to draw a cooldown on the icon;
    --     If left nil, the icon is treated as timeless.
    -- The icon will not be hidden until HideNameplateAura is called.
    -- Name only works with friendly players in your party.
    -- GUID can be given instead of name, but this requies a table iteration.
    function mod:BigWigs_ShowNameplateAura(msg,sender,name,icon,duration)
        if not self.enabled or not name or not icon then return end

        -- store to show/hide when relevant frame's visibility changes
        if not active_boss_auras then
            active_boss_auras = {}
        end

        active_boss_auras[name] = {
            icon,
            duration and GetTime()+duration
        }

        -- immediately show if they already have a frame
        if msg == 'guid' then
            ShowNameplateAura(GetFrameByGUID(name),active_boss_auras[name])
            guid_was_used = true
        else
            ShowNameplateAura(
                GetFrameByName(name),
                active_boss_auras[name]
            )
        end
    end
    function mod:BigWigs_HideNameplateAura(msg,sender,name)
        if not self.enabled or not name then return end

        if active_boss_auras then
            -- remove from name list
            active_boss_auras[name] = nil
        end

        -- immediately hide
        if msg == 'guid' then
            HideNameplateAura(GetFrameByGUID(name))
        else
            HideNameplateAura(GetFrameByName(name))
        end
    end
end
-- messages ####################################################################
function mod:Show(f)
    if not active_boss_auras or not any_auras_hidden then return end

    local icon_tbl
    if guid_was_used then
        local guid = UnitGUID(f.unit)
        if not guid then return end

        icon_tbl = active_boss_auras[guid]
    else
        local name = GetUnitName(f.unit,true)
        if not name then return end

        icon_tbl = active_boss_auras[name]
    end

    if not icon_tbl then return end

    ShowNameplateAura(f,icon_tbl)
end
function mod:Hide(f)
    if f.BossModIcon and f.BossModIcon:IsShown() then
        HideNameplateAura(f)
        any_auras_hidden = true
    end
end
function mod:Create(f)
    local icon = CreateFrame('Frame',nil,f)
    icon:SetFrameLevel(0)
    icon:Hide()

    local tex = icon:CreateTexture(nil,'ARTWORK')
    tex:SetTexCoord(.1,.9,.1,.9)
    tex:SetAllPoints(icon)

    local cd = icon:CreateFontString(nil,'OVERLAY')
    cd:SetTextColor(1,1,0)
    cd:SetFont('Fonts\\FRIZQT__.TTF',18,'OUTLINE')
    cd:SetPoint('TOPLEFT',-4,4)
    cd:Hide()

    icon.tex = tex
    icon.cd = cd

    f.BossModIcon = icon

    self:UpdateIcon(f)

    mod:RunCallback('PostCreateaAura',icon)
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
        CONTROL_FRIENDLY = addon.layout.BossModIcon.control_friendly
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
                mod:BigWigs_ShowNameplateAura('guid',nil,...)
            end)
            DBM:RegisterCallback('BossMod_HideNameplateAura',function(msg,...)
                mod:BigWigs_HideNameplateAura('guid',nil,...)
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

        GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
        plugin_ct = addon:GetPlugin('CombatToggle')

        -- Register addon callbacks
        -- TODO conflict if both are enabled
        -- temporarily ignore one until both have settings
        -- DBM.Options.DontShowNameplateIcons
        if DBM then
            RegisterAddon('DBM')
        end

        if BigWigsLoader then
            RegisterAddon('BigWigs')
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
function mod:Initialise()
    self:RegisterCallback('PostCreateaAura')
end
