--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local folder,ns = ...
local category = 'Kui |cff9966ffNameplates Core'
local frame_name = 'KuiNameplatesCoreConfig'
local knp = KuiNameplates
local kc = LibStub('KuiConfig-1.0')
local config,profile
-- strings #####################################################################
local page_names = {
    general = 'General',
    test1 = 'Test 1',
    test2 = 'Test 2',
    test3 = 'Something different'
}
local opt_tooltips = {
    nameonly = 'Hide the healthbars of friendly or unattackable units',
    tank_mode = 'Recolour the health bars of units you are actively tanking',
}
local opt_titles = {
    nameonly = 'Use nameonly mode',
    hide_names = 'Hide unimportant unit names',
    tank_mode = 'Enable tank mode',
    threat_brackets = 'Show threat brackets'
}
-- load-on-demand ##############################################################
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
    -- remove AddonLoader's fake category
    AddonLoader:RemoveInterfaceOptions(category)

    -- and nil its slash commands
    SLASH_KUINAMEPLATES1 = nil
    SLASH_KNP1 = nil
    SlashCmdList.KUINAMEPLATES = nil
    SlashCmdList.KNP = nil
    hash_SlashCmdList["/kuinameplates"] = nil
    hash_SlashCmdList["/knp"] = nil
end
-- category container ##########################################################
local opt = CreateFrame('Frame',frame_name,InterfaceOptionsFramePanelContainer)
opt:Hide()
opt.name = category
opt.pages = {}
-- helpers #####################################################################
do
    local function OnEnter(self)
        GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
        GameTooltip:SetWidth(200)
        GameTooltip:AddLine(self.desc:GetText())

        if tooltip_text[self.env] then
            GameTooltip:AddLine(tooltip_text[self.env], 1,1,1,true)
        end

        GameTooltip:Show()
    end
    local function OnLeave(self)
        GameTooltip:Hide()
    end
    local function CheckBoxOnClick(self)
        if self:GetChecked() then
            PlaySound("igMainMenuOptionCheckBoxOn")
        else
            PlaySound("igMainMenuOptionCheckBoxOff")
        end

        if self.env then
            config:SetConfig(self.env,self:GetChecked())
        end

        if self.callback then
            self:callback()
        end
    end
    local function CheckBoxOnShow(self)
        if not profile then return end
        if self.env then
            self:SetChecked(profile[self.env])
        end
    end
    local function CreateCheckBox(parent, name, callback)
        local check = CreateFrame('CheckButton', frame_name..name..'Check', parent, 'OptionsBaseCheckButtonTemplate')

        check.env = name
        check.callback = callback
        check:SetScript('OnClick',CheckBoxOnClick)
        check:SetScript('OnShow',CheckBoxOnShow)

        check:HookScript('OnEnter',OnEnter)
        check:HookScript('OnLeave',OnLeave)

        check.desc = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        check.desc:SetText(opt_titles[name] or 'Checkbox')
        check.desc:SetPoint('LEFT', check, 'RIGHT')

        return check
    end
    -- page functions
    local function ShowPage(self)
        if opt.active_page then
            opt.active_page:HidePage()
        end

        self.scroll:Show()
        self.bg:Show()
        self:Show()

        opt.active_page = self
    end
    local function HidePage(self)
        self.scroll:Hide()
        self.bg:Hide()
        self:Hide()
    end
    local page_proto = {
        CreateCheckBox = CreateCheckBox,

        HidePage = HidePage,
        ShowPage = ShowPage
    }
    function opt:CreateConfigPage(name)
        local f = CreateFrame('Frame',frame_name..name..'Page',self)
        f.name = name

        f.scroll = CreateFrame('ScrollFrame',frame_name..name..'PageScrollFrame',self,'UIPanelScrollFrameTemplate')
        f.scroll:SetPoint('TOPLEFT',20,-50)
        f.scroll:SetPoint('BOTTOMRIGHT',-40,20)
        f.scroll:SetScrollChild(f)

        f.bg = CreateFrame('Frame',nil,self)
        f.bg:SetBackdrop({
            bgFile = 'Interface/ChatFrame/ChatFrameBackground',
            edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        f.bg:SetBackdropColor(.1, .1, .1, .3)
        f.bg:SetBackdropBorderColor(.5, .5, .5)
        f.bg:SetPoint('TOPLEFT',f.scroll,-10,10)
        f.bg:SetPoint('BOTTOMRIGHT',f.scroll,30,-10)

        f:SetWidth(1)
        f:SetHeight(1000)

        -- mixin page functions
        for k,v in pairs(page_proto) do
            f[k]=v
        end

        f:HidePage()

        tinsert(self.pages,f)
        return f
    end
end
-- tab functions ###############################################################
do
    local function OnClick(self)
        self.child:ShowPage()
    end
    function opt:CreateTabs(self)
        local pt
        for k,v in ipairs(opt.pages) do
            local tab = CreateFrame('Button',frame_name..v.name..'PageTab',opt,'TabButtonTemplate')
            tab:HookScript('OnClick',OnClick)
            tab:SetText(page_names[v.name] or 'Tab')
            tab.child = v

            if pt then
                tab:SetPoint('LEFT',pt,'RIGHT')
            else
                tab:SetPoint('TOPLEFT',10,-8)
            end

            PanelTemplates_TabResize(tab,5)

            pt = tab
        end

    end
end
-- #############################################################################
-- options frame elements ######################################################
-- page containers #############################################################
local general = opt:CreateConfigPage('general')
local test1 = opt:CreateConfigPage('test1')
local test2 = opt:CreateConfigPage('test2')
local test3 = opt:CreateConfigPage('test3')
-- create elements #############################################################
local nameonlyCheck = general:CreateCheckBox('nameonly')
local hidenamesCheck = general:CreateCheckBox('hide_names')
local tankmodeCheck = general:CreateCheckBox('tank_mode')
local threatbracketsCheck = general:CreateCheckBox('threat_brackets')

nameonlyCheck:SetPoint('TOPLEFT',10,-10)
hidenamesCheck:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT')
tankmodeCheck:SetPoint('TOPLEFT',hidenamesCheck,'BOTTOMLEFT')
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
-- #############################################################################
-- create tabs
opt:CreateTabs()
-- show inital page
opt.pages[1]:ShowPage()
-- add to interface
InterfaceOptions_AddCategory(opt)

-- 6.2.2: workaround for the category not populating correctly OnClick
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
    local lastFrame = InterfaceOptionsFrame.lastFrame
    InterfaceOptionsFrame.lastFrame = nil
    InterfaceOptionsFrame_Show()
    InterfaceOptionsFrame_OpenToCategory(category)
    InterfaceOptionsFrame_OpenToCategory(category)
    InterfaceOptionsFrame.lastFrame = lastFrame
    lastFrame = nil
end
-- slash command ###############################################################
SLASH_KUINAMEPLATESCORE1 = '/knp'
SLASH_KUINAMEPLATESCORE2 = '/kuinameplates'

function SlashCmdList.KUINAMEPLATESCORE(msg)
    -- 6.2.2: call twice to force it to open to the correct frame
    InterfaceOptionsFrame_OpenToCategory(category)
    InterfaceOptionsFrame_OpenToCategory(category)
end
-- initialise ##################################################################
function opt:LayoutLoaded()
    -- called by knp core if config is already loaded when layout is initialised
    if not knp.layout then return end
    if config then return end

    config = knp.layout.config
    profile = config:GetConfig()

    config:RegisterConfigChanged(function(self)
        profile = self:GetConfig()
    end)
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
