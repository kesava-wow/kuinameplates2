--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local folder,ns = ...
local knp = KuiNameplates
local kui = LibStub('Kui-1.0')
local kc = LibStub('KuiConfig-1.0')

-- reuse container created by core:Initialise
local opt = KuiNameplatesCoreConfig
assert(opt)
opt.pages = {}

-- slash command ###############################################################
SLASH_KUINAMEPLATESCORE1 = '/knp'
SLASH_KUINAMEPLATESCORE2 = '/kuinameplates'

function SlashCmdList.KUINAMEPLATESCORE(msg)
    if msg == 'debug' then
        knp.debug = true
        knp.debug_messages = not knp.debug_messages
        knp.debug_events = knp.debug_messages
        knp.debug_callbacks = knp.debug_messages
        if knp.debug_messages and not knp.DEBUG_IGNORE then
            knp.DEBUG_IGNORE = {
                ['m:Create'] = true,
                ['m:Show'] = true,
                ['m:Hide'] = true,
                ['e:UNIT_POWER_FREQUENT'] = true,
                ['e:UNIT_HEALTH_FREQUENT'] = true,
                ['c:Auras:DisplayAura'] = true,
            }
        end
        return
    elseif knp.debug and strfind(msg,'^trace') then
        --@debug@
        local script_profile = GetCVarBool('scriptProfile')
        if strfind(msg,'^trace p') then
            local k = strmatch(msg,'^trace p ?(%d*)$')
            knp:PrintTrace(tonumber(k))
        elseif script_profile and msg == 'trace off' then
            if InCombatLockdown() then return end
            SetCVar('scriptProfile',false)
            ReloadUI()
        elseif not script_profile then
            if InCombatLockdown() then return end
            SetCVar('scriptProfile',true)
            ReloadUI()
        else
            knp.profiling = not knp.profiling
            knp:print('Profiling '..(knp.profiling and 'started' or 'stopped'))
        end
        --@end-debug@
        return
    elseif msg == 'debug-frames' then
        knp.draw_frames = not knp.draw_frames
        if knp.draw_frames then
            KuiNameplatesPlayerAnchor:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
            KuiNameplatesPlayerAnchor:SetBackdropBorderColor(0,0,1)
            for k,f in knp:Frames() do
                f:SetBackdrop({edgeFile=kui.m.t.solid,edgeSize=1})
                f:SetBackdropBorderColor(1,1,1)
                f.parent:SetBackdrop({bgFile=kui.m.t.solid})
                f.parent:SetBackdropColor(0,0,0)
            end
        else
            KuiNameplatesPlayerAnchor:SetBackdrop(nil)
            for k,f in knp:Frames() do
                f:SetBackdrop(nil)
                f.parent:SetBackdrop(nil)
            end
        end
        return
    elseif knp.debug and strfind(msg,'^debug%-ignore') then
        local to_ignore = strmatch(msg,'^debug%-ignore (.-)%s*$')
        knp.DEBUG_IGNORE = knp.DEBUG_IGNORE or {}
        knp.DEBUG_IGNORE[to_ignore] = not knp.DEBUG_IGNORE[to_ignore]
        return
    elseif msg == 'dump-config' then
        local d = kui:DebugPopup()
        d:AddText(format('%s %d.%d %s',
            '@project-version@',knp.MAJOR,knp.MINOR,tostring(knp.debug)))
        d:AddText(KuiNameplatesCore.config.csv)
        d:AddText(KuiNameplatesCore.config:GetActiveProfile())
        d:Show()
        return
    elseif strfind(msg,'^profile') then
        local profile = strmatch(msg,'^profile (.-)%s*$')
        if not profile then
            knp:ui_print('Switch to named profile. Usage: /knp profile profile name')
            return
        end
        if KuiNameplatesCore.config.gsv.profiles[profile] then
            KuiNameplatesCore.config:SetProfile(profile)
        end
        return
    elseif strfind(msg,'^set') then
        local k,v = strmatch(msg,'^set (.-) (.-)%s*$')
        if not k or not v then
            knp:ui_print('Set config key to value. Usage: /knp set config_key value')
            print(' Only boolean (true, false), numeric and string values can be set by this command.')
            return
        end

        local extant_v = KuiNameplatesCore.profile[k]
        if type(extant_v) == 'nil' then
            knp:ui_print(format('Invalid config key `%s`.',k))
            return
        end

        v = (strlower(v) == 'true' and true) or
            (strlower(v) == 'false' and false) or
            tonumber(v) or v

        if type(extant_v) ~= type(v) then
            knp:ui_print(format('Invalid value for key (expected %s, got %s).',
                type(extant_v),type(v)))
            return
        end

        KuiNameplatesCore.config:SetKey(k,v)
        return
    elseif msg and msg ~= '' then
        -- interpret msg as config page shortcut
        local L = opt:GetLocale()
        msg = strlower(msg)

        local found
        for i,f in ipairs(opt.pages) do
            if f.name then
                local name = f.name
                local locale = L.page_names[name] and
                               strlower(L.page_names[name])

                if msg == name or msg == locale then
                    -- exact match
                    found = f
                    break
                elseif not found and
                    (name:match('^'..msg) or locale:match('^'..msg))
                then
                    -- starts-with match, continue searching for exact matches
                    found = f
                end
            end
        end

        if found then
            found:ShowPage()
        end
    end

    -- 6.2.2: call twice to force it to open to the correct frame
    InterfaceOptionsFrame_OpenToCategory(opt.name)
    InterfaceOptionsFrame_OpenToCategory(opt.name)
end
-- locale ######################################################################
do
    local L = {}
    function opt:Locale(region)
        assert(type(region) == 'string')
        if region == 'enGB' or region == GetLocale() then
            return L
        end
    end
    function opt:GetLocale()
        return L
    end
end
-- config handlers #############################################################
function opt:ConfigChanged(config,k)
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
        for name,ele in pairs(self.active_page.elements) do
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

    self.config = knp.layout.config

    self.config:RegisterConfigChanged(opt,'ConfigChanged')
    self.profile = self.config:GetConfig()
end

opt:SetScript('OnEvent',function(self,event,addon)
    if addon ~= folder then return end
    self:UnregisterEvent('ADDON_LOADED')

    -- get config from layout if we were loaded on demand
    if knp.layout and knp.layout.config then
        self:LayoutLoaded()
    end
end)
opt:RegisterEvent('ADDON_LOADED')
