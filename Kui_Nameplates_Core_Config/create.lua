local folder,ns = ...
local opt = KuiNameplatesCoreConfig
-- create profile selector #####################################################
local profileDropDown = opt:CreateDropDown('profile')
profileDropDown:SetPoint('TOPLEFT',-5,-23)
-- create pages ################################################################
local general = opt:CreateConfigPage('general')
local test1 = opt:CreateConfigPage('test1')
local test2 = opt:CreateConfigPage('test2')
local test3 = opt:CreateConfigPage('test3')

-- create tabs
opt:CreateTabs()
-- show inital page
opt.pages[1]:ShowPage()

-- create elements #############################################################
local nameonlyCheck = general:CreateCheckBox('nameonly')
local hidenamesCheck = general:CreateCheckBox('hide_names')
local tankmodeCheck = general:CreateCheckBox('tank_mode')
local threatbracketsCheck = general:CreateCheckBox('threat_brackets')

nameonlyCheck:SetPoint('TOPLEFT',10,-10)
hidenamesCheck:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT')
tankmodeCheck:SetPoint('TOPLEFT',hidenamesCheck,'BOTTOMLEFT')
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
