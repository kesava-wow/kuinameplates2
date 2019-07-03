-- luacheck:globals DBM BigWigsLoader
--[[
    Boss mod callback handlers

    Expected order of calls:

    At the beginning of an encounter:
    _Enable{Friendly,Hostile}Nameplates
    -   Used to tell the nameplate addon to keep friendly or hostile nameplates
        enabled during an encounter so that you can show icons on them.
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
    _Disable{Friendly,Hostile}Nameplates
    -   Tell the nameplate addon to restore friendly or hostile nameplate
        visibility to whatever it was before _Enable was called, and enable
        automatic handling such as combat toggling.
    -   Can be called during combat; the insutruction will be delayed until
        combat ends.
    -   Also immediately hides all auras.

    TODO
    - update docs to reflect multiple icons.
    - larger font. obviously. (support in auras)
    - bugginess when more than max icons are created.
]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BossMods',nil,nil,false)

-- XXX placeholders for l11n-compatibility
local L_SHOW_WARNING = '|cff9966ffKui Nameplates|r: %s just sent a message instructing Kui Nameplates to forcibly enable %s nameplates so that it can show you extra information on them during this encounter. You can disable this in /knp > boss mods.'
local L_FRIENDLY = 'friendly'
local L_HOSTILE = 'hostile'

local ICON_SIZE, ICON_X_OFFSET, ICON_Y_OFFSET = 30,0,0
local CONTROL_VISIBILITY = true
local CLICKTHROUGH = false

local plugin_ct,active_boss_auras
local hidden_auras,num_hidden_auras,enable_warned
local prev_show_enemies,prev_show_friends
local select = select

-- callback registrars #########################################################
local RegisterAddon,UnregisterAddon,registered
do
    local function Wrapper_DBM_ShowAura(_,unitType,...)
        unitType = (unitType == true or unitType == 'guid') and true or nil
        mod:BigWigs_ShowNameplateAura(unitType,...)
    end
    local function Wrapper_DBM_HideAura(_,unitType,...)
        unitType = (unitType == true or unitType == 'guid') and true or nil
        mod:BigWigs_HideNameplateAura(unitType,...)
    end
    local function Wrapper_DBM_DisableFriendly()
        mod:BigWigs_DisableFriendlyNameplates()
    end
    local function Wrapper_DBM_DisableHostile()
        mod:BigWigs_DisableHostileNameplates()
    end

    local cb_registrar = {
        ['BigWigs'] = function(r)
            if not BigWigsLoader then return end
            if r then
                BigWigsLoader.RegisterMessage(mod,'BigWigs_ShowNameplateAura',function(_,_,...)
                    mod:BigWigs_ShowNameplateAura(select(5,...),...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_HideNameplateAura',function(_,_,...)
                    mod:BigWigs_HideNameplateAura(select(3,...),...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_AddNameplateIcon',function(_,_,...)
                    mod:BigWigs_ShowNameplateAura(true,...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_RemoveNameplateIcon',function(_,_,...)
                    mod:BigWigs_HideNameplateAura(true,...)
                end)
                BigWigsLoader.RegisterMessage(mod,'BigWigs_DisableFriendlyNameplates')
                BigWigsLoader.RegisterMessage(mod,'BigWigs_DisableHostileNameplates')
            else
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_ShowNameplateAura')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_HideNameplateAura')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_AddNameplateIcon')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_RemoveNameplateIcon')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_DisableFriendlyNameplates')
                BigWigsLoader.UnregisterMessage(mod,'BigWigs_DisableHostileNameplates')
            end
        end,
        ['DBM'] = function(r)
            if not DBM then return end
            if r then
                DBM:RegisterCallback('BossMod_ShowNameplateAura',Wrapper_DBM_ShowAura)
                DBM:RegisterCallback('BossMod_HideNameplateAura',Wrapper_DBM_HideAura)
                DBM:RegisterCallback('BossMod_DisableFriendlyNameplates',Wrapper_DBM_DisableFriendly)
                DBM:RegisterCallback('BossMod_DisableHostileNameplates',Wrapper_DBM_DisableHostile)
            else
                DBM:UnregisterCallback('BossMod_ShowNameplateAura',Wrapper_DBM_ShowAura)
                DBM:UnregisterCallback('BossMod_HideNameplateAura',Wrapper_DBM_HideAura)
                DBM:UnregisterCallback('BossMod_DisableFriendlyNameplates',Wrapper_DBM_DisableFriendly)
                DBM:UnregisterCallback('BossMod_DisableHostileNameplates',Wrapper_DBM_DisableHostile)
            end
        end,
    }

    function RegisterAddon(name,hostile)
        if not name then return end
        if not registered and type(cb_registrar[name]) == 'function' then
            cb_registrar[name](true)
            registered = name
            addon:print('BossMods registered '..name)

            if CONTROL_VISIBILITY and not enable_warned then
                if (hostile and not prev_show_enemies) or
                   (not hostile and not prev_show_friends)
                then
                    print(string.format(
                        L_SHOW_WARNING,
                        name,(hostile and L_HOSTILE or L_FRIENDLY)
                    ))
                    enable_warned = true
                end
            end
        else
            addon:print('BossMods ignored registration for '..name)
        end
    end
    function UnregisterAddon()
        if registered and type(cb_registrar[registered]) == 'function' then
            cb_registrar[registered]()
            addon:print('BossMods un-registered '..registered)
            registered = nil
        end
    end
end
-- local functions #############################################################
local function GetFrameByGUID(guid)
    -- TODO store guids => frames OnShow/Hide
    for _,f in addon:Frames() do
        if f:IsShown() and UnitGUID(f.unit) == guid then
            return f
        end
    end
end
local function GetFrameByName(name)
    -- syntactic wrapper for GetActiveNameplateForUnit
    return addon:GetActiveNameplateForUnit(name)
end
local function AddToHiddenAuras(guid)
    -- maintain a list of auras which are currently off-screen for efficiency
    if not hidden_auras then
        hidden_auras = {}
        num_hidden_auras = nil
    elseif hidden_auras[guid] then
        -- already tracking hidden aura on this frame
        return
    end

    addon:print(guid..' was added to hidden_auras')

    hidden_auras[guid] = true

    if num_hidden_auras then
        num_hidden_auras = num_hidden_auras + 1
    else
        num_hidden_auras = 1
    end
end
local function RemoveFromHiddenAuras(guid)
    if not hidden_auras or not hidden_auras[guid] then return end
    hidden_auras[guid] = nil

    if num_hidden_auras then
        num_hidden_auras = num_hidden_auras - 1

        if num_hidden_auras <= 0 then
            num_hidden_auras = nil
        end
    end
end
local function AddActiveAura(guid,icon_tbl)
    if not active_boss_auras then
        active_boss_auras = {}
    end

    if not active_boss_auras[guid] then
        active_boss_auras[guid] = {}
    end

    if #active_boss_auras[guid] > 0 then
        -- need to check for overwrite
        for i,this_tbl in pairs(active_boss_auras[guid]) do
            if this_tbl[1] == icon_tbl[1] then
                -- this is an overwrite
                active_boss_auras[guid][i] = icon_tbl
                return
            end
        end
    end

    -- this is a new icon
    tinsert(active_boss_auras[guid], icon_tbl)

    if addon.debug then
        kui.print(active_boss_auras)
    end
end
local function RemoveActiveAura(guid,icon)
    if not active_boss_auras then return end
    if not active_boss_auras[guid] then return end

    if icon then
        -- remove specific icon
        if #active_boss_auras[guid] == 0 then return end

        for i,this_tbl in pairs(active_boss_auras[guid]) do
            if this_tbl[1] == icon then
                tremove(active_boss_auras[guid],i)
                return
            end
        end
    else
        -- remove any
        active_boss_auras[guid] = nil
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

    for _,icon_tbl in ipairs(auras_tbl) do
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
        f.BossModAuraFrame.unit_type = nil
    end
end
local function HideAllAuras()
    for _,f in addon:Frames() do
        if f:IsShown() then
            HideNameplateAura(f)
        end
    end

    active_boss_auras = nil
    hidden_auras = nil
    num_hidden_auras = nil
end
-- callbacks ###################################################################
-- show/hide friendly nameplates
do
    local disable_enemy_clickthrough,disable_friendly_clickthrough,
          enabled_hostile,enabled_friendly,
          registered_hostile,registered_friendly

    -- helpers:
    local function DisableNameplates()
        mod:UnregisterEvent('PLAYER_REGEN_ENABLED')

        -- reset visibility
        if enabled_hostile then
            SetCVar('nameplateShowEnemies',prev_show_enemies)
            enabled_hostile = nil
        end
        if enabled_friendly then
            SetCVar('nameplateShowFriends',prev_show_friends)
            enabled_friendly = nil
        end

        -- restore CombatToggle's desired out-of-combat settings
        plugin_ct:Enable()
        plugin_ct:PLAYER_REGEN_ENABLED()

        -- reset clickthrough
        if disable_enemy_clickthrough then
            C_NamePlate.SetNamePlateEnemyClickThrough(false)
            disable_enemy_clickthrough = nil
        end
        if disable_friendly_clickthrough then
            C_NamePlate.SetNamePlateFriendlyClickThrough(false)
            disable_friendly_clickthrough = nil
        end
    end

    -- callback wrappers:
    local function Callback_EnableNameplates(sender,hostile)
        if not mod.enabled then return end

        if registered and sender ~= registered then
            addon:print('BossMods ignored Enable call from '..sender..' (expecting '..registered')')
            return
        end

        if  (hostile and registered_hostile) or
            (not hostile and registered_friendly)
        then
            addon:print('BossMods ignored duplicated Enable call from '..sender)
            return
        end

        if hostile then
            registered_hostile = true
        else
            registered_friendly = true
        end

        addon:print('BossMods received Enable from '..sender..(hostile and ', hostile' or ''))

        if CONTROL_VISIBILITY then
            plugin_ct:Disable()

            if hostile and not enabled_hostile then
                prev_show_enemies = GetCVarBool('nameplateShowEnemies')
                enabled_hostile = true
            elseif not hostile and not enabled_friendly then
                prev_show_friends = GetCVarBool('nameplateShowFriends')
                enabled_friendly = true
            end

            if not InCombatLockdown() then
                -- skip CombatToggle into combat mode
                plugin_ct:PLAYER_REGEN_DISABLED()

                if hostile then
                    SetCVar('nameplateShowEnemies',true)
                else
                    SetCVar('nameplateShowFriends',true)
                end

                if CLICKTHROUGH then
                    if hostile then
                        if  not prev_show_enemies and
                            not C_NamePlate.GetNamePlateEnemyClickThrough()
                        then
                            disable_enemy_clickthrough = true
                            C_NamePlate.SetNamePlateEnemyClickThrough(true)
                        end
                    else
                        if  not prev_show_friends and
                            not C_NamePlate.GetNamePlateFriendlyClickThrough()
                        then
                            disable_friendly_clickthrough = true
                            C_NamePlate.SetNamePlateFriendlyClickThrough(true)
                        end
                    end
                end
            end
        end

        RegisterAddon(sender,hostile)
    end
    local function Callback_DisableNameplates()
        if not mod.enabled or not registered then return end

        if CONTROL_VISIBILITY then
            if InCombatLockdown() then
                -- wait until after combat to reset display
                mod:RegisterEvent('PLAYER_REGEN_ENABLED',DisableNameplates)
            else
                -- immediately reset
                DisableNameplates()
            end
        end

        -- doesn't mmake sense to only disable friendly or hostile since we
        -- can't do it in combat anyway:
        registered_hostile = nil
        registered_friendly = nil

        -- immediately clear all auras
        HideAllAuras()

        -- unregister callbacks
        UnregisterAddon()
    end

    -- callback handlers:
    function mod:BigWigs_EnableFriendlyNameplates(msg)
        if msg == 'BigWigs_EnableFriendlyNameplates' then
            Callback_EnableNameplates('BigWigs')
        elseif msg == 'BossMod_EnableFriendlyNameplates' then
            Callback_EnableNameplates('DBM')
        end
    end
    function mod:BigWigs_EnableHostileNameplates(msg)
        if msg == 'BigWigs_EnableHostileNameplates' then
            Callback_EnableNameplates('BigWigs',true)
        elseif msg == 'BossMod_EnableHostileNameplates' then
            Callback_EnableNameplates('DBM',true)
        end
    end
    function mod:BigWigs_DisableFriendlyNameplates()
        Callback_DisableNameplates()
    end
    function mod:BigWigs_DisableHostileNameplates()
        Callback_DisableNameplates()
    end
end
-- show/hide icon on nameplate belonging to given name
function mod:BigWigs_ShowNameplateAura(is_guid,name,icon,duration,desaturate)
    -- these should not be called during combat
    -- DisableFriendlyNameplates also wipes boss auras
    if not self.enabled or not name or not icon then return end

    local guid = is_guid and name or UnitGUID(name)
    if not guid then
        addon:print('bossmods show discarded unmatched name: '..name)
        return
    end

    -- store to show/hide when relevant frame's visibility changes
    AddActiveAura(guid, {
        icon,
        desaturate,
        duration and GetTime()+duration,
    })

    -- immediately show new aura if frame is currently visible
    local f = is_guid and GetFrameByGUID(name) or GetFrameByName(name)
    if f then
        ShowNameplateAuras(f,active_boss_auras[guid])
    else
        -- state an aura is hidden on this name
        AddToHiddenAuras(guid)
    end
end
function mod:BigWigs_HideNameplateAura(is_guid,name,icon)
    if not self.enabled or not name then return end

    local guid = is_guid and name or UnitGUID(name)
    if not guid then
        addon:print('bossmods hide discarded unmatched name: '..name)
        return
    end

    -- remove from name list
    RemoveActiveAura(guid,icon)

    if  not active_boss_auras or
        not active_boss_auras[guid] or
        #active_boss_auras[guid] == 0
    then
        -- remove from hidden_auras if disabled while hidden and no more
        -- auras are present with this guid
        RemoveFromHiddenAuras(guid)
    end

    -- immediately hide
    if is_guid then
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

    local guid = UnitGUID(f.unit)
    if hidden_auras[guid] then
        RemoveFromHiddenAuras(guid)
        ShowNameplateAuras(f,active_boss_auras[guid])
    end
end
function mod:Hide(f)
    -- hide currently active auras, if any
    if f.BossModAuraFrame and f.BossModAuraFrame.is_active then
        AddToHiddenAuras(UnitGUID(f.unit))
        HideNameplateAura(f)
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
    f.BossModAuraFrame:SetPoint('BOTTOM',f,'TOP',ICON_X_OFFSET,ICON_Y_OFFSET)
end
function mod:UpdateConfig()
    if not self.enabled then return end

    if type(addon.layout.BossModIcon) == 'table' then
        ICON_SIZE = addon.layout.BossModIcon.icon_size or ICON_SIZE
        ICON_X_OFFSET = addon.layout.BossModIcon.icon_x_offset or ICON_X_OFFSET
        ICON_Y_OFFSET = addon.layout.BossModIcon.icon_y_offset or ICON_Y_OFFSET
        CONTROL_VISIBILITY = addon.layout.BossModIcon.control_visibility
        CLICKTHROUGH = addon.layout.BossModIcon.clickthrough
    end

    for _,f in addon:Frames() do
        -- update aura frame on existing frames
        self:UpdateFrame(f)
    end
end
-- register ####################################################################
function mod:OnEnable()
    if BigWigsLoader or DBM then
        plugin_ct = addon:GetPlugin('CombatToggle')

        self:RegisterMessage('Show')
        self:RegisterMessage('Hide')
        self:RegisterMessage('Create')

        for _,f in addon:Frames() do
            -- create on existing frames
            if not f.BossModAuraFrame then
                self:Create(f)
            end
        end

        -- register addons' Enable callbacks
        if DBM and DBM.RegisterCallback then
            DBM:RegisterCallback('BossMod_EnableFriendlyNameplates',function(...)
                mod:BigWigs_EnableFriendlyNameplates(...)
            end)
            DBM:RegisterCallback('BossMod_EnableHostileNameplates',function(...)
                mod:BigWigs_EnableHostileNameplates(...)
            end)
        end
        if BigWigsLoader then
            BigWigsLoader.RegisterMessage(mod,'BigWigs_EnableFriendlyNameplates')
            BigWigsLoader.RegisterMessage(mod,'BigWigs_EnableHostileNameplates')
        end
    end
end
function mod:OnDisable()
    HideAllAuras()
end
function mod:Initialised()
    self:UpdateConfig()
end
