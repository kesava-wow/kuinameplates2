local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local LSM = LibStub('LibSharedMedia-3.0')

local version = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
version:SetAlpha(.7)
version:SetPoint('TOPRIGHT',-12,-12)
version:SetText(string.format(
    opt.titles.version,
    'KuiNameplates','Kesava','@project-version@'
))

opt:Initialise()
-- create pages ################################################################
local general     = opt:CreateConfigPage('general')
local healthbars  = opt:CreateConfigPage('healthbars')
local castbars    = opt:CreateConfigPage('castbars')
local text        = opt:CreateConfigPage('text')
local nameonly    = opt:CreateConfigPage('nameonly')
local framesizes  = opt:CreateConfigPage('framesizes')
local auras       = opt:CreateConfigPage('auras')
local threat      = opt:CreateConfigPage('threat')
local classpowers = opt:CreateConfigPage('classpowers')

-- show inital page
opt.pages[1]:ShowPage()

-- create elements #############################################################
-- general #####################################################################
local combat_hostile = general:CreateDropDown('combat_hostile')
local combat_friendly = general:CreateDropDown('combat_friendly')
local ignore_uiscale = general:CreateCheckBox('ignore_uiscale')
local glow_as_shadow = general:CreateCheckBox('glow_as_shadow')
local state_icons = general:CreateCheckBox('state_icons')
local target_glow = general:CreateCheckBox('target_glow')
local target_glow_colour = general:CreateColourPicker('target_glow_colour')
local target_arrows = general:CreateCheckBox('target_arrows')
local frame_glow_size = general:CreateSlider('frame_glow_size',4,16)
local target_arrows_size = general:CreateSlider('target_arrows_size',20,60)

combat_hostile.SelectTable = {'Do nothing','Hide','Show'}
combat_friendly.SelectTable = {'Do nothing','Hide','Show'}

combat_hostile:SetPoint('TOPLEFT',10,-10)
combat_friendly:SetPoint('LEFT',combat_hostile,'RIGHT',10,0)

ignore_uiscale:SetPoint('TOPLEFT',10,-60)
glow_as_shadow:SetPoint('TOPLEFT',ignore_uiscale,'BOTTOMLEFT')
state_icons:SetPoint('LEFT',glow_as_shadow,'RIGHT',190,0)
target_glow:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT')
target_glow_colour:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT',220,0)
target_arrows:SetPoint('TOPLEFT',target_glow,'BOTTOMLEFT')

frame_glow_size:SetPoint('TOPLEFT',target_arrows,'BOTTOMLEFT',0,-20)
target_arrows_size:SetPoint('LEFT',frame_glow_size,'RIGHT',20,0)

target_arrows_size.enabled = function(p) return p.target_arrows end

local fade_rules_sep = general:CreateSeperator('fade_rules_sep')
local fade_alpha = general:CreateSlider('fade_alpha',0,1)
local fade_speed = general:CreateSlider('fade_speed',0,1)
local fade_all = general:CreateCheckBox('fade_all')
local fade_friendly_npc = general:CreateCheckBox('fade_friendly_npc')
local fade_neutral_enemy = general:CreateCheckBox('fade_neutral_enemy')
local fade_untracked = general:CreateCheckBox('fade_untracked')
local fade_avoid_nameonly = general:CreateCheckBox('fade_avoid_nameonly')
local fade_avoid_raidicon = general:CreateCheckBox('fade_avoid_raidicon')
local fade_avoid_execute_friend = general:CreateCheckBox('fade_avoid_execute_friend')
local fade_avoid_execute_hostile = general:CreateCheckBox('fade_avoid_execute_hostile')

fade_alpha:SetValueStep(.05)
fade_speed:SetValueStep(.05)

fade_rules_sep:SetPoint('TOP',0,-235)
fade_alpha:SetPoint('TOPLEFT',10,-260)

fade_speed:SetPoint('LEFT',fade_alpha,'RIGHT',20,0)
fade_all:SetPoint('TOPLEFT',15,-295)
fade_friendly_npc:SetPoint('LEFT',fade_all,'RIGHT',190,0)
fade_neutral_enemy:SetPoint('TOPLEFT',fade_all,'BOTTOMLEFT')
fade_untracked:SetPoint('LEFT',fade_neutral_enemy,'RIGHT',190,0)

fade_avoid_nameonly:SetPoint('TOPLEFT',fade_neutral_enemy,'BOTTOMLEFT',0,-20)
fade_avoid_raidicon:SetPoint('LEFT',fade_avoid_nameonly,'RIGHT',190,0)
fade_avoid_execute_friend:SetPoint('TOPLEFT',fade_avoid_nameonly,'BOTTOMLEFT')
fade_avoid_execute_hostile:SetPoint('LEFT',fade_avoid_execute_friend,'RIGHT',190,0)

target_glow_colour.enabled = function(p) return p.target_glow end

-- healthbars ##################################################################
local bar_texture = healthbars:CreateDropDown('bar_texture')
local bar_animation = healthbars:CreateDropDown('bar_animation')

local execute_sep = healthbars:CreateSeperator('execute_sep')
local execute_enabled = healthbars:CreateCheckBox('execute_enabled')
local execute_auto = healthbars:CreateCheckBox('execute_auto')
local execute_colour = healthbars:CreateColourPicker('execute_colour')
local execute_percent = healthbars:CreateSlider('execute_percent')

local colour_sep = healthbars:CreateSeperator('reaction_colour_sep')
local colour_hated = healthbars:CreateColourPicker('colour_hated')
local colour_neutral = healthbars:CreateColourPicker('colour_neutral')
local colour_friendly = healthbars:CreateColourPicker('colour_friendly')
local colour_tapped = healthbars:CreateColourPicker('colour_tapped')
local colour_player = healthbars:CreateColourPicker('colour_player')
local colour_self_class = healthbars:CreateCheckBox('colour_self_class')
local colour_self = healthbars:CreateColourPicker('colour_self')
local colour_enemy_class = healthbars:CreateCheckBox('colour_enemy_class')
local colour_enemy_player = healthbars:CreateColourPicker('colour_enemy_player')
local colour_enemy_pet = healthbars:CreateColourPicker('colour_enemy_pet')

bar_animation.SelectTable = {'None','Smooth','Cutaway'}

bar_texture:SetPoint('TOPLEFT',10,-10)
bar_animation:SetPoint('LEFT',bar_texture,'RIGHT',10,0)

execute_sep:SetPoint('TOP',0,-75)
execute_enabled:SetPoint('TOPLEFT',15,-90)
execute_colour:SetPoint('LEFT',execute_enabled,'RIGHT',190,0)
execute_auto:SetPoint('TOPLEFT',execute_enabled,'BOTTOMLEFT')
execute_percent:SetPoint('LEFT',execute_auto,'RIGHT',180,-5)

colour_sep:SetPoint('TOP',0,-175)
colour_hated:SetPoint('TOPLEFT',15,-190)
colour_neutral:SetPoint('LEFT',colour_hated,'RIGHT')
colour_friendly:SetPoint('LEFT',colour_neutral,'RIGHT')
colour_tapped:SetPoint('TOPLEFT',colour_hated,'BOTTOMLEFT')
colour_player:SetPoint('LEFT',colour_tapped,'RIGHT')

colour_enemy_class:SetPoint('TOPLEFT',colour_tapped,'BOTTOMLEFT',-4,-15)
colour_enemy_player:SetPoint('TOPLEFT',colour_enemy_class,'BOTTOMLEFT',4,0)
colour_enemy_pet:SetPoint('LEFT',colour_enemy_player,'RIGHT',0,0)

colour_self_class:SetPoint('TOPLEFT',colour_enemy_player,'BOTTOMLEFT',-4,-15)
colour_self:SetPoint('TOPLEFT',colour_self_class,'BOTTOMLEFT',4,0)

colour_self.enabled = function(p) return not p.colour_self_class end
colour_enemy_player.enabled = function(p) return not p.colour_enemy_class end

execute_auto.enabled = function(p) return p.execute_enabled end
execute_colour.enabled = function(p) return p.execute_enabled end
execute_percent.enabled = function(p) return p.execute_enabled and not p.execute_auto end

-- text ########################################################################
local font_face = text:CreateDropDown('font_face')
local font_style = text:CreateDropDown('font_style')
local font_size_normal = text:CreateSlider('font_size_normal',1,20)
local font_size_small = text:CreateSlider('font_size_small',1,20)
local name_text = text:CreateCheckBox('name_text')
local hidenamesCheck = text:CreateCheckBox('hide_names')
local level_text = text:CreateCheckBox('level_text')
local health_text = text:CreateCheckBox('health_text')
local text_vertical_offset = text:CreateSlider('text_vertical_offset',-20,20)
local name_vertical_offset = text:CreateSlider('name_vertical_offset',-20,20)
local bot_vertical_offset = text:CreateSlider('bot_vertical_offset',-20,20)

font_style.SelectTable = { 'None','Outline','Shadow','Shadow+Outline','Monochrome' }

text_vertical_offset:SetWidth(120)
text_vertical_offset:SetValueStep(.5)
name_vertical_offset:SetWidth(120)
name_vertical_offset:SetValueStep(.5)
bot_vertical_offset:SetWidth(120)
bot_vertical_offset:SetValueStep(.5)

bot_vertical_offset.enabled = function(p) return p.level_text or p.health_text end

font_face:SetPoint('TOPLEFT',10,-10)
font_style:SetPoint('LEFT',font_face,'RIGHT',10,0)

font_size_normal:SetPoint('TOPLEFT',10,-70)
font_size_small:SetPoint('LEFT',font_size_normal,'RIGHT',20,0)

text_vertical_offset:SetPoint('TOPLEFT',font_size_normal,'BOTTOMLEFT',0,-30)
name_vertical_offset:SetPoint('LEFT',text_vertical_offset,'RIGHT',20,0)
bot_vertical_offset:SetPoint('LEFT',name_vertical_offset,'RIGHT',20,0)

name_text:SetPoint('TOPLEFT',text_vertical_offset,'BOTTOMLEFT',0,-20)
hidenamesCheck:SetPoint('LEFT',name_text,'RIGHT',190,0)
level_text:SetPoint('TOPLEFT',name_text,'BOTTOMLEFT')
health_text:SetPoint('TOPLEFT',level_text,'BOTTOMLEFT')

hidenamesCheck.enabled = function(p) return p.name_text end

local health_text_SelectTable = {
    'Current |cff888888(145k)',
    'Maximum |cff888888(156k)',
    'Percent |cff888888(93)',
    'Deficit |cff888888(-10.9k)',
    'Blank |cff888888(  )'
}

local health_text_sep = text:CreateSeperator('health_text_sep')
local health_text_friend_max = text:CreateDropDown('health_text_friend_max')
local health_text_friend_dmg = text:CreateDropDown('health_text_friend_dmg')
local health_text_hostile_max = text:CreateDropDown('health_text_hostile_max')
local health_text_hostile_dmg = text:CreateDropDown('health_text_hostile_dmg')

health_text_friend_max.SelectTable = health_text_SelectTable
health_text_friend_dmg.SelectTable = health_text_SelectTable
health_text_hostile_max.SelectTable = health_text_SelectTable
health_text_hostile_dmg.SelectTable = health_text_SelectTable

health_text_sep:SetPoint('TOP',0,-250)
health_text_friend_max:SetPoint('TOPLEFT',10,-270)
health_text_friend_dmg:SetPoint('LEFT',health_text_friend_max,'RIGHT',10,0)
health_text_hostile_max:SetPoint('TOPLEFT',health_text_friend_max,'BOTTOMLEFT',0,0)
health_text_hostile_dmg:SetPoint('LEFT',health_text_hostile_max,'RIGHT',10,0)

health_text_friend_max.enabled = function(p) return p.health_text end
health_text_friend_dmg.enabled = health_text_friend_max.enabled
health_text_hostile_max.enabled = health_text_friend_max.enabled
health_text_hostile_dmg.enabled = health_text_friend_max.enabled

-- nameonly ####################################################################
local nameonlyCheck = nameonly:CreateCheckBox('nameonly')
local nameonly_no_font_style = nameonly:CreateCheckBox('nameonly_no_font_style')
local nameonly_damaged_friends = nameonly:CreateCheckBox('nameonly_damaged_friends')
local nameonly_enemies = nameonly:CreateCheckBox('nameonly_enemies')
local nameonly_all_enemies = nameonly:CreateCheckBox('nameonly_all_enemies')
local nameonly_target = nameonly:CreateCheckBox('nameonly_target')
local guild_text_players = nameonly:CreateCheckBox('guild_text_players')
local title_text_players = nameonly:CreateCheckBox('title_text_players')

nameonly_no_font_style.enabled = function(p) return p.nameonly end
nameonly_enemies.enabled = function(p) return p.nameonly and not p.nameonly_all_enemies end
nameonly_damaged_friends.enabled = nameonly_no_font_style.enabled
nameonly_all_enemies.enabled = nameonly_no_font_style.enabled
nameonly_target.enabled = nameonly_no_font_style.enabled
guild_text_players.enabled = nameonly_no_font_style.enabled
title_text_players.enabled = nameonly_no_font_style.enabled

nameonlyCheck:SetPoint('TOPLEFT',10,-10)
nameonly_no_font_style:SetPoint('LEFT',nameonlyCheck,'RIGHT',190,0)

nameonly_target:SetPoint('TOPLEFT',nameonlyCheck,'BOTTOMLEFT',0,-20)
nameonly_all_enemies:SetPoint('TOPLEFT',nameonly_target,'BOTTOMLEFT')
nameonly_enemies:SetPoint('LEFT',nameonly_all_enemies,'RIGHT',190,0)
nameonly_damaged_friends:SetPoint('TOPLEFT',nameonly_all_enemies,'BOTTOMLEFT')

guild_text_players:SetPoint('TOPLEFT',nameonly_damaged_friends,'BOTTOMLEFT',0,-20)
title_text_players:SetPoint('LEFT',guild_text_players,'RIGHT',190,0)

-- frame sizes #################################################################
local frame_width = framesizes:CreateSlider('frame_width',20,200)
local frame_height = framesizes:CreateSlider('frame_height',3,40)
local frame_width_minus = framesizes:CreateSlider('frame_width_minus',20,200)
local frame_height_minus = framesizes:CreateSlider('frame_height_minus',3,40)
local frame_width_personal = framesizes:CreateSlider('frame_width_personal',20,200)
local frame_height_personal = framesizes:CreateSlider('frame_height_personal',3,40)
local castbar_height = framesizes:CreateSlider('castbar_height',3,20)
local powerbar_height = framesizes:CreateSlider('powerbar_height',1,20)

frame_width:SetPoint('TOPLEFT',10,-30)
frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
frame_width_personal:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-30)
frame_height_personal:SetPoint('LEFT',frame_width_personal,'RIGHT',20,0)
frame_width_minus:SetPoint('TOPLEFT',frame_width_personal,'BOTTOMLEFT',0,-30)
frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)
castbar_height:SetPoint('TOPLEFT',frame_width_minus,'BOTTOMLEFT',0,-60)
powerbar_height:SetPoint('LEFT',castbar_height,'RIGHT',20,0)

-- auras #######################################################################
local auras_enabled = auras:CreateCheckBox('auras_enabled')
local auras_on_personal = auras:CreateCheckBox('auras_on_personal')
local auras_sort = auras:CreateDropDown('auras_sort')
local auras_whitelist = auras:CreateCheckBox('auras_whitelist')
local auras_pulsate = auras:CreateCheckBox('auras_pulsate')
local auras_centre = auras:CreateCheckBox('auras_centre')
local auras_time_threshold = auras:CreateSlider('auras_time_threshold',-1,180)

auras_sort.SelectTable = {'Aura index','Time remaining'}

local auras_filtering_sep = auras:CreateSeperator('auras_filtering_sep')
local auras_minimum_length = auras:CreateSlider('auras_minimum_length',0,60)
local auras_maximum_length = auras:CreateSlider('auras_maximum_length',-1,1800)

local auras_icons_sep = auras:CreateSeperator('auras_icons_sep')
local auras_icon_normal_size = auras:CreateSlider('auras_icon_normal_size',10,50)
local auras_icon_minus_size = auras:CreateSlider('auras_icon_minus_size',10,50)
local auras_icon_squareness = auras:CreateSlider('auras_icon_squareness',0.5,1)

auras_icon_squareness:SetValueStep(.1)

auras_enabled:SetPoint('TOPLEFT',10,-17)
auras_on_personal:SetPoint('TOPLEFT',auras_enabled,'BOTTOMLEFT')
auras_whitelist:SetPoint('TOPLEFT',auras_on_personal,'BOTTOMLEFT')
auras_pulsate:SetPoint('TOPLEFT',auras_whitelist,'BOTTOMLEFT')
auras_centre:SetPoint('TOPLEFT',auras_pulsate,'BOTTOMLEFT')
auras_sort:SetPoint('LEFT',auras_enabled,'RIGHT',184,0)
auras_time_threshold:SetPoint('LEFT',auras_whitelist,'RIGHT',184,5)

auras_filtering_sep:SetPoint('TOP',0,-170)
auras_minimum_length:SetPoint('TOPLEFT',10,-200)
auras_maximum_length:SetPoint('LEFT',auras_minimum_length,'RIGHT',20,0)

auras_icons_sep:SetPoint('TOP',0,-250)
auras_icon_normal_size:SetPoint('TOPLEFT',10,-280)
auras_icon_minus_size:SetPoint('LEFT',auras_icon_normal_size,'RIGHT',20,0)
auras_icon_squareness:SetPoint('TOPLEFT',auras_icon_normal_size,'BOTTOMLEFT',0,-30)

-- cast bars ###################################################################
local castbar_enable = castbars:CreateCheckBox('castbar_enable')
local castbar_colour = castbars:CreateColourPicker('castbar_colour')
local castbar_unin_colour = castbars:CreateColourPicker('castbar_unin_colour')
local castbar_personal = castbars:CreateCheckBox('castbar_showpersonal')
local castbar_icon = castbars:CreateCheckBox('castbar_icon')
local castbar_name = castbars:CreateCheckBox('castbar_name')
local castbar_all = castbars:CreateCheckBox('castbar_showall')
local castbar_friend = castbars:CreateCheckBox('castbar_showfriend')
local castbar_enemy = castbars:CreateCheckBox('castbar_showenemy')

castbar_enable:SetPoint('TOPLEFT',10,-10)
castbar_colour:SetPoint('LEFT',castbar_enable,220,0)
castbar_unin_colour:SetPoint('LEFT',castbar_personal,220,0)
castbar_personal:SetPoint('TOPLEFT',castbar_enable,'BOTTOMLEFT')
castbar_icon:SetPoint('TOPLEFT',castbar_personal,'BOTTOMLEFT')
castbar_name:SetPoint('TOPLEFT',castbar_icon,'BOTTOMLEFT')
castbar_all:SetPoint('TOPLEFT',castbar_name,'BOTTOMLEFT')
castbar_friend:SetPoint('TOPLEFT',castbar_all,'BOTTOMLEFT')
castbar_enemy:SetPoint('TOPLEFT',castbar_friend,'BOTTOMLEFT')

castbar_colour.enabled = function(p) return p.castbar_enable end
castbar_unin_colour.enabled = function(p) return p.castbar_enable end
castbar_personal.enabled = function(p) return p.castbar_enable end
castbar_icon.enabled = function(p) return p.castbar_enable end
castbar_name.enabled = function(p) return p.castbar_enable end
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
tankmode_force_enable:SetPoint('LEFT',tankmodeCheck,'RIGHT',190,0)
threatbracketsCheck:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT')

tankmode_colour_sep:SetPoint('TOP',0,-100)
tankmode_tank_colour:SetPoint('TOPLEFT',15,-120)
tankmode_trans_colour:SetPoint('LEFT',tankmode_tank_colour,'RIGHT')
tankmode_other_colour:SetPoint('LEFT',tankmode_trans_colour,'RIGHT')

-- classpowers #################################################################
local classpowers_enable = classpowers:CreateCheckBox('classpowers_enable')
local classpowers_on_target = classpowers:CreateCheckBox('classpowers_on_target')
local classpowers_size = classpowers:CreateSlider('classpowers_size',5,20)
local classpowers_bar_width = classpowers:CreateSlider('classpowers_bar_width',10,100)
local classpowers_bar_height = classpowers:CreateSlider('classpowers_bar_height',1,11)
local classpowers_colour = classpowers:CreateColourPicker('classpowers_colour')
local classpowers_colour_overflow = classpowers:CreateColourPicker('classpowers_colour_overflow')
local classpowers_colour_inactive = classpowers:CreateColourPicker('classpowers_colour_inactive')

classpowers_bar_width:SetValueStep(2)
classpowers_bar_height:SetValueStep(2)

classpowers_enable:SetPoint('TOPLEFT',10,-10)
classpowers_on_target:SetPoint('LEFT',classpowers_enable,'RIGHT',190,0)
classpowers_size:SetPoint('TOPLEFT',classpowers_enable,'BOTTOMLEFT',0,-20)
classpowers_bar_width:SetPoint('TOPLEFT',classpowers_size,'BOTTOMLEFT',0,-30)
classpowers_bar_height:SetPoint('LEFT',classpowers_bar_width,'RIGHT',20,0)

classpowers_colour:SetPoint('TOPLEFT',15,-150)
classpowers_colour_overflow:SetPoint('TOPLEFT',classpowers_colour,'BOTTOMLEFT')
classpowers_colour_inactive:SetPoint('TOPLEFT',classpowers_colour_overflow,'BOTTOMLEFT')

function classpowers_colour:Get()
    local class = select(2,UnitClass('player'))
    self.env = 'classpowers_colour_'..strlower(class)

    if opt.profile[self.env] then
        self.block:SetBackdropColor(unpack(opt.profile[self.env]))
    else
        self.block:SetBackdropColor(.5,.5,.5)
        self:Disable()
    end
end
function classpowers_colour:Set(col)
    opt.config:SetConfig(self.env,col)
    -- manually re-run OnShow since our env doesn't match the element name
    self:Hide()
    self:Show()
end
classpowers_colour:SetScript('OnEnter',function(self)
    -- force tooltip to use classpowers_colour env
    GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
    GameTooltip:SetWidth(200)
    GameTooltip:AddLine(opt.titles['classpowers_colour'])
    GameTooltip:AddLine(opt.tooltips['classpowers_colour'],1,1,1,true)
    GameTooltip:Show()
end)

-- LSM dropdowns ###############################################################
function bar_texture:initialize()
    local list = {}
    for k,f in ipairs(LSM:List(LSM.MediaType.STATUSBAR)) do
        tinsert(list,{
            text = f,
            value = f,
            selected = f == opt.profile[self.env]
        })
    end

    self:SetList(list)
    self:SetValue(opt.profile[self.env])
end
function bar_texture:OnListButtonChanged(button,item)
    local texture = LSM:Fetch(LSM.MediaType.STATUSBAR,item.value)
    button:SetBackdrop({bgFile=texture})
    button.label:SetFont('fonts/frizqt__.ttf',10,'OUTLINE')
end
function font_face:initialize()
    local list = {}
    for k,f in ipairs(LSM:List(LSM.MediaType.FONT)) do
        tinsert(list,{
            text = f,
            value = f,
            selected = f == opt.profile[self.env]
        })
    end

    self:SetList(list)
    self:SetValue(opt.profile[self.env])
end
function font_face:OnListButtonChanged(button,item)
    local font = LSM:Fetch(LSM.MediaType.FONT,item.value)
    button.label:SetFont(font,12)
end
