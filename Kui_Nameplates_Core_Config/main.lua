-- luacheck: globals SLASH_KUINAMEPLATESCORE1 SLASH_KUINAMEPLATESCORE2
-- luacheck: globals KuiNameplatesCore KuiNameplatesCoreConfig KuiNameplatesCoreSaved
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
local core = KuiNameplatesCore
local config -- set when layout is loaded

-- reuse category container created by core:Initialise
local opt = KuiNameplatesCoreConfig
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
           ((option and command..' '..C(4)..option) or command)) or
           (option and C(4)..option or '')
           )..'|r'
end

local commands = {
    'help',
    'config',
    'set',
    'find',
    'dump',
    'export',
    'import',
    'locale',
    'profile',
    'debug all',
    'debug frames',
    'debug ignore',
    'debug',
    'trace',
    'which',
}
-- XXX generate doc text (locale, delayed? etc)
local command_doc = {
    ['help'] = format('It\'s this message! Use  %s  for more.',
        C_command('help','command')),
    ['debug'] = 'Toggle debug output. Spams your chat frame.',
    ['dump'] = 'Output debug information - give this to me if you\'re reporting a problem!',
    ['config'] = {
        'Open configuration interface, optionally to a named page.',
        'Type the name of a page, full or partial, to open directly to it.',
        'This command is run by default if no other is matched.',
        format('%sUsage|r  %s',
            C(2),C_command('config','page')),
        format('%sExample|r  %s  Opens the auras page',
            C(2),'/knp aur'),
    },
    ['profile'] = {
        'Switch to named profile.',
        format('%sUsage|r  %s',
            C(2),C_command('profile','! profile name')),
        format('%sExample|r  %s  Switch to profile %s if it exists',
            C(2),'/knp profile mine','mine'),
        format('%sExample|r  %s  Switch to profile %s, creating it if it does not exist',
            C(2),'/knp profile ! new','new'),
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
            C(2),'/knp set frame_width 132'),
        format('%sExample|r  %s',
            C(2),'/knp set target_glow_colour .5,0,1,.5')
    },
    ['find'] = {
        'Search the available configuration keys.'
    },
    ['locale'] = {
        'Switch KNP\'s config language.',
        format('%sUsage|r  %s',
            C(2),C_command('locale','new_locale')),
        format('Enter  %s  as  %s  to reset to WoW\'s default.',
            'nil','new_locale'),
    },
    ['export'] = 'Export the current profile as a string.',
    ['import'] = 'Import a profile created with the export command.',
}
local command_func = {}
function command_func.help(command,...)
    if not command then
        knp:ui_print('Available commands:')
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
command_func['debug frames'] = function()
    -- luacheck: globals KuiNameplatesPlayerAnchor
    knp.draw_frames = not knp.draw_frames
    if knp.draw_frames then
        KuiNameplatesPlayerAnchor:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
        KuiNameplatesPlayerAnchor:SetBackdropBorderColor(0,0,1)
        for _,f in knp:Frames() do
            f:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
            f:SetBackdropBorderColor(1,1,1)
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
end
command_func['debug all'] = function()
    -- spam mode
    knp.debug = true
    knp.debug_messages = true
    knp.debug_events = true
    knp.debug_callbacks = true
    if type(knp.DEBUG_IGNORE) == 'table' then
        wipe(knp.DEBUG_IGNORE)
    end
end
command_func['debug ignore'] = function(to_ignore)
    knp.DEBUG_IGNORE = knp.DEBUG_IGNORE or {}
    knp.DEBUG_IGNORE[to_ignore] = not knp.DEBUG_IGNORE[to_ignore]
end
function command_func.debug()
    knp.debug = true
    knp.debug_messages = not knp.debug_messages
    knp.debug_events = knp.debug_messages
    knp.debug_callbacks = knp.debug_messages
end
function command_func.trace(command,...)
    --@debug@
    local script_profile = GetCVarBool('scriptProfile')
    local args = table.concat({...},' ')
    if command == 'p' then
        knp:PrintTrace(tonumber(args))
        return
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
        return
    elseif script_profile then
        knp.profiling = not knp.profiling
        knp:print('Profiling '..(knp.profiling and 'started' or 'stopped'))
        return
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
    return
end
function command_func.profile(arg1,argv)
    local create
    if arg1 == '!' then
        create = true
        arg1 = argv
    elseif argv and argv ~= '' then
        arg1 = arg1..' '..argv
    end
    if create or config.gsv.profiles[arg1] then
        config:SetProfile(arg1)
        knp:ui_print(format('Switched to profile `%s`.',arg1))
    else
        knp:ui_print(format('No profile with name `%s`.',arg1))
    end
end
function command_func.set(arg1,argv)
    if not arg1 then return false end

    local extant_v = opt.profile[arg1]
    if type(extant_v) == 'nil' then
        knp:ui_print(format('Invalid config key `%s`.',arg1))
        return
    end

    if argv == 'nil' then
        -- reset the key
        argv = nil
    else
        if strlower(argv) == 'true' then
            argv = true
        elseif strlower(argv) == 'false' then
            argv = false
        elseif tonumber(argv) then
            argv = tonumber(argv)
        else
            -- string; find colour tables
            local r,g,b,a = strmatch(argv,'^([^,]-),([^,]-),([^,]-)$')
            if not r then
                r,g,b,a = strmatch(argv,'^([^,]-),([^,]-),([^,]-),([^,]-)$')
            end

            r,g,b,a = tonumber(r),tonumber(g),tonumber(b),tonumber(a)
            if r and g and b then
                argv = { r, g, b }
                if a then
                    tinsert(argv,a)
                end
            end
        end

        if type(extant_v) ~= type(argv) then
            knp:ui_print(format('Invalid value for key (expected %s, got %s).',
                type(extant_v),type(argv)))
            return
        end
        if type(argv) == 'table' and #argv ~= #extant_v then
            knp:ui_print(format('Invalid table length (expected %d, got %d).',
                #extant_v,#argv))
            return
        end
    end

    config:SetKey(arg1,argv)
end
do
    local L_NO_TITLE = C(2)..'(no description)'
    local PRINT_KEYS = 15
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
                if not key:match(search) then
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
            if #fuzzy_match_ix <= 5 then
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
function command_func.locale(arg1)
    -- set locale and reload ui
    if arg1 == 'nil' then arg1 = nil end
    KuiNameplatesCoreSaved.LOCALE = arg1
    ReloadUI()
end
function command_func.which()
    local t = C_NamePlate.GetNamePlateForUnit('target')
    if not t then return end
    knp:ui_print(t:GetName())
end
function command_func.export()
    -- export the current profile as a string
    local d = kui:DebugPopup()
    d:AddText(config:GetActiveProfile())
    d:Show()
    d:HighlightText()
end
function command_func.import()
    local d = kui:DebugPopup(function(input)
        local profile_name = 'import test'
        local table,tlen = kui.string_to_table(input)

        if not table or tlen == 0 then
            knp:ui_print('Import failed (empty table).')
            return
        end

        config.csv.profile = profile_name
        config:PostProfile(profile_name,table)

        knp:ui_print(format('Switched to imported profile `%s`.',profile_name))
    end)
    d:Show()
end

function SlashCmdList.KUINAMEPLATESCORE(msg)
    if strmatch(msg,"[^%s]") then
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
