local folder,ns = ...
local opt = KuiNameplatesCoreConfig
-- create profile selector #####################################################
local profileDropDown = opt:CreateDropDown('profile')
profileDropDown:SetPoint('TOPLEFT',-5,-23)
opt.profileDropDown = profileDropDown
-- create pages ################################################################
local general = opt:CreateConfigPage('general')
local text = opt:CreateConfigPage('text')
local framesizes = opt:CreateConfigPage('framesizes')
local auras = opt:CreateConfigPage('auras')
local castbars = opt:CreateConfigPage('castbars')
local classpowers = opt:CreateConfigPage('classpowers')
local threat = opt:CreateConfigPage('threat')

-- create tabs
opt:CreateTabs()
-- show inital page
opt.pages[1]:ShowPage()

-- create elements #############################################################
-- general #####################################################################
local nameonlyCheck = general:CreateCheckBox('nameonly')

nameonlyCheck:SetPoint('TOPLEFT',10,-10)

-- text ########################################################################
local hidenamesCheck = text:CreateCheckBox('hide_names')

hidenamesCheck:SetPoint('TOPLEFT',10,-10)

-- frame sizes #################################################################
local testslider = framesizes:CreateSlider('test')

testslider:SetPoint('TOPLEFT',10,-10)

-- threat ######################################################################
local tankmodeCheck = threat:CreateCheckBox('tank_mode')
local threatbracketsCheck = threat:CreateCheckBox('threat_brackets')

tankmodeCheck:SetPoint('TOPLEFT',10,-10)
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
