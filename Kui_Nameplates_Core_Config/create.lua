local folder,ns = ...
local opt = KuiNameplatesCoreConfig

opt:Initialise()
-- create profile selector #####################################################
local profileDropDown = opt:CreateDropDown('profile',130)
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

-- show inital page
opt.pages[1]:ShowPage()

-- create elements #############################################################
-- general #####################################################################
local nameonlyCheck = general:CreateCheckBox('nameonly')

nameonlyCheck:SetPoint('TOPLEFT',10,-10)

-- text ########################################################################
local font_size_normal = text:CreateSlider('font_size_normal',1,20)
local font_size_small = text:CreateSlider('font_size_small',1,20)
local hidenamesCheck = text:CreateCheckBox('hide_names')

font_size_normal:SetPoint('TOPLEFT',10,-30)
font_size_small:SetPoint('LEFT',font_size_normal,'RIGHT',20,0)
hidenamesCheck:SetPoint('TOPLEFT',font_size_normal,'BOTTOMLEFT',0,-20)

-- frame sizes #################################################################
local frame_width = framesizes:CreateSlider('frame_width',20,200)
local frame_height = framesizes:CreateSlider('frame_height',3,40)
local frame_width_minus = framesizes:CreateSlider('frame_width_minus',20,200)
local frame_height_minus = framesizes:CreateSlider('frame_height_minus',3,40)

frame_width:SetPoint('TOPLEFT',10,-30)
frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
frame_width_minus:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-30)
frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)

-- cast bars ###################################################################
local castbar_enable = castbars:CreateCheckBox('castbar_enable')
local castbar_personal = castbars:CreateCheckBox('castbar_showpersonal')
local castbar_all = castbars:CreateCheckBox('castbar_showall')
local castbar_friend = castbars:CreateCheckBox('castbar_showfriend')
local castbar_enemy = castbars:CreateCheckBox('castbar_showenemy')

castbar_enable:SetPoint('TOPLEFT',10,-10)
castbar_personal:SetPoint('TOPLEFT',castbar_enable,'BOTTOMLEFT')
castbar_all:SetPoint('TOPLEFT',castbar_personal,'BOTTOMLEFT')
castbar_friend:SetPoint('TOPLEFT',castbar_all,'BOTTOMLEFT')
castbar_enemy:SetPoint('TOPLEFT',castbar_friend,'BOTTOMLEFT')

castbar_personal.enabled = function(p) return p.castbar_enable end
castbar_all.enabled = function(p) return p.castbar_enable end
castbar_friend.enabled = function(p) return p.castbar_enable and p.castbar_showall end
castbar_enemy.enabled = function(p) return p.castbar_enable and p.castbar_showall end

-- threat ######################################################################
local tankmodeCheck = threat:CreateCheckBox('tank_mode')
local threatbracketsCheck = threat:CreateCheckBox('threat_brackets')

tankmodeCheck:SetPoint('TOPLEFT',10,-10)
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')
