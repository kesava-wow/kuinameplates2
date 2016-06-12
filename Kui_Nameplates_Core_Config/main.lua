--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- configuration interface for the core layout
--------------------------------------------------------------------------------
local folder,ns = ...
local knp = KuiNameplates
local category = 'Kui |cff9966ffNameplates Core'
local kc = LibStub('KuiConfig-1.0')

-- category container
local opt = CreateFrame('Frame','KuiNameplatesCoreConfig',InterfaceOptionsFramePanelContainer)
opt:Hide()
opt.name = category
opt.pages = {}

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
-- script handlers #############################################################
opt:HookScript('OnSizeChanged',function(self)
    -- fit pages into frame
    for k,v in ipairs(self.pages) do
        v:SetWidth(opt:GetWidth()-40)
    end
end)
-- profile drop down handlers ##################################################
-- TODO move this stuff into a KuiConfig helper
local function profileDropDown_OnChanged(dd,profile_select)
    opt.config:SetProfile(profile_select)
end
local function profileDropDown_NewProfile(dd)
    -- TODO
end
local function profileDropDown_Initialize()
    local info = UIDropDownMenu_CreateInfo()

    do
        info.text = opt.titles.new_profile
        info.checked = nil
        info.func = profileDropDown_NewProfile
        UIDropDownMenu_AddButton(info)
    end

    for k,p in pairs(opt.config.gsv.profiles) do
        info.text = k
        info.arg1 = k
        info.checked = nil
        info.func = profileDropDown_OnChanged
        UIDropDownMenu_AddButton(info)
    end
end
-- config handlers #############################################################
function opt:ConfigChanged()
    self.profile = self.config:GetConfig()

    UIDropDownMenu_Initialize(self.profileDropDown,profileDropDown_Initialize)
    UIDropDownMenu_SetSelectedName(self.profileDropDown,self.config.csv.profile)

    if self:IsShown() then
        -- re-run OnShow of all visible options
        self:Hide()
        self:Show()
    end
end
-- initialise ##################################################################
function opt:LayoutLoaded()
    -- called by knp core if config is already loaded when layout is initialised
    if not knp.layout then return end
    if self.config then return end

    self.config = knp.layout.config

    self.config:RegisterConfigChanged(opt,'ConfigChanged')
    self:ConfigChanged()
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
