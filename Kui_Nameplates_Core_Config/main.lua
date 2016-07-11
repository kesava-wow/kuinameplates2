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
