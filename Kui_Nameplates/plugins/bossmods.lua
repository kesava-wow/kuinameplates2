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
    _ShowNameplateAura(is_guid, unitname or unitguid, texture, duration, desaturate)
    -   Called throughout an encounter to inform the nameplate addon to show
        the given icon on the nameplate which matches the given name or guid.
    -   If guid is used, first argument should be true.
        However, once a guid is used instead of a name, subsequent calls using
        names will be ignored. Your addon should always use one or the other.
        Name is more efficient, but can only be used on friendly party members.
    -   Passing "duration" (number) will show a timer on the aura. Otherwise
        auras will be treated as timeless. When this duration expires, the aura
        will NOT be hidden. You must still call _HideNameplateAura.

    _HideNameplateAura(is_guid, name)
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

    TODO
    - update this ^ shit to reflect multiple icons.
    - larger font. obviously.
    - listen to aura calls from first addon to call _EnableFriendlyNameplates,
        ignore others.
    - bugginess when more than max icons are created.

]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods')

local ICON_SIZE, ICON_X_OFFSET, ICON_Y_OFFSET = 30,0,0
local CONTROL_FRIENDLY = true
local DECIMAL_THRESHOLD = 1
local CLICKTHROUGH = false

local initialised
local active_boss_auras, guid_was_used
local hidden_auras, num_hidden_auras
local GetNamePlateForUnit
local plugin_ct

-- callback registrars #########################################################
local RegisterAddon,UnregisterAddon,registered
do
    local function Wrapper_DBM_ShowAura(msg,unitType,...)
        unitType = (unitType == true or unitType == 'guid') and true or nil
        mod:BigWigs_ShowNameplateAura(unitType,...)
    end
    local function Wrapper_DBM_HideAura(msg,unitType,...)
        unitType = (unitType == true or unitType == 'guid') and true or nil
        mod:BigWigs_HideNameplateAura(unitType,...)
    end
    local function Wrapper_DBM_DisableFriendly()
        mod:BigWigs_DisableFriendlyNameplates()
    end

    local cb_registrar = {
        ['BigWigs'] = function(r)
            if not BigWigsLoader then return end
            if r then
                BigWigsLoader.RegisterMessage(mod,'BigWigs_ShowNameplateAura',function(msg,sender,...)
                    mod:BigWigs_ShowNameplateAura(nil,...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_HideNameplateAura',function(msg,sender,...)
                    mod:BigWigs_HideNameplateAura(nil,...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates')
            else
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_ShowNameplateAura')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_HideNameplateAura')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_DisableFriendlyNameplates')
            end
        end,
        ['DBM'] = function(r)
            if not DBM then return end
            if r then
                DBM:RegisterCallback('BossMod_ShowNameplateAura',Wrapper_DBM_ShowAura)
                DBM:RegisterCallback('BossMod_HideNameplateAura',Wrapper_DBM_HideAura)
                DBM:RegisterCallback('BossMod_DisableFriendlyNameplates',Wrapper_DBM_DisableFriendly)
            else
                DBM:UnregisterCallback('BossMod_ShowNameplateAura',Wrapper_DBM_ShowAura)
                DBM:UnregisterCallback('BossMod_HideNameplateAura',Wrapper_DBM_HideAura)
                DBM:UnregisterCallback('BossMod_DisableFriendlyNameplates',Wrapper_DBM_DisableFriendly)
            end
        end,
    }

    function RegisterAddon(name)
        if not name then return end
        if not registered and type(cb_registrar[name]) == 'function' then
            cb_registrar[name](true)
            registered = name
            addon:print('BossMods registered '..name)
        else
            addon:print('BossMods ignored registration for '..name)
        end
    end
    function UnregisterAddon()
        if registered and type(cb_registrar[registered]) == 'function' then
            cb_registrar[registered]()
            registered = nil
            addon:print('BossMods un-registered '..registered)
        end
    end
end
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
    elseif hidden_auras[name] then
        -- already tracking hidden aura on this frame
        return
    end

    addon:print(name..' was added to hidden_auras')

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
local function ShowNameplateAura(f, icon_tbl)
    if not f or not icon_tbl or not f.BossModAuraFrame then return end

    local texture,desaturate,expiration = unpack(icon_tbl)
    if not texture then return end

    local button = f.BossModAuraFrame:AddAura(nil,texture,nil,nil,expiration)
    if button then
        button.icon:SetDesaturated(desaturate)
    end

    -- there is an aura active on this frame
    f.BossModAuraFrame.is_active = true
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

    if not icon then
        f.BossModAuraFrame:HideAllButtons()
    else
        f.BossModAuraFrame:RemoveAura(nil,icon)
    end

    if not f.BossModAuraFrame:IsShown() then
        -- there are no auras on this frame
        f.BossModAuraFrame.is_active = nil
    end
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
-- show/hide friendly nameplates
do
    local prev_show_friends,disable_clickthrough
    local function DisableFriendlyNameplates()
        mod:UnregisterEvent('PLAYER_REGEN_ENABLED')

        SetCVar('nameplateShowFriends',prev_show_friends)

        -- restore CombatToggle's desired out-of-combat settings
        plugin_ct:Enable()
        plugin_ct:PLAYER_REGEN_ENABLED()

        if disable_clickthrough then
            -- reset clickthrough
            disable_clickthrough = nil
            C_NamePlate.SetNamePlateFriendlyClickThrough(false)
        end
    end
    function mod:BigWigs_EnableFriendlyNameplates(msg)
        if not self.enabled then return end
        if registered then
            addon:print('BossMods ignored duplicated Enable call ('..msg..')')
            return
        end

        if CONTROL_FRIENDLY then
            plugin_ct:Disable()

            if not InCombatLockdown() then
                -- skip CombatToggle into combat mode
                plugin_ct:PLAYER_REGEN_DISABLED()

                prev_show_friends = GetCVarBool('nameplateShowFriends')
                SetCVar('nameplateShowFriends',true)

                if  CLICKTHROUGH and
                    not prev_show_friends and
                    not C_NamePlate.GetNamePlateFriendlyClickThrough()
                then
                    -- enable clickthrough when automatically shown
                    disable_clickthrough = true
                    C_NamePlate.SetNamePlateFriendlyClickThrough(true)
                end
            end
        end

        -- register show/hide aura callbacks
        if msg == 'BigWigs_EnableFriendlyNameplates' then
            RegisterAddon('BigWigs')
        elseif msg == 'BossMod_EnableFriendlyNameplates' then
            RegisterAddon('DBM')
        end
    end
    function mod:BigWigs_DisableFriendlyNameplates(msg)
        if not self.enabled or not registered then return end

        if CONTROL_FRIENDLY then
            if InCombatLockdown() then
                -- wait until after combat to reset display
                self:RegisterEvent('PLAYER_REGEN_ENABLED',DisableFriendlyNameplates)
            else
                -- immediately reset
                DisableFriendlyNameplates()
            end
        end

        -- immediately clear all auras
        HideAllAuras()

        -- unregister callbacks
        UnregisterAddon()
    end
end
-- show/hide icon on nameplate belonging to given name
function mod:BigWigs_ShowNameplateAura(is_guid,name,icon,duration,desaturate)
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    if not self.enabled or not name or not icon then return end

    if guid_was_used and not is_guid then
        -- ignore non-guid calls once guid has been used
        addon:print('name was given but was expecting guid')
        return
    end

    if is_guid then
        guid_was_used = true
    end

    -- store to show/hide when relevant frame's visibility changes
    AddActiveAura(name, {
        icon,
        desaturate,
        duration and GetTime()+duration
    })

    -- immediately show new aura if frame is currently visible
    local f = guid_was_used and GetFrameByGUID(name) or GetFrameByName(name)
    if f then
        ShowNameplateAuras(f,active_boss_auras[name])
    else
        -- state an aura is hidden on this name
        AddToHiddenAuras(name)
    end
end
function mod:BigWigs_HideNameplateAura(is_guid,name,icon)
    if not self.enabled or not name then return end

    -- remove from name list
    RemoveActiveAura(name,icon)

    if  not active_boss_auras or
        not active_boss_auras[name] or
        #active_boss_auras[name] == 0
    then
        -- remove from hidden_auras if disabled while hidden and no more
        -- auras are present on this name
        RemoveFromHiddenAuras(name)
    end

    -- immediately hide
    if guid_was_used then
        HideNameplateAura(GetFrameByGUID(name),icon)
    else
        HideNameplateAura(GetFrameByName(name),icon)
    end
end
-- messages ####################################################################
function mod:Show(f)
    -- restore previously hidden auras, if any
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
    -- hide currently active auras, if any
    if f.BossModAuraFrame and f.BossModAuraFrame.is_active then
        HideNameplateAura(f)
        f.BossModAuraFrame.is_active = nil

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
        centred = true,
        point = {'BOTTOMLEFT','LEFT','RIGHT'}
    })
    f.BossModAuraFrame:Hide()
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
        CLICKTHROUGH = addon.layout.BossModIcon.clickthrough
    end

    for i,f in addon:Frames() do
        -- update aura frame on existing frames
        self:UpdateFrame(f)
    end
end
-- register ####################################################################
function mod:OnEnable()
    if not initialised then return end
    if BigWigsLoader or DBM then
        GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
        plugin_ct = addon:GetPlugin('CombatToggle')

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

        -- register addons' Enable callbacks
        if DBM then
            DBM:RegisterCallback('BossMod_EnableFriendlyNameplates',function(...)
                mod:BigWigs_EnableFriendlyNameplates(...)
            end)
        end
        if BigWigsLoader then
            BigWigsLoader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates')
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
