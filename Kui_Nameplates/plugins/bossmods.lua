--[[
    Boss mod callback handlers
    Please contact me on Curse or IRC (freenode, #wowace) if you want me to
    add support for your messages.

    Expected order of calls:

    At the beginning of an encounter:
    _EnableFriendlyNameplates
    -   Used to tell the nameplate addon to keep friendly nameplates enabled
        during an encounter so that you can show icons on them.
    -   Should be fired out of the combat lockdown at the beginning of a fight.

    During an encounter:
    _ShowNameplateAura(is_guid, nil, unitname or unitguid, texture, duration, desaturate)
    -   Called throughout an encounter to inform the nameplate addon to show
        the given icon on the nameplate which matches the given name or guid.
    -   If guid is used, first argument should be the string "guid".
        However, once a guid is used instead of a name, subsequent calls using
        names will be ignored. Your addon should always use one or the other.
        Name is more efficient, but can only be used on friendly party members.
    -   Passing "duration" (number) will show a timer on the aura. Otherwise
        auras will be treated as timeless. When this duration expires, the aura
        will NOT be hidden. You must still call _HideNameplateAura.

    _HideNameplateAura(is_guid, nil, name)
    -   Hide the currently active icon on the nameplate matching the given name
        or guid, if there is one.

    At the end of an encounter:
    _DisableFriendlyNameplates
    -   Tell the nameplate addon to restore friendly nameplate visibility to
        whatever it was before _EnableFriendlyNameplates was called, and enable
        automatic handling such as combat toggling.
    -   Can be called during combat; the insutruction will be delayed until
        combat ends.
    -   Also immediately hides all auras.

]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local ICON_SIZE, ICON_X_OFFSET, ICON_Y_OFFSET = 30,0,0
local CONTROL_FRIENDLY = true
local DECIMAL_THRESHOLD = 1

local initialised
local active_boss_auras, guid_was_used
local hidden_auras, num_hidden_auras
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
local function AddToHiddenAuras(name)
    -- maintain a list of auras which are currently off-screen for efficiency
    if not hidden_auras then
        hidden_auras = {}
        num_hidden_auras = nil
    end

    hidden_auras[name] = true

    if num_hidden_auras then
        num_hidden_auras = num_hidden_auras + 1
    else
        num_hidden_auras = 1
    end
end
local function RemoveFromHiddenAuras(name)
    if not hidden_auras or not hidden_auras[name] then return end
    hidden_auras[name] = nil

    if num_hidden_auras then
        num_hidden_auras = num_hidden_auras - 1

        if num_hidden_auras <= 0 then
            num_hidden_auras = nil
        end
    end
end
local function AddActiveAura(name,icon_tbl)
    if not active_boss_auras then
        active_boss_auras = {}
    end

    if not active_boss_auras[name] then
        active_boss_auras[name] = {}
    end

    if #active_boss_auras[name] > 0 then
        -- need to check for overwrite
        for i,this_tbl in pairs(active_boss_auras[name]) do
            if this_tbl[1] == icon_tbl[1] then
                -- this is an overwrite
                active_boss_auras[name][i] = icon_tbl
                return
            end
        end
    end

    -- this is a new icon
    tinsert(active_boss_auras[name], icon_tbl)

    if addon.debug then
        kui.print(active_boss_auras)
    end
end
local function RemoveActiveAura(name,icon)
    if not active_boss_auras then return end
    if not active_boss_auras[name] then return end

    if icon then
        -- remove specific icon
        if #active_boss_auras[name] == 0 then return end

        for i,this_tbl in pairs(active_boss_auras[name]) do
            if this_tbl[1] == icon then
                tremove(active_boss_auras[name],i)
                return
            end
        end
    else
        -- remove any
        active_boss_auras[name] = nil
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
    if not f or not icon_tbl or not f.BossModAuraFrame then return end

    local texture,desaturate,expiry = unpack(icon_tbl)
    if not texture then return end

    -- TODO desaturate
    f.BossModAuraFrame:AddAura(nil,texture,nil,expiry)
end
local function ShowNameplateAuras(f, auras_tbl)
    if not f or not auras_tbl or not f.BossModAuraFrame then return end
    if #auras_tbl == 0 then return end

    for i,icon_tbl in ipairs(auras_tbl) do
        ShowNameplateAura(f,icon_tbl)
    end
end
local function HideNameplateAura(f,icon)
    if not f or not f.BossModAuraFrame then return end
    f.BossModAuraFrame:HideAllButtons()
end
local function HideAllAuras()
    for k,f in addon:Frames() do
        if f:IsShown() then
            HideNameplateAura(f)
        end
    end

    active_boss_auras = nil
    guid_was_used = nil
    hidden_auras = nil
    num_hidden_auras = nil
end
-- callbacks ###################################################################
do
    -- Show/hide friendly nameplates ###########################################
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    local prev_val,enable_was_called
    local function DisableFriendlyNameplates()
        mod:UnregisterEvent('PLAYER_REGEN_ENABLED')

        SetCVar('nameplateShowFriends',prev_val)

        -- restore CombatToggle's desired out-of-combat settings
        plugin_ct:Enable()
        plugin_ct:PLAYER_REGEN_ENABLED()
    end
    function mod:BigWigs_EnableFriendlyNameplates()
        if not self.enabled or not CONTROL_FRIENDLY then return end
        enable_was_called = true

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

        if enable_was_called then
            if InCombatLockdown() then
                -- wait until after combat to reset display
                self:RegisterEvent('PLAYER_REGEN_ENABLED',DisableFriendlyNameplates)
            else
                DisableFriendlyNameplates()
            end

            enable_was_called = nil
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
    function mod:BigWigs_ShowNameplateAura(msg,sender,name,icon,duration,desaturate)
        if not self.enabled or not name or not icon then return end

        if guid_was_used and msg ~= 'guid' then
            -- ignore non-guid calls once guid has been used
            addon:print('name was given but was expecting guid')
            return
        end

        -- store to show/hide when relevant frame's visibility changes
        AddActiveAura(name, {
            icon,
            desaturate,
            duration and GetTime()+duration
        })

        -- immediately show if they already have a frame
        local f
        if msg == 'guid' then
            f = GetFrameByGUID(name)
            guid_was_used = true
        else
            f = GetFrameByName(name)
        end

        if f then
            ShowNameplateAuras(f,active_boss_auras[name])
        else
            -- state an aura is hidden on this name
            AddToHiddenAuras(name)
        end
    end
    function mod:BigWigs_HideNameplateAura(msg,sender,name,icon)
        if not self.enabled or not name then return end

        -- remove from name list
        RemoveActiveAura(name,icon)

        -- remove from hidden_auras if disabled while hidden
        RemoveFromHiddenAuras(name)

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
    if not active_boss_auras or not num_hidden_auras then return end

    addon:print('BossMods parsed OnShow ('..num_hidden_auras..' hidden)')

    if guid_was_used then
        local guid = UnitGUID(f.unit)

        RemoveFromHiddenAuras(guid)
        ShowNameplateAuras(f,active_boss_auras[guid])
    else
        if not UnitIsPlayer(f.unit) then return end

        local name = GetUnitName(f.unit,true)

        RemoveFromHiddenAuras(name)
        ShowNameplateAuras(f,active_boss_auras[name])
    end
end
function mod:Hide(f)
    if  f.BossModAuraFrame and
        f.BossModAuraFrame.visible and
        f.BossModAuraFrame.visible > 0
    then
        HideNameplateAura(f)

        if guid_was_used then
            AddToHiddenAuras(UnitGUID(f.unit))
        else
            AddToHiddenAuras(GetUnitName(f.unit,true))
        end
    end
end
function mod:Create(f)
    f.BossModAuraFrame = f.handler:CreateAuraFrame({
        id = 'bossmods_external',
        size = ICON_SIZE,
        max = 3,
        rows = 1,
        x_spacing = 1,
        squareness = 1,
        pulsate = false,
        external = true,
        point = {'BOTTOMLEFT','LEFT','RIGHT'}
    })
    self:UpdateFrame(f)
end
-- mod functions ###############################################################
function mod:UpdateFrame(f)
    -- set size, position based on config
    if not f.BossModAuraFrame then return end

    local width = (ICON_SIZE * 3) + (1 * 2)
    f.BossModAuraFrame:SetSize(width,1)
    f.BossModAuraFrame:SetIconSize(ICON_SIZE)
    f.BossModAuraFrame:SetPoint('BOTTOMLEFT', f, 'TOPLEFT',
        floor((f:GetWidth() / 2) - (width / 2)) + ICON_X_OFFSET,
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
        -- update aura frame on existing frames
        self:UpdateFrame(f)
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
            if not f.BossModAuraFrame then
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
end
