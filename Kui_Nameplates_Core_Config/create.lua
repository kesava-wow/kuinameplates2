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
local testslider2 = framesizes:CreateSlider('test2')
local testslider3 = framesizes:CreateSlider('test3')
local testslider4 = framesizes:CreateSlider('test4')

testslider:SetPoint('TOPLEFT',10,-30)
testslider2:SetPoint('TOPLEFT',testslider,'BOTTOMLEFT',0,-30)
testslider3:SetPoint('TOPLEFT',testslider2,'BOTTOMLEFT',0,-30)
testslider4:SetPoint('LEFT',testslider,'RIGHT',20,0)

-- cast bars ###################################################################
local castbar_personal = castbars:CreateCheckBox('castbar_showpersonal')
local castbar_all = castbars:CreateCheckBox('castbar_showall')
local castbar_friend = castbars:CreateCheckBox('castbar_showfriend')

castbar_personal:SetPoint('TOPLEFT',10,-10)
castbar_all:SetPoint('TOPLEFT',castbar_personal,'BOTTOMLEFT')
castbar_friend:SetPoint('TOPLEFT',castbar_all,'BOTTOMLEFT')

-- threat ######################################################################
local tankmodeCheck = threat:CreateCheckBox('tank_mode')
local threatbracketsCheck = threat:CreateCheckBox('threat_brackets')

tankmodeCheck:SetPoint('TOPLEFT',10,-10)
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
