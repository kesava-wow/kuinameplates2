-- luacheck:globals SLASH_KUINAMEPLATESCORE1 SLASH_KUINAMEPLATESCORE2
-- luacheck:globals KuiNameplatesCoreSaved
--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local folder = ...
local kui = LibStub('Kui-1.0')
local knp = KuiNameplates
local core = KuiNameplatesCore --luacheck:globals KuiNameplatesCore
local config -- set when layout is loaded

-- reuse category container created by core:Initialise
local opt = KuiNameplatesCoreConfig --luacheck:globals KuiNameplatesCoreConfig
assert(opt)
opt.pages = {}

-- slash command ###############################################################
SLASH_KUINAMEPLATESCORE1 = '/knp'
SLASH_KUINAMEPLATESCORE2 = '/kuinameplates'

local colours = {
    '|cffffffff','|cffcccccc','|cffffff88','|cff88ff88'
}
local function C(colour_id)
    return colours[colour_id]
end
local function C_command(command,option)
    return C(3)..'/knp '..(
           (command and
           ((option and command..' '..C(4)..option..'|r') or command)) or
           (option and C(4)..option..'|r' or '')
           )..'|r'
end

-- command index (purely for ordering help output)
local commands = {
    'help',
    'config',
    'get',
    'set',
    'find',
    'dump',
    'export',
    'import',
    'locale',
    'profile',
    'debug',
}
-- XXX generate doc text (locale, delayed? etc)
local command_doc = {
    ['help'] = format('This message. Use  %s  for more.',
        C_command('help','command')),
    ['debug'] = 'Toggle debug output (spams your chat frame)',
    ['dump'] = 'Output debug information - give this to me if you\'re reporting a problem!',
    ['config'] = {
        'Open configuration interface, optionally to a named page',
        format('%sUsage|r  %s',
            C(2),C_command('config','page')),
        'Enter the name of a page, full or partial, to open it',
        'This command is run by default if no other is matched',
        format('%sExample|r  %s  Opens the auras page',
            C(2),C_command(nil,'aur')),
    },
    ['profile'] = {
        'Switch to named profile',
        format('%sUsage|r  %s',
            C(2),C_command('profile','! profile name')),
        format('%sExample|r  %s  Switch to profile %s if it exists',
            C(2),C_command('profile','mine'),'mine'),
        format('%sExample|r  %s  Switch to profile %s, creating it if it does not exist',
            C(2),C_command('profile','! new'),'new'),
    },
    ['get'] = {
        'Show current value of configuration key',
        format('%sUsage|r  %s',
            C(2),C_command('get','key')),
        format('Use  %s  to search available configuration keys',
            C_command('find')),
    },
    ['set'] = {
        'Set configuration key to value',
        format('%sUsage|r  %s',
            C(2),C_command('set','key value')),
        format('Enter  %s  as  %s  to reset the key to default',
            'nil','value'),
        format('Use  %s  to search available configuration keys',
            C_command('find')),
        format('%sSupported values|r  bool  %s%s|r  colour  %s%s|r  number  text',
            C(2),C(2),'true/false',C(2),'r,g,b,a (0-1)'),
        format('%sExample|r  %s',
            C(2),C_command('set','frame_width 132')),
        format('%sExample|r  %s',
            C(2),C_command('set','target_glow_colour .8,.25,1,.8')),
    },
    ['find'] = {
        'Search available configuration keys',
        format('%sUsage|r  %s',
            C(2),C_command('find','search text')),
        format('%sExample|r  %s',
            C(2),C_command('find','cvar always show')),
    },
    ['locale'] = {
        'Switch KNP\'s config language',
        format('%sUsage|r  %s',
            C(2),C_command('locale','new locale')),
        format('Enter  %s  as  %s  to reset to WoW\'s default',
            'nil','new locale'),
    },
    ['export'] = 'Export the current profile as a string',
    ['import'] = 'Import a profile created with the export command',
}
local command_func = {}
function command_func.help(command,...)
    if not command then
        knp:ui_print('Available commands')
        for _,command_name in ipairs(commands) do
            local doc = command_doc[command_name]
            if type(doc) == 'table' then doc = doc[1] end
            if type(doc) == 'string' then
                print(format('    %s%s|r   %s',C(3),command_name,doc))
            end
        end
    else
        local args = table.concat({command,...},' ')
        local doc = command_doc[args]
        if type(doc) == 'string' then
            knp:ui_print(doc)
        elseif type(doc) == 'table' then
            for i,line in ipairs(doc) do
                if i == 1 then
                    knp:ui_print(line)
                else
                    print('    '..line)
                end
            end
        else
            knp:ui_print('No help for '..args)
        end
    end
end
function command_func.config(...)
    -- interpret msg as config page shortcut
    local L = opt:GetLocale()
    local msg = table.concat({...},' ')

    -- remove arrow from, e.g. "/knp > general"
    msg = string.gsub(msg,'^[^%S]*>[^%S]*','')

    local found
    for i,f in ipairs(opt.pages) do
        if f.name then
            local name = f.name
            local locale = L.page_names[name] and
                           strlower(L.page_names[name])

            if msg == name or msg == locale then
                -- exact match
                found = i
                break
            elseif not found and
                (name:match('^'..msg) or locale:match('^'..msg))
            then
                -- starts-with match, continue searching for exact matches
                found = i
            end
        end
    end

    if found then
        opt:ShowPage(found)
    end

    InterfaceOptionsFrame_OpenToCategory(opt.name)
    InterfaceOptionsFrame_OpenToCategory(opt.name)
end
function command_func.debug(arg,...)
    -- luacheck:globals KuiNameplatesPlayerAnchor
    if arg == 'all' then
        -- enable spam mode; clear all ignores
        knp.debug = true
        knp.debug_messages = true
        knp.debug_events = true
        knp.debug_callbacks = true
        if type(knp.DEBUG_IGNORE) == 'table' then
            wipe(knp.DEBUG_IGNORE)
        end
    elseif arg == 'ignore' then
        local to_ignore = ...
        knp.DEBUG_IGNORE = knp.DEBUG_IGNORE or {}
        knp.DEBUG_IGNORE[to_ignore] = not knp.DEBUG_IGNORE[to_ignore]
    elseif arg == 'frames' then
        -- toggle frame visibility
        knp.draw_frames = not knp.draw_frames
        if knp.draw_frames then
            if not KuiNameplatesPlayerAnchor.SetBackdrop then
                Mixin(KuiNameplatesPlayerAnchor,BackdropTemplateMixin)
            end
            KuiNameplatesPlayerAnchor:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
            KuiNameplatesPlayerAnchor:SetBackdropBorderColor(0,0,1)
            for _,f in knp:Frames() do
                if not f.SetBackdrop then
                    Mixin(f,BackdropTemplateMixin)
                end
                f:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
                f:SetBackdropBorderColor(1,1,1)
                if not f.parent.SetBackdrop then
                    Mixin(f.parent,BackdropTemplateMixin)
                end
                f.parent:SetBackdrop({bgFile=kui.m.t.solid})
                f.parent:SetBackdropColor(0,0,0)
            end
        else
            KuiNameplatesPlayerAnchor:SetBackdrop(nil)
            for _,f in knp:Frames() do
                f:SetBackdrop(nil)
                f.parent:SetBackdrop(nil)
            end
        end
    else
        -- debug toggle
        knp.debug = true
        knp.debug_messages = not knp.debug_messages
        knp.debug_events = knp.debug_messages
        knp.debug_callbacks = knp.debug_messages
    end
end
function command_func.trace(command,...)
    --@debug@
    local script_profile = GetCVarBool('scriptProfile')
    local args = table.concat({...},' ')
    if command == 'p' then
        knp:PrintTrace(tonumber(args))
    elseif command == 't' then
        if script_profile then
            if InCombatLockdown() then return end
            SetCVar('scriptProfile',false)
            ReloadUI()
        else
            if InCombatLockdown() then return end
            SetCVar('scriptProfile',true)
            ReloadUI()
        end
    elseif script_profile then
        knp.profiling = not knp.profiling
        knp:print('Profiling '..(knp.profiling and 'started' or 'stopped'))
    end
    --@end-debug@
    return
end
function command_func.dump()
    local d = kui:DebugPopup()
    local debug = knp.debug and '+debug' or ''
    local custom = IsAddOnLoaded('Kui_Nameplates_Custom') and '+c' or ''
    local barauras = IsAddOnLoaded('Kui_Nameplates_BarAuras') and '+ba' or ''
    local extras = IsAddOnLoaded('Kui_Nameplates_Extras') and '+x' or ''
    local locale = KuiNameplatesCoreSaved.LOCALE or GetLocale()
    local class = select(2,UnitClass('player'))

    local plugins_str
    for _,plugin_tbl in ipairs(knp.plugins) do
        if plugin_tbl.name then
            local this_str
            if plugin_tbl.enabled then
                this_str = plugin_tbl.name
            else
                this_str = format('[%s]',plugin_tbl.name)
            end
            plugins_str = plugins_str and plugins_str..', '..this_str or this_str
        end
    end

    d:AddText(format('%s %d.%d%s%s%s%s',
        '@project-version@',knp.MAJOR,knp.MINOR,
        debug,custom,barauras,extras))
    d:AddText(format('%s %s',locale,class))

    d:AddText(config.csv)
    d:AddText(config:GetActiveProfile())
    d:AddText(plugins_str)

    d:Show()
    d:HighlightText()
end
function command_func.profile(allow_create,...)
    local create,profile_name
    if allow_create == '!' then
        create = true
        profile_name = table.concat({...},' ')
    else
        profile_name = table.concat({allow_create,...},' ')
    end
    if not profile_name or profile_name == '' then
        return false
    end

    if config.gsv.profiles[profile_name] or create then
        config:SetProfile(profile_name)
        knp:ui_print(format('Switched to profile `%s`',profile_name))
    else
        knp:ui_print(format('No profile with name `%s`',profile_name))
    end
end
function command_func.get(key)
    if not key then return false end
    local v = core.profile[key]
    local out
    if type(v) == 'table' then
        out = kui.table_to_string(v)
    elseif type(v) == 'number' then
        out = tonumber(string.format('%.3f',v))
    elseif type(v) == 'string' or tostring(v) then
        out = tostring(v)
    else
        out = '('..type(v)..')'
    end
    knp:ui_print(key..' = '..out)
end
function command_func.set(key,value)
    if not key then return false end

    local extant_v = opt.profile[key]
    if type(extant_v) == 'nil' then
        knp:ui_print(format('Invalid config key `%s`',key))
        return
    end

    if value == 'nil' then
        -- reset the key
        value = nil
    else
        if strlower(value) == 'true' then
            value = true
        elseif strlower(value) == 'false' then
            value = false
        elseif tonumber(value) then
            value = tonumber(value)
        else
            -- string; find colour tables
            local r,g,b,a = strmatch(value,'^([^,]-),([^,]-),([^,]-)$')
            if not r then
                r,g,b,a = strmatch(value,'^([^,]-),([^,]-),([^,]-),([^,]-)$')
            end

            r,g,b,a = tonumber(r),tonumber(g),tonumber(b),tonumber(a)
            if r and g and b then
                value = { r, g, b }
                if a then
                    tinsert(value,a)
                end
            end
        end

        if type(extant_v) ~= type(value) then
            knp:ui_print(format('Invalid value for key (expected %s, got %s)',
                type(extant_v),type(value)))
            return
        end
        if type(value) == 'table' and #value ~= #extant_v then
            knp:ui_print(format('Invalid table length (expected %d, got %d)',
                #extant_v,#value))
            return
        end
    end

    config:SetKey(key,value)
end
do
    local L_NO_TITLE = C(2)..'(no description)' -- XXX locale
    local PRINT_KEYS,PRINT_TITLES = 15,10
    local key_index

    function command_func.find(...)
        -- list config keys
        local fuzzy_match_ix = {}

        if not key_index then
            -- initialise config key index
            key_index = {}
            for key in pairs(opt.profile) do
                tinsert(key_index,key)
            end
            table.sort(key_index)
        end

        for _,key in ipairs(key_index) do
            -- search for input in config keys
            local matches_all = true
            for _,search in pairs({...}) do
                if not key:match(strlower(search)) then
                    matches_all = false
                    break
                end
            end
            if matches_all then
                tinsert(fuzzy_match_ix,key)
            end
        end

        -- generate output
        if not fuzzy_match_ix or #fuzzy_match_ix == 0 then
            knp:ui_print('No matches')
        else
            knp:ui_print('Matches found')
            if #fuzzy_match_ix <= PRINT_TITLES then
                -- show multiple matches with config titles
                local L = opt:GetLocale()
                for _,key in ipairs(fuzzy_match_ix) do
                    print(format('    %s%s|r  %s',C(3),key,L.titles[key] or L_NO_TITLE))
                end
            else
                -- list matches
                local concat = table.concat(fuzzy_match_ix,', ',1,min(#fuzzy_match_ix,PRINT_KEYS))
                if #fuzzy_match_ix > PRINT_KEYS then
                    concat = concat..format(' %s... and %d more',C(2),#fuzzy_match_ix-PRINT_KEYS)
                end
                print('    '..concat)
            end
        end
    end
end
function command_func.locale(new_locale)
    -- set locale and reload ui
    if new_locale == 'nil' then new_locale = nil end
    KuiNameplatesCoreSaved.LOCALE = new_locale
    ReloadUI()
end
function command_func.which()
    local t = C_NamePlate.GetNamePlateForUnit('target')
    if not t then return end
    knp:ui_print(t:GetName())
end
function command_func.export()
    -- export the current profile as a string
    local profile_name = config.csv.profile
    local profile_table = config:GetActiveProfile()
    if type(profile_name) ~= 'string' or type(profile_table) ~= 'table' then
        knp:ui_print('Current profile is invalid')
        return
    end

    local d = kui:DebugPopup()
    d:AddText(profile_name..kui.table_to_string(profile_table))
    d:Show()
    d:HighlightText()
end
function command_func.import(allow_overwrite)
    local create = allow_overwrite == '!'
    local d = kui:DebugPopup(function(input)
        local profile_name
        local first_bracket = strfind(input,'{')
        if first_bracket and first_bracket > 1 then
            -- get profile name, if available
            profile_name = strsub(input,1,first_bracket-1)
            input = strsub(input,first_bracket)
        else
            profile_name = 'import'
        end

        if config.gsv.profiles[profile_name] and not create then
            -- profile with this name already exists
            knp:ui_print(format('Import failed (profile  %s  exists - use  %s  to ignore)',
                profile_name,C_command('import','!'))
            )
            return
        end

        local table,tlen = kui.string_to_table(input)
        if not table or tlen == 0 then
            knp:ui_print('Import failed (empty table)')
            return
        end

        config.csv.profile = profile_name
        config:PostProfile(profile_name,table)

        knp:ui_print(format('Switched to imported profile `%s`',profile_name))
    end)
    d:Show()
end

function SlashCmdList.KUINAMEPLATESCORE(msg)
    if msg and strmatch(msg,"[^%s]") then
        local args = {}
        for match in string.gmatch(msg,'[^%s]+') do
        -- split input by whitespace into argument table
            tinsert(args,match)
        end

        if #args > 0 and type(command_func[args[1]]) == 'function' then
            -- run given command
            local command_name = args[1]
            tremove(args,1)

            if command_func[command_name](unpack(args)) == false then
                command_func.help(command_name)
            end
            return
        end

        -- open config to named page
        return command_func.config(unpack(args))
    end
    return command_func.config()
end
-- locale ######################################################################
do
    local L = {}
    local L_enGB = {}
    function opt:Locale(region)
        -- for translations; initialise locale table
        assert(type(region) == 'string')
        if region == 'enGB' then
            -- always populate enGB
            return L_enGB
        elseif region == (KuiNameplatesCoreSaved.LOCALE or GetLocale()) then
            return L
        end
    end
    function opt:LocaleLoaded()
        if type(L.page_names) ~= 'table' then
            -- no other locale was loaded
            L = L_enGB
        else
            -- mixin missing translations from enGB
            for namespace,translations in pairs(L_enGB) do
                if not L[namespace] then
                    L[namespace] = {}
                end
                for key,value in pairs(translations) do
                    if not L[namespace][key] then
                        L[namespace][key] = value
                    end
                end
            end
            L_enGB = nil
        end
    end
    function opt:GetLocale()
        return L
    end
end
-- config handlers #############################################################
function opt:ConfigChanged(_,k)
    self.profile = config:GetConfig()
    if not self.active_page then return end

    if not k then
        -- profile changed; re-run OnShow of all visible elements
        opt:Hide()
        opt:Show()
    else
        if self.active_page.elements[k] then
            -- re-run OnShow of affected option
            self.active_page.elements[k]:Hide()
            self.active_page.elements[k]:Show()
        end

        -- re-run enabled of other options on the current page
        for _,ele in pairs(self.active_page.elements) do
            if ele.enabled then
                if ele.enabled(self.profile) then
                    ele:Enable()
                else
                    ele:Disable()
                end
            end
        end
    end
end
-- initialise ##################################################################
function opt:LayoutLoaded()
    -- called by knp core if config is already loaded when layout is initialised
    if not knp.layout then return end
    if self.config then return end

    self.config = core.config
    self.config:RegisterConfigChanged(opt,'ConfigChanged')
    config = self.config -- local alias for command functions

    self.profile = self.config:GetConfig()
end

opt:SetScript('OnEvent',function(self,_,addon)
    if addon ~= folder then return end
    self:UnregisterEvent('ADDON_LOADED')

    -- get config from layout if we were loaded on demand
    if knp.layout and knp.layout.config then
        self:LayoutLoaded()
    end
end)
opt:RegisterEvent('ADDON_LOADED')
