--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local folder,ns = ...
local category = 'Kui |cff9966ffNameplates Core'
local knp = KuiNameplates
local kc = LibStub('KuiConfig-1.0')
local config,profile
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
-- #############################################################################
local opt = CreateFrame('Frame','KuiNameplatesCoreConfig',InterfaceOptionsFramePanelContainer)
opt:Hide()
opt.name = category
-- helpers #####################################################################
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
local function CreateCheckBox(name, desc, callback)
    local check = CreateFrame('CheckButton', 'KuiNameplatesCoreConfig'..name..'Check', opt, 'OptionsBaseCheckButtonTemplate')

    check.env = name
    check.callback = callback
    check:SetScript('OnClick',CheckBoxOnClick)
    check:SetScript('OnShow',CheckBoxOnShow)

    check.desc = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    check.desc:SetText(desc)
    check.desc:SetPoint('LEFT', check, 'RIGHT')

    return check
end
-- create elements #############################################################
local nameonlyCheck = CreateCheckBox('nameonly','Use nameonly mode')
local hidenamesCheck = CreateCheckBox('hide_names','Hide unimportant unit names')
local tankmodeCheck = CreateCheckBox('tank_mode','Enable tank mode')
local threatbracketsCheck = CreateCheckBox('threat_brackets','Show threat brackets')

nameonlyCheck:SetPoint('TOPLEFT',20,-20)
hidenamesCheck:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT')
tankmodeCheck:SetPoint('TOPLEFT',hidenamesCheck,'BOTTOMLEFT')
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
-- add to interface ############################################################
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
