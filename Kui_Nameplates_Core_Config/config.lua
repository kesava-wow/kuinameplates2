--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local category = 'Kui Nameplates Core'
local knp = KuiNameplates
local kc = LibStub('KuiConfig-1.0')
local config,profile
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

nameonlyCheck:SetPoint('TOPLEFT')
hidenamesCheck:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT')
-- #############################################################################
InterfaceOptions_AddCategory(opt)
-- slash command ###############################################################
SLASH_KUINAMEPLATESCORE1 = '/knp'
SLASH_KUINAMEPLATESCORE2 = '/kuinameplates'

function SlashCmdList.KUINAMEPLATESCORE(msg)
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
end

opt:SetScript('OnEvent',function(self,event,addon)
    if addon ~= 'Kui_Nameplates_Core_Config' then return end
    -- used to get config if we're loaded on demand
    if knp.layout and knp.layout.config then
        self:LayoutLoaded()
    end

    opt:UnregisterEvent('ADDON_LOADED')
end)
opt:RegisterEvent('ADDON_LOADED')
