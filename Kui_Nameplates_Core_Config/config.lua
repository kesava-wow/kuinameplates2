--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
local category = 'Kui Nameplates Core'
local knp = KuiNameplates
local kc = LibStub('KuiConfig-1.0')
local config,profile

local opt = CreateFrame('Frame','KuiNameplatesCoreConfig',InterfaceOptionsFramePanelContainer)
opt:Hide()
opt.name = category

InterfaceOptions_AddCategory(opt)

opt:HookScript('OnShow',function()
    config,profile = knp.layout.config,knp.layout.config:GetConfig()
    print(profile.nameonly)
end)
-- slash command ###############################################################
SLASH_KUINAMEPLATESCORE1 = '/knp'
SLASH_KUINAMEPLATESCORE2 = '/kuinameplates'

function SlashCmdList.KUINAMEPLATESCORE(msg)
    InterfaceOptionsFrame_OpenToCategory(category)
end
