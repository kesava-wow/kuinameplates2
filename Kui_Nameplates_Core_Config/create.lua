local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local LSM = LibStub('LibSharedMedia-3.0')

opt:Initialise()
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
local bar_texture = general:CreateDropDown('bar_texture')
local nameonlyCheck = general:CreateCheckBox('nameonly')
local glow_as_shadow = general:CreateCheckBox('glow_as_shadow')
local target_glow = general:CreateCheckBox('target_glow')
local target_glow_colour = general:CreateColourPicker('target_glow_colour')

bar_texture:SetPoint('TOP',0,-30)
nameonlyCheck:SetPoint('TOPLEFT',10,-70)
glow_as_shadow:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT')
target_glow:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT')
target_glow_colour:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT',200,0)

local colour_sep = general:CreateSeperator('reaction_colour_sep')
local colour_hated = general:CreateColourPicker('colour_hated')
local colour_neutral = general:CreateColourPicker('colour_neutral')
local colour_friendly = general:CreateColourPicker('colour_friendly')
local colour_tapped = general:CreateColourPicker('colour_tapped')
local colour_player = general:CreateColourPicker('colour_player')

colour_sep:SetPoint('TOP',0,-180)
colour_hated:SetPoint('TOPLEFT',15,-200)
colour_neutral:SetPoint('LEFT',colour_hated,'RIGHT')
colour_friendly:SetPoint('LEFT',colour_neutral,'RIGHT')
colour_tapped:SetPoint('TOPLEFT',colour_hated,'BOTTOMLEFT')
colour_player:SetPoint('LEFT',colour_tapped,'RIGHT')

target_glow_colour.enabled = function(p) return p.target_glow end

function bar_texture:initialize()
    local info = UIDropDownMenu_CreateInfo()

    for k,f in ipairs(LSM:List(LSM.MediaType.STATUSBAR)) do
        info.text = f
        info.arg1 = self
        info.arg2 = f
        info.checked = nil
        info.func = self.OnChanged
        UIDropDownMenu_AddButton(info)
    end
end

-- text ########################################################################
local font_face = text:CreateDropDown('font_face',175)
local font_style = text:CreateDropDown('font_style',175)

local font_size_normal = text:CreateSlider('font_size_normal',1,20)
font_size_normal:SetWidth(190)
local font_size_small = text:CreateSlider('font_size_small',1,20)
font_size_small:SetWidth(190)

local hidenamesCheck = text:CreateCheckBox('hide_names')
local level_text = text:CreateCheckBox('level_text')
local health_text = text:CreateCheckBox('health_text')

local text_vertical_offset = text:CreateSlider('text_vertical_offset',-20,20)
text_vertical_offset:SetWidth(120)
text_vertical_offset:SetValueStep(.5)
local name_vertical_offset = text:CreateSlider('name_vertical_offset',-20,20)
name_vertical_offset:SetWidth(120)
name_vertical_offset:SetValueStep(.5)
local bot_vertical_offset = text:CreateSlider('bot_vertical_offset',-20,20)
bot_vertical_offset:SetWidth(120)
bot_vertical_offset:SetValueStep(.5)

bot_vertical_offset.enabled = function(p) return p.level_text or p.health_text end

font_face:SetPoint('TOPLEFT',-5,-30)
font_style:SetPoint('LEFT',font_face,'RIGHT',-20,0)

font_size_normal:SetPoint('TOPLEFT',10,-90)
font_size_small:SetPoint('LEFT',font_size_normal,'RIGHT',20,0)

text_vertical_offset:SetPoint('TOPLEFT',font_size_normal,'BOTTOMLEFT',0,-30)
name_vertical_offset:SetPoint('LEFT',text_vertical_offset,'RIGHT',20,0)
bot_vertical_offset:SetPoint('LEFT',name_vertical_offset,'RIGHT',20,0)

hidenamesCheck:SetPoint('TOPLEFT',text_vertical_offset,'BOTTOMLEFT',0,-20)
level_text:SetPoint('TOPLEFT',hidenamesCheck,'BOTTOMLEFT')
health_text:SetPoint('TOPLEFT',level_text,'BOTTOMLEFT')

function font_face:initialize()
    local info = UIDropDownMenu_CreateInfo()

    for k,f in ipairs(LSM:List(LSM.MediaType.FONT)) do
        info.text = f
        info.arg1 = self
        info.arg2 = f
        info.checked = nil
        info.func = self.OnChanged

        UIDropDownMenu_AddButton(info)
    end
end

font_style.SelectTable = { 'None','Outline','Monochrome' }
function font_style:initialize()
    local info = UIDropDownMenu_CreateInfo()

    for k,f in ipairs(self.SelectTable) do
        info.text = f
        info.arg1 = self
        info.arg2 = k
        info.checked = nil
        info.func = self.OnChanged

        UIDropDownMenu_AddButton(info)
    end

    UIDropDownMenu_SetSelectedName(self,self.SelectTable[opt.profile[self.env]])

    -- we manually set the selected entry
    self.manual = true
end

-- frame sizes #################################################################
local frame_width = framesizes:CreateSlider('frame_width',20,200)
frame_width:SetWidth(190)
local frame_height = framesizes:CreateSlider('frame_height',3,40)
frame_height:SetWidth(190)
local frame_width_minus = framesizes:CreateSlider('frame_width_minus',20,200)
frame_width_minus:SetWidth(190)
local frame_height_minus = framesizes:CreateSlider('frame_height_minus',3,40)
frame_height_minus:SetWidth(190)
local castbar_height = framesizes:CreateSlider('castbar_height',3,20)
castbar_height:SetWidth(190)

frame_width:SetPoint('TOPLEFT',10,-30)
frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
frame_width_minus:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-30)
frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)
castbar_height:SetPoint('TOPLEFT',frame_width_minus,'BOTTOMLEFT',0,-30)

-- auras #######################################################################
local auras_enabled = auras:CreateCheckBox('auras_enabled')
local auras_whitelist = auras:CreateCheckBox('auras_whitelist')
local auras_pulsate = auras:CreateCheckBox('auras_pulsate')

local auras_filtering_sep = auras:CreateSeperator('auras_filtering_sep')
local auras_time_threshold = auras:CreateSlider('auras_time_threshold',-1,180)
local auras_minimum_length = auras:CreateSlider('auras_minimum_length',0,60)
local auras_maximum_length = auras:CreateSlider('auras_maximum_length',-1,1800)

local auras_icons_sep = auras:CreateSeperator('auras_icons_sep')
local auras_icon_normal_size = auras:CreateSlider('auras_icon_normal_size',10,50)
local auras_icon_minus_size = auras:CreateSlider('auras_icon_minus_size',10,50)
local auras_icon_squareness = auras:CreateSlider('auras_icon_squareness',0.5,1)

auras_icon_squareness:SetValueStep(.1)

auras_enabled:SetPoint('TOPLEFT',10,-10)
auras_whitelist:SetPoint('TOPLEFT',auras_enabled,'BOTTOMLEFT')
auras_pulsate:SetPoint('LEFT',auras_whitelist,'RIGHT',150,0)

auras_filtering_sep:SetPoint('TOP',0,-100)
auras_time_threshold:SetPoint('TOPLEFT',auras_whitelist,'BOTTOMLEFT',53,-70)
auras_minimum_length:SetPoint('TOPLEFT',auras_time_threshold,'BOTTOMLEFT',0,-30)
auras_maximum_length:SetPoint('LEFT',auras_minimum_length,'RIGHT',20,0)

auras_icons_sep:SetPoint('TOP',0,-240)
auras_icon_normal_size:SetPoint('TOPLEFT',auras_minimum_length,'BOTTOMLEFT',0,-80)
auras_icon_minus_size:SetPoint('LEFT',auras_icon_normal_size,'RIGHT',20,0)
auras_icon_squareness:SetPoint('TOPLEFT',auras_icon_normal_size,'BOTTOMLEFT',0,-30)

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
local tankmode_force_enable = threat:CreateCheckBox('tankmode_force_enable')
local threatbracketsCheck = threat:CreateCheckBox('threat_brackets')
local tankmode_colour_sep = threat:CreateSeperator('tankmode_colour_sep')
local tankmode_tank_colour = threat:CreateColourPicker('tankmode_tank_colour')
local tankmode_trans_colour = threat:CreateColourPicker('tankmode_trans_colour')
local tankmode_other_colour = threat:CreateColourPicker('tankmode_other_colour')

tankmode_force_enable.enabled = function(p) return p.tank_mode end
tankmode_tank_colour.enabled = function(p) return p.tank_mode end
tankmode_trans_colour.enabled = function(p) return p.tank_mode end
tankmode_other_colour.enabled = function(p) return p.tank_mode end

tankmodeCheck:SetPoint('TOPLEFT',10,-10)
tankmode_force_enable:SetPoint('LEFT',tankmodeCheck,'RIGHT',150,0)
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')

tankmode_colour_sep:SetPoint('TOP',0,-100)
tankmode_tank_colour:SetPoint('TOPLEFT',15,-120)
tankmode_trans_colour:SetPoint('LEFT',tankmode_tank_colour,'RIGHT')
tankmode_other_colour:SetPoint('LEFT',tankmode_trans_colour,'RIGHT')
