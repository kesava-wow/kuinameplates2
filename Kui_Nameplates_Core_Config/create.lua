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
local frame_width = framesizes:CreateSlider('frame_width')
local frame_height = framesizes:CreateSlider('frame_height')
local frame_width_minus = framesizes:CreateSlider('frame_width_minus')
local frame_height_minus = framesizes:CreateSlider('frame_height_minus')

frame_width:SetPoint('TOPLEFT',10,-30)
frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
frame_width_minus:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-30)
frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)

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
