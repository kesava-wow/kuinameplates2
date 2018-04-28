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
        d:AddText(KuiNameplatesCore.config.csv)
        d:AddText(KuiNameplatesCore.config:GetActiveProfile())
        d:Show()
        return
    elseif msg and msg ~= '' then
        -- interpret msg as config page shortcut
        local L = opt:GetLocale()
        msg = strlower(msg)

        local found
        for i,f in ipairs(opt.pages) do
            local n = strlower(L.page_names[f.name] or f.name)
            if n == msg then
                -- exact match
                found = f
                break
            elseif not found and n:match('^'..msg) then
                -- starts-with match
                -- (continue searching for exact, don't look for more fuzzies)
                found = f
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
