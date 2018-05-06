local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local LSM = LibStub('LibSharedMedia-3.0')
local L = opt:GetLocale()

local version = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
version:SetTextColor(.5,.5,.5)
version:SetPoint('TOPRIGHT',-12,-10)
version:SetText(string.format(
    L.titles.version,
    'KuiNameplates','Kesava','@project-version@'
))

opt:Initialise()
-- create pages ################################################################
local general     = opt:CreateConfigPage('general')
local fade_rules  = opt:CreateConfigPage('fade_rules')
local healthbars  = opt:CreateConfigPage('healthbars')
local castbars    = opt:CreateConfigPage('castbars')
local text        = opt:CreateConfigPage('text')
local nameonly    = opt:CreateConfigPage('nameonly')
local framesizes  = opt:CreateConfigPage('framesizes')
local auras       = opt:CreateConfigPage('auras')
local threat      = opt:CreateConfigPage('threat')
local classpowers = opt:CreateConfigPage('classpowers')
local bossmod     = opt:CreateConfigPage('bossmod')
local cvars       = opt:CreateConfigPage('cvars')

-- show inital page
opt.pages[1]:ShowPage()

-- create elements #############################################################
-- general #####################################################################
function general:Initialise()
    local combat_hostile = self:CreateDropDown('combat_hostile')
    local combat_friendly = self:CreateDropDown('combat_friendly')
    local ignore_uiscale = self:CreateCheckBox('ignore_uiscale')
    local use_blizzard_personal = self:CreateCheckBox('use_blizzard_personal')
    local glow_as_shadow = self:CreateCheckBox('glow_as_shadow')
    local state_icons = self:CreateCheckBox('state_icons')
    local target_glow = self:CreateCheckBox('target_glow')
    local target_glow_colour = self:CreateColourPicker('target_glow_colour')
    local target_arrows = self:CreateCheckBox('target_arrows')
    local frame_glow_size = self:CreateSlider('frame_glow_size',4,16)
    local target_arrows_size = self:CreateSlider('target_arrows_size',20,60)

    target_glow_colour.enabled = function(p) return p.target_glow end

    combat_hostile.SelectTable = {
        L.titles.dd_combat_toggle_nothing,
        L.titles.dd_combat_toggle_hide,
        L.titles.dd_combat_toggle_show,
    }
    combat_friendly.SelectTable = combat_hostile.SelectTable

    combat_hostile:SetPoint('TOPLEFT',10,-10)
    combat_friendly:SetPoint('LEFT',combat_hostile,'RIGHT',10,0)

    ignore_uiscale:SetPoint('TOPLEFT',10,-55)
    use_blizzard_personal:SetPoint('LEFT',ignore_uiscale,'RIGHT',190,0)

    target_glow:SetPoint('TOPLEFT',ignore_uiscale,'BOTTOMLEFT',0,-10)
    target_glow_colour:SetPoint('TOPLEFT',target_glow,'BOTTOMLEFT',4,0)
    glow_as_shadow:SetPoint('TOPLEFT',target_glow_colour,'BOTTOMLEFT',-4,0)
    state_icons:SetPoint('LEFT',target_glow,'RIGHT',190,0)
    target_arrows:SetPoint('LEFT',glow_as_shadow,'RIGHT',190,0)

    frame_glow_size:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT',0,-20)
    target_arrows_size:SetPoint('LEFT',frame_glow_size,'RIGHT',20,0)

    target_arrows_size.enabled = function(p) return p.target_arrows end

    local clickthrough_sep = self:CreateSeparator('clickthrough_sep')
    local clickthrough_self = self:CreateCheckBox('clickthrough_self')
    local clickthrough_friend = self:CreateCheckBox('clickthrough_friend')
    local clickthrough_enemy = self:CreateCheckBox('clickthrough_enemy')

    clickthrough_sep:SetPoint('TOP',0,-250)
    clickthrough_self:SetPoint('TOPLEFT',10,-(250+10))
    clickthrough_friend:SetPoint('TOPLEFT',(10+155),-(250+10))
    clickthrough_enemy:SetPoint('TOPLEFT',(10+155*2),-(250+10))
end
-- fade rules popup ############################################################
function fade_rules:Initialise()
    local nt_alpha = self:CreateSlider('fade_non_target_alpha',0,1)
    local cond_alpha = self:CreateSlider('fade_conditional_alpha',0,1)
    local fade_speed = self:CreateSlider('fade_speed',0,1)
    local fade_all = self:CreateCheckBox('fade_all')
    local fade_fnpc = self:CreateCheckBox('fade_friendly_npc')
    local fade_ne = self:CreateCheckBox('fade_neutral_enemy')
    local fade_ut = self:CreateCheckBox('fade_untracked')
    local avoid_no = self:CreateCheckBox('fade_avoid_nameonly')
    local avoid_ri = self:CreateCheckBox('fade_avoid_raidicon')
    local avoid_xf = self:CreateCheckBox('fade_avoid_execute_friend')
    local avoid_xh = self:CreateCheckBox('fade_avoid_execute_hostile')
    local avoid_t = self:CreateCheckBox('fade_avoid_tracked')
    local avoid_cf = self:CreateCheckBox('fade_avoid_casting_friendly')
    local avoid_ch = self:CreateCheckBox('fade_avoid_casting_hostile')
    local avoid_ci = self:CreateCheckBox('fade_avoid_casting_interruptible',true)
    local avoid_cu = self:CreateCheckBox('fade_avoid_casting_uninterruptible',true)

    avoid_ci.enabled = function(p) return p.fade_avoid_casting_friendly or p.fade_avoid_casting_hostile end
    avoid_cu.enabled = avoid_ci.enabled

    nt_alpha:SetWidth(120)
    nt_alpha:SetValueStep(.05)
    cond_alpha:SetWidth(120)
    cond_alpha:SetValueStep(.05)
    fade_speed:SetWidth(120)
    fade_speed:SetValueStep(.05)

    nt_alpha:SetPoint('TOPLEFT',10,-20)
    cond_alpha:SetPoint('LEFT',nt_alpha,'RIGHT',20,0)
    fade_speed:SetPoint('LEFT',cond_alpha,'RIGHT',20,0)

    fade_all:SetPoint('TOPLEFT',10,-60)
    fade_fnpc:SetPoint('LEFT',fade_all,'RIGHT',190,0)
    fade_ne:SetPoint('TOPLEFT',fade_all,'BOTTOMLEFT')
    fade_ut:SetPoint('LEFT',fade_ne,'RIGHT',190,0)

    avoid_no:SetPoint('TOPLEFT',fade_ne,'BOTTOMLEFT',0,-10)
    avoid_ri:SetPoint('LEFT',avoid_no,'RIGHT',190,0)
    avoid_xf:SetPoint('TOPLEFT',avoid_no,'BOTTOMLEFT')
    avoid_xh:SetPoint('LEFT',avoid_xf,'RIGHT',190,0)
    avoid_t:SetPoint('TOPLEFT',avoid_xf,'BOTTOMLEFT')

    avoid_cf:SetPoint('TOPLEFT',avoid_t,'BOTTOMLEFT',0,-10)
    avoid_ch:SetPoint('LEFT',avoid_cf,'RIGHT',190,0)
    avoid_ci:SetPoint('TOPLEFT',avoid_cf,'BOTTOMLEFT',10,0)
    avoid_cu:SetPoint('TOPLEFT',avoid_ci,'BOTTOMLEFT')
end
-- healthbars ##################################################################
function healthbars:Initialise()
    local bar_texture = self:CreateDropDown('bar_texture')
    local bar_animation = self:CreateDropDown('bar_animation')
    local absorb_enable = self:CreateCheckBox('absorb_enable')
    local absorb_striped = self:CreateCheckBox('absorb_striped')

    local execute_sep = self:CreateSeparator('execute_sep')
    local execute_enabled = self:CreateCheckBox('execute_enabled')
    local execute_auto = self:CreateCheckBox('execute_auto')
    local execute_colour = self:CreateColourPicker('execute_colour')
    local execute_percent = self:CreateSlider('execute_percent')

    local colour_sep = self:CreateSeparator('reaction_colour_sep')
    local colour_hated = self:CreateColourPicker('colour_hated')
    local colour_neutral = self:CreateColourPicker('colour_neutral')
    local colour_friendly = self:CreateColourPicker('colour_friendly')
    local colour_friendly_pet = self:CreateColourPicker('colour_friendly_pet')
    local colour_tapped = self:CreateColourPicker('colour_tapped')
    local colour_absorb = self:CreateColourPicker('colour_absorb')
    local colour_player_class = self:CreateCheckBox('colour_player_class')
    local colour_player = self:CreateColourPicker('colour_player')
    local colour_self_class = self:CreateCheckBox('colour_self_class')
    local colour_self = self:CreateColourPicker('colour_self')
    local colour_enemy_class = self:CreateCheckBox('colour_enemy_class')
    local colour_enemy_player = self:CreateColourPicker('colour_enemy_player')
    local colour_enemy_pet = self:CreateColourPicker('colour_enemy_pet')

    bar_animation.SelectTable = {
        L.titles.dd_font_style_none,
        L.titles.dd_bar_animation_smooth,
        L.titles.dd_bar_animation_cutaway
    }

    bar_texture:SetPoint('TOPLEFT',10,-10)
    bar_animation:SetPoint('LEFT',bar_texture,'RIGHT',10,0)
    absorb_enable:SetPoint('TOPLEFT',bar_texture,'BOTTOMLEFT',0,-5)
    absorb_striped:SetPoint('LEFT',absorb_enable,'RIGHT',190,0)

    execute_sep:SetPoint('TOP',0,-105)
    execute_enabled:SetPoint('TOPLEFT',15,-120)
    execute_colour:SetPoint('LEFT',execute_enabled,'RIGHT',190,0)
    execute_auto:SetPoint('TOPLEFT',execute_enabled,'BOTTOMLEFT',0,-5)
    execute_percent:SetPoint('LEFT',execute_auto,'RIGHT',180,-5)

    colour_sep:SetPoint('TOP',0,-215)
    colour_hated:SetPoint('TOPLEFT',15,-230)
    colour_neutral:SetPoint('LEFT',colour_hated,'RIGHT')
    colour_friendly:SetPoint('LEFT',colour_neutral,'RIGHT')
    colour_tapped:SetPoint('TOPLEFT',colour_hated,'BOTTOMLEFT')
    colour_absorb:SetPoint('LEFT',colour_tapped,'RIGHT')

    colour_player_class:SetPoint('TOPLEFT',colour_tapped,'BOTTOMLEFT',-4,-15)
    colour_player:SetPoint('TOPLEFT',colour_player_class,'BOTTOMLEFT',4,0)
    colour_friendly_pet:SetPoint('LEFT',colour_player,'RIGHT',0,0)

    colour_enemy_class:SetPoint('TOPLEFT',colour_player,'BOTTOMLEFT',-4,-15)
    colour_enemy_player:SetPoint('TOPLEFT',colour_enemy_class,'BOTTOMLEFT',4,0)
    colour_enemy_pet:SetPoint('LEFT',colour_enemy_player,'RIGHT',0,0)

    colour_self_class:SetPoint('TOPLEFT',colour_enemy_player,'BOTTOMLEFT',-4,-15)
    colour_self:SetPoint('TOPLEFT',colour_self_class,'BOTTOMLEFT',4,0)

    absorb_striped.enabled = function(p) return p.absorb_enable end
    colour_absorb.enabled = function(p) return p.absorb_enable end

    colour_self.enabled = function(p) return not p.colour_self_class end
    colour_player.enabled = function(p) return not p.colour_player_class end
    colour_enemy_player.enabled = function(p) return not p.colour_enemy_class end

    execute_auto.enabled = function(p) return p.execute_enabled end
    execute_colour.enabled = execute_auto.enabled
    execute_percent.enabled = function(p) return p.execute_enabled and not p.execute_auto end

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
end
-- text ########################################################################
function text:Initialise()
    local font_face = self:CreateDropDown('font_face')
    local font_style = self:CreateDropDown('font_style')
    local font_size_normal = self:CreateSlider('font_size_normal',1,20)
    local font_size_small = self:CreateSlider('font_size_small',1,20)
    local name_text = self:CreateCheckBox('name_text')
    local hidenamesCheck = self:CreateCheckBox('hide_names',true)
    local level_text = self:CreateCheckBox('level_text')
    local health_text = self:CreateCheckBox('health_text')
    local text_vertical_offset = self:CreateSlider('text_vertical_offset',-20,20)
    local name_vertical_offset = self:CreateSlider('name_vertical_offset',-20,20)
    local bot_vertical_offset = self:CreateSlider('bot_vertical_offset',-20,20)

    font_style.SelectTable = {
        L.titles.dd_font_style_none,
        L.titles.dd_font_style_outline,
        L.titles.dd_font_style_shadow,
        L.titles.dd_font_style_shadowandoutline,
        L.titles.dd_font_style_monochrome,
    }

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
    hidenamesCheck:SetPoint('TOPLEFT',name_text,'BOTTOMLEFT',10,0)

    level_text:SetPoint('LEFT',name_text,'RIGHT',190,0)
    health_text:SetPoint('TOPLEFT',level_text,'BOTTOMLEFT')

    hidenamesCheck.enabled = function(p) return p.name_text end

    local health_text_SelectTable = {
        L.titles.dd_health_text_blank..' |cff888888(  )',
        L.titles.dd_health_text_current..' |cff888888(145k)',
        L.titles.dd_health_text_maximum..' |cff888888(156k)',
        L.titles.dd_health_text_percent..' |cff888888(93)',
        L.titles.dd_health_text_deficit..' |cff888888(-10.9k)',
        L.titles.dd_health_text_current_percent..' |cff888888(145k  93%)',
        L.titles.dd_health_text_current_deficit..' |cff888888(145k  -10.9k)',
    }

    local health_text_sep = text:CreateSeparator('health_text_sep')
    local health_text_friend_max = text:CreateDropDown('health_text_friend_max')
    local health_text_friend_dmg = text:CreateDropDown('health_text_friend_dmg')
    local health_text_hostile_max = text:CreateDropDown('health_text_hostile_max')
    local health_text_hostile_dmg = text:CreateDropDown('health_text_hostile_dmg')

    health_text_friend_max.SelectTable = health_text_SelectTable
    health_text_friend_dmg.SelectTable = health_text_SelectTable
    health_text_hostile_max.SelectTable = health_text_SelectTable
    health_text_hostile_dmg.SelectTable = health_text_SelectTable

    health_text_sep:SetPoint('TOP',0,-230)
    health_text_friend_max:SetPoint('TOP',health_text_sep,'BOTTOM',0,-10)
    health_text_friend_max:SetPoint('LEFT',10,0)
    health_text_friend_dmg:SetPoint('LEFT',health_text_friend_max,'RIGHT',10,0)
    health_text_hostile_max:SetPoint('TOPLEFT',health_text_friend_max,'BOTTOMLEFT',0,0)
    health_text_hostile_dmg:SetPoint('LEFT',health_text_hostile_max,'RIGHT',10,0)

    health_text_friend_max.enabled = function(p) return p.health_text end
    health_text_friend_dmg.enabled = health_text_friend_max.enabled
    health_text_hostile_max.enabled = health_text_friend_max.enabled
    health_text_hostile_dmg.enabled = health_text_friend_max.enabled

    local nc_sep = self:CreateSeparator('name_colour_sep')
    local nc_wb = self:CreateCheckBox('name_colour_white_in_bar_mode')
    local nc_cf = self:CreateCheckBox('class_colour_friendly_names')
    local nc_ch = self:CreateCheckBox('class_colour_enemy_names')
    local nc_pf = self:CreateColourPicker('name_colour_player_friendly')
    local nc_ph = self:CreateColourPicker('name_colour_player_hostile')
    local nc_nf = self:CreateColourPicker('name_colour_npc_friendly')
    local nc_nn = self:CreateColourPicker('name_colour_npc_neutral')
    local nc_nh = self:CreateColourPicker('name_colour_npc_hostile')

    nc_wb.enabled = function(p) return p.name_text end
    nc_cf.enabled = nc_wb.enabled
    nc_ch.enabled = nc_wb.enabled
    nc_pf.enabled = nc_wb.enabled
    nc_ph.enabled = nc_wb.enabled
    nc_nf.enabled = nc_wb.enabled
    nc_nn.enabled = nc_wb.enabled
    nc_nh.enabled = nc_wb.enabled
    nc_pf.enabled = function(p)
        return p.name_text and not p.class_colour_friendly_names
    end
    nc_ph.enabled = function(p)
        return p.name_text and not p.class_colour_enemy_names
    end

    nc_sep:SetPoint('TOP',0,-350)
    nc_wb:SetPoint('TOP',nc_sep,'BOTTOM',0,-10)
    nc_wb:SetPoint('LEFT',10,0)
    nc_nh:SetPoint('TOPLEFT',nc_wb,'BOTTOMLEFT',4,0)
    nc_nn:SetPoint('LEFT',nc_nh,'RIGHT',0,0)
    nc_nf:SetPoint('LEFT',nc_nn,'RIGHT',0,0)
    nc_cf:SetPoint('TOPLEFT',nc_nh,'BOTTOMLEFT',-4,-5)
    nc_ch:SetPoint('LEFT',nc_cf,'RIGHT',190,0)
    nc_pf:SetPoint('TOPLEFT',nc_cf,'BOTTOMLEFT',4,0)
    nc_ph:SetPoint('TOPLEFT',nc_ch,'BOTTOMLEFT',4,0)

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
end
-- nameonly ####################################################################
function nameonly:Initialise()
    local nameonlyCheck = self:CreateCheckBox('nameonly')
    local nameonly_no_font_style = self:CreateCheckBox('nameonly_no_font_style')
    local nameonly_health_colour = self:CreateCheckBox('nameonly_health_colour')
    local nameonly_damaged_friends = self:CreateCheckBox('nameonly_damaged_friends')
    local nameonly_enemies = self:CreateCheckBox('nameonly_enemies',true)
    local nameonly_neutral = self:CreateCheckBox('nameonly_neutral',true)
    local nameonly_in_combat = self:CreateCheckBox('nameonly_in_combat')
    local nameonly_all_enemies = self:CreateCheckBox('nameonly_all_enemies')
    local nameonly_target = self:CreateCheckBox('nameonly_target')
    local guild_text_npcs = self:CreateCheckBox('guild_text_npcs')
    local guild_text_players = self:CreateCheckBox('guild_text_players')
    local title_text_players = self:CreateCheckBox('title_text_players')
    local vis_sep = self:CreateSeparator('nameonly_visibility_sep')
    local text_sep = self:CreateSeparator('nameonly_text_sep')

    nameonly_no_font_style.enabled = function(p) return p.nameonly end
    nameonly_health_colour.enabled = nameonly_no_font_style.enabled
    nameonly_enemies.enabled = function(p) return p.nameonly and not p.nameonly_all_enemies end
    nameonly_neutral.enabled = nameonly_enemies.enabled
    nameonly_damaged_friends.enabled = nameonly_no_font_style.enabled
    nameonly_all_enemies.enabled = nameonly_no_font_style.enabled
    nameonly_target.enabled = nameonly_no_font_style.enabled
    nameonly_in_combat.enabled = nameonly_no_font_style.enabled
    guild_text_npcs.enabled = nameonly_no_font_style.enabled
    guild_text_players.enabled = nameonly_no_font_style.enabled
    title_text_players.enabled = nameonly_no_font_style.enabled

    nameonlyCheck:SetPoint('TOPLEFT',10,-10)

    vis_sep:SetPoint('TOP',0,-65)
    nameonly_target:SetPoint('TOPLEFT',10,-75)
    nameonly_damaged_friends:SetPoint('TOPLEFT',nameonly_target,'BOTTOMLEFT')
    nameonly_in_combat:SetPoint('TOPLEFT',nameonly_damaged_friends,'BOTTOMLEFT')
    nameonly_all_enemies:SetPoint('LEFT',nameonly_target,'RIGHT',190,0)
    nameonly_enemies:SetPoint('TOPLEFT',nameonly_all_enemies,'BOTTOMLEFT',10,0)
    nameonly_neutral:SetPoint('TOPLEFT',nameonly_enemies,'BOTTOMLEFT')

    text_sep:SetPoint('TOP',0,-183)
    nameonly_health_colour:SetPoint('TOPLEFT',nameonly_in_combat,'BOTTOMLEFT',0,-40)
    nameonly_no_font_style:SetPoint('LEFT',nameonly_health_colour,'RIGHT',190,0)
    guild_text_players:SetPoint('TOPLEFT',nameonly_health_colour,'BOTTOMLEFT')
    title_text_players:SetPoint('LEFT',guild_text_players,'RIGHT',190,0)
    guild_text_npcs:SetPoint('TOPLEFT',guild_text_players,'BOTTOMLEFT')
end
-- frame sizes #################################################################
function framesizes:Initialise()
    local frame_width = self:CreateSlider('frame_width',20,200)
    local frame_height = self:CreateSlider('frame_height',3,40)
    local frame_width_minus = self:CreateSlider('frame_width_minus',20,200)
    local frame_height_minus = self:CreateSlider('frame_height_minus',3,40)
    local frame_width_personal = self:CreateSlider('frame_width_personal',20,200)
    local frame_height_personal = self:CreateSlider('frame_height_personal',3,40)
    local powerbar_height = self:CreateSlider('powerbar_height',1,20)

    frame_width:SetPoint('TOPLEFT',10,-30)
    frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
    frame_width_personal:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-30)
    frame_height_personal:SetPoint('LEFT',frame_width_personal,'RIGHT',20,0)
    frame_width_minus:SetPoint('TOPLEFT',frame_width_personal,'BOTTOMLEFT',0,-30)
    frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)
    powerbar_height:SetPoint('TOPLEFT',frame_width_minus,'BOTTOMLEFT',0,-60)
end
-- auras #######################################################################
function auras:Initialise()
    local auras_enabled = self:CreateCheckBox('auras_enabled')
    local auras_on_personal = self:CreateCheckBox('auras_on_personal')
    local auras_sort = self:CreateDropDown('auras_sort')
    local auras_pulsate = self:CreateCheckBox('auras_pulsate')
    local auras_centre = self:CreateCheckBox('auras_centre')
    local auras_show_all_self = self:CreateCheckBox('auras_show_all_self')
    local auras_hide_all_other = self:CreateCheckBox('auras_hide_all_other')
    local auras_time_threshold = self:CreateSlider('auras_time_threshold',-1,180)

    auras_sort.SelectTable = {
        L.titles.dd_auras_sort_index,
        L.titles.dd_auras_sort_time,
    }

    local auras_kslc_hint = self:CreateFontString(nil,'ARTWORK','GameFontHighlight')
    auras_kslc_hint:SetTextColor(.7,.7,.7)
    auras_kslc_hint:SetWidth(350)
    auras_kslc_hint:SetText(L.titles['auras_kslc_hint'] or 'Text')

    local auras_filtering_sep = self:CreateSeparator('auras_filtering_sep')
    local auras_minimum_length = self:CreateSlider('auras_minimum_length',0,60)
    local auras_maximum_length = self:CreateSlider('auras_maximum_length',-1,1800)

    local auras_icons_sep = self:CreateSeparator('auras_icons_sep')
    local auras_icon_normal_size = self:CreateSlider('auras_icon_normal_size',10,50)
    local auras_icon_minus_size = self:CreateSlider('auras_icon_minus_size',10,50)
    local auras_icon_squareness = self:CreateSlider('auras_icon_squareness',0.5,1)

    auras_icon_squareness:SetValueStep(.1)

    auras_enabled:SetPoint('TOPLEFT',10,-17)
    auras_on_personal:SetPoint('TOPLEFT',auras_enabled,'BOTTOMLEFT')
    auras_show_all_self:SetPoint('TOPLEFT',auras_on_personal,'BOTTOMLEFT')
    auras_hide_all_other:SetPoint('TOPLEFT',auras_show_all_self,'BOTTOMLEFT')
    auras_pulsate:SetPoint('TOPLEFT',auras_hide_all_other,'BOTTOMLEFT')
    auras_centre:SetPoint('TOPLEFT',auras_pulsate,'BOTTOMLEFT')
    auras_sort:SetPoint('LEFT',auras_enabled,'RIGHT',184,0)
    auras_time_threshold:SetPoint('LEFT',auras_show_all_self,'RIGHT',184,5)
    auras_kslc_hint:SetPoint('TOP',0,-190)

    auras_filtering_sep:SetPoint('TOP',auras_kslc_hint,'BOTTOM',0,-35)
    auras_minimum_length:SetPoint('TOPLEFT',auras_filtering_sep,0,-30)
    auras_maximum_length:SetPoint('LEFT',auras_minimum_length,'RIGHT',20,0)

    auras_icons_sep:SetPoint('TOP',auras_filtering_sep,'BOTTOM',0,-90)
    auras_icon_normal_size:SetPoint('TOPLEFT',auras_icons_sep,0,-30)
    auras_icon_minus_size:SetPoint('LEFT',auras_icon_normal_size,'RIGHT',20,0)
    auras_icon_squareness:SetPoint('TOPLEFT',auras_icon_normal_size,'BOTTOMLEFT',0,-30)
end
-- cast bars ###################################################################
function castbars:Initialise()
    local castbar_enable = self:CreateCheckBox('castbar_enable')
    local castbar_colour = self:CreateColourPicker('castbar_colour')
    local castbar_unin_colour = self:CreateColourPicker('castbar_unin_colour')
    local castbar_personal = self:CreateCheckBox('castbar_showpersonal')
    local castbar_icon = self:CreateCheckBox('castbar_icon')
    local castbar_name = self:CreateCheckBox('castbar_name')
    local castbar_shield = self:CreateCheckBox('castbar_shield')
    local castbar_all = self:CreateCheckBox('castbar_showall')
    local castbar_friend = self:CreateCheckBox('castbar_showfriend',true)
    local castbar_enemy = self:CreateCheckBox('castbar_showenemy',true)
    local castbar_height = self:CreateSlider('castbar_height',3,20)
    local name_v_offset = self:CreateSlider('castbar_name_vertical_offset',-20,20)

    castbar_enable:SetPoint('TOPLEFT',10,-10)
    castbar_colour:SetPoint('LEFT',castbar_enable,220,0)
    castbar_unin_colour:SetPoint('LEFT',castbar_personal,220,0)
    castbar_personal:SetPoint('TOPLEFT',castbar_enable,'BOTTOMLEFT')
    castbar_icon:SetPoint('TOPLEFT',castbar_personal,'BOTTOMLEFT')
    castbar_name:SetPoint('TOPLEFT',castbar_icon,'BOTTOMLEFT')
    castbar_shield:SetPoint('TOPLEFT',castbar_name,'BOTTOMLEFT')
    castbar_all:SetPoint('TOPLEFT',castbar_shield,'BOTTOMLEFT')
    castbar_friend:SetPoint('TOPLEFT',castbar_all,'BOTTOMLEFT',10,0)
    castbar_enemy:SetPoint('TOPLEFT',castbar_friend,'BOTTOMLEFT')
    castbar_height:SetPoint('TOPLEFT',castbar_enemy,'BOTTOMLEFT',-10,-30)
    name_v_offset:SetPoint('LEFT',castbar_height,'RIGHT',20,0)

    castbar_colour.enabled = function(p) return p.castbar_enable end
    castbar_unin_colour.enabled = castbar_colour.enabled
    castbar_personal.enabled = castbar_colour.enabled
    castbar_icon.enabled = castbar_colour.enabled
    castbar_name.enabled = castbar_colour.enabled
    castbar_shield.enabled = castbar_colour.enabled
    castbar_all.enabled = castbar_colour.enabled
    castbar_height.enabled = castbar_colour.enabled
    castbar_friend.enabled = function(p) return p.castbar_enable and p.castbar_showall end
    castbar_enemy.enabled = castbar_friend.enabled
    name_v_offset.enabled = function(p) return p.castbar_enable and p.castbar_name end
end
-- threat ######################################################################
function threat:Initialise()
    local tankmodeCheck = self:CreateCheckBox('tank_mode')
    local tankmode_force_enable = self:CreateCheckBox('tankmode_force_enable',true)
    local tankmode_force_offtank = self:CreateCheckBox('tankmode_force_offtank',true)
    local threatbracketsCheck = self:CreateCheckBox('threat_brackets')
    local tankmode_colour_sep = self:CreateSeparator('tankmode_colour_sep')
    local tankmode_tank_colour = self:CreateColourPicker('tankmode_tank_colour')
    local tankmode_trans_colour = self:CreateColourPicker('tankmode_trans_colour')
    local tankmode_other_colour = self:CreateColourPicker('tankmode_other_colour')
    local frame_glow_threat = self:CreateCheckBox('frame_glow_threat')

    tankmode_force_enable.enabled = function(p)
        return p.tank_mode
    end
    tankmode_force_offtank.enabled = function(p)
        return p.tank_mode and p.tankmode_force_enable
    end

    tankmode_tank_colour.enabled = tankmode_force_enable.enabled
    tankmode_trans_colour.enabled = tankmode_force_enable.enabled
    tankmode_other_colour.enabled = tankmode_force_enable.enabled

    tankmodeCheck:SetPoint('TOPLEFT',10,-10)
    tankmode_force_enable:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT',10,0)
    tankmode_force_offtank:SetPoint('TOPLEFT',tankmode_force_enable,'BOTTOMLEFT')
    threatbracketsCheck:SetPoint('LEFT',tankmodeCheck,'RIGHT',190,0)
    frame_glow_threat:SetPoint('TOPLEFT',threatbracketsCheck,'BOTTOMLEFT')

    tankmode_colour_sep:SetPoint('TOP',0,-110)
    tankmode_tank_colour:SetPoint('TOPLEFT',15,-130)
    tankmode_trans_colour:SetPoint('LEFT',tankmode_tank_colour,'RIGHT')
    tankmode_other_colour:SetPoint('LEFT',tankmode_trans_colour,'RIGHT')
end
-- classpowers #################################################################
function classpowers:Initialise()
    local classpowers_enable = self:CreateCheckBox('classpowers_enable')
    local classpowers_on_target = self:CreateCheckBox('classpowers_on_target',true)
    local classpowers_size = self:CreateSlider('classpowers_size',5,20)
    local classpowers_colour = self:CreateColourPicker('classpowers_colour')
    local classpowers_colour_overflow = self:CreateColourPicker('classpowers_colour_overflow')
    local classpowers_colour_inactive = self:CreateColourPicker('classpowers_colour_inactive')

    classpowers_enable:SetPoint('TOPLEFT',10,-10)
    classpowers_on_target:SetPoint('TOPLEFT',classpowers_enable,'BOTTOMLEFT',10,0)
    classpowers_colour:SetPoint('TOPLEFT',classpowers_on_target,'BOTTOMLEFT',-6,-10)
    classpowers_colour_overflow:SetPoint('LEFT',classpowers_colour,'RIGHT')
    classpowers_colour_inactive:SetPoint('LEFT',classpowers_colour_overflow,'RIGHT')
    classpowers_size:SetPoint('TOPLEFT',classpowers_colour,'BOTTOMLEFT',-4,-20)

    function classpowers_colour:Get()
        -- get colour from current class
        local class = select(2,UnitClass('player'))
        self.env = 'classpowers_colour_'..strlower(class)

        if opt.profile[self.env] then
            self.block:SetBackdropColor(unpack(opt.profile[self.env]))
        else
            self.block:SetBackdropColor(.5,.5,.5)
        end
    end
    function classpowers_colour:Set(col)
        opt.config:SetConfig(self.env,col)
        -- manually re-run OnShow since our env doesn't match the element name
        self:Hide()
        self:Show()
    end
    classpowers_colour:SetScript('OnEnter',function(self)
        -- force tooltip to use classpowers_colour env, since we change the
        -- env based on the player class
        GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
        GameTooltip:SetWidth(200)
        GameTooltip:AddLine(L.titles['classpowers_colour'])
        GameTooltip:AddLine(L.tooltips['classpowers_colour'],1,1,1,true)
        GameTooltip:Show()
    end)

    local function classpowers_enabled(p) return p.classpowers_enable end
    classpowers_on_target.enabled = classpowers_enabled
    classpowers_size.enabled = classpowers_enabled

    local function classpowers_colour_enabled(p)
        if classpowers_enabled(p) then
            local class = select(2,UnitClass('player'))
            local env = 'classpowers_colour_'..strlower(class)
            if opt.profile[env] then return true end
        end
    end
    classpowers_colour.enabled = classpowers_colour_enabled
    classpowers_colour_overflow.enabled = classpowers_enabled
    classpowers_colour_inactive.enabled = classpowers_enabled

    if select(2,UnitClass('player')) == 'MONK' then
        local classpowers_bar_width = self:CreateSlider('classpowers_bar_width',10,100)
        local classpowers_bar_height = self:CreateSlider('classpowers_bar_height',1,11)

        classpowers_bar_width:SetValueStep(2)
        classpowers_bar_height:SetValueStep(2)

        classpowers_bar_width:SetPoint('TOPLEFT',classpowers_size,'BOTTOMLEFT',0,-30)
        classpowers_bar_height:SetPoint('LEFT',classpowers_bar_width,'RIGHT',20,0)

        classpowers_bar_width.enabled = classpowers_enabled
        classpowers_bar_height.enabled = classpowers_enabled
    end
end
-- bossmod #####################################################################
function bossmod:Initialise()
    local bossmod_enable = self:CreateCheckBox('bossmod_enable')
    local bossmod_control_visibility = self:CreateCheckBox('bossmod_control_visibility')
    local bossmod_icon_size = self:CreateSlider('bossmod_icon_size',10,100)
    local bossmod_x_offset = self:CreateSlider('bossmod_x_offset',-200,200)
    local bossmod_y_offset = self:CreateSlider('bossmod_y_offset',-200,200)
    local bossmod_clickthrough = self:CreateCheckBox('bossmod_clickthrough',true)

    local function bossmod_enabled(p) return p.bossmod_enable end
    bossmod_control_visibility.enabled = bossmod_enabled
    bossmod_icon_size.enabled = bossmod_enabled
    bossmod_x_offset.enabled = bossmod_enabled
    bossmod_y_offset.enabled = bossmod_enabled
    bossmod_clickthrough.enabled = function(p) return p.bossmod_enable and p.bossmod_control_visibility end

    bossmod_enable:SetPoint('TOPLEFT',10,-10)
    bossmod_control_visibility:SetPoint('TOPLEFT',bossmod_enable,'BOTTOMLEFT',0,-10)
    bossmod_clickthrough:SetPoint('TOPLEFT',bossmod_control_visibility,'BOTTOMLEFT',10,0)

    bossmod_icon_size:SetPoint('TOP',0,-125)
    bossmod_x_offset:SetPoint('TOPLEFT',10,-(125+60))
    bossmod_y_offset:SetPoint('LEFT',bossmod_x_offset,'RIGHT',20,0)
end
-- cvars #######################################################################
function cvars:Initialise()
    -- "allow KNP to manage the cvars on this page"
    local enable = self:CreateCheckBox('cvar_enable')
    -- nameplateShowFriendlyNPCs
    local sfn = self:CreateCheckBox('cvar_show_friendly_npcs')
    -- nameplateShowOnlyNames
    local no = self:CreateCheckBox('cvar_name_only')
    -- nameplatePersonalShowAlways
    local psa = self:CreateCheckBox('cvar_personal_show_always')
    -- nameplatePersonalShowInCombat
    local psc = self:CreateCheckBox('cvar_personal_show_combat')
    -- nameplatePersonalShowWithTarget
    local pst = self:CreateCheckBox('cvar_personal_show_target')
    -- nameplateMaxDistance
    local md = self:CreateSlider('cvar_max_distance',5,100)
    md:SetValueStep(5)
    -- nameplate{Other,Large}TopInset
    local ct = self:CreateSlider('cvar_clamp_top',-.1,.5)
    ct:SetValueStep(.01)
    -- nameplate{Other,Large}BottomInset
    local cb = self:CreateSlider('cvar_clamp_bottom',-.1,.5)
    cb:SetValueStep(.01)
    -- nameplateOverlapV
    local ov = self:CreateSlider('cvar_overlap_v',0,5)
    ov:SetValueStep(.1)

    sfn.enabled = function(p) return p.cvar_enable end
    no.enabled  = sfn.enabled
    psa.enabled = sfn.enabled
    psc.enabled = sfn.enabled
    pst.enabled = sfn.enabled
    md.enabled  = sfn.enabled
    ct.enabled  = sfn.enabled
    cb.enabled  = sfn.enabled
    ov.enabled  = sfn.enabled

    enable:SetPoint('TOPLEFT',10,-10)

    sfn:SetPoint('TOPLEFT',enable,'BOTTOMLEFT',0,-10)
    no:SetPoint('TOPLEFT',sfn,'BOTTOMLEFT')

    psa:SetPoint('TOPLEFT',no,'BOTTOMLEFT',0,-10)
    psc:SetPoint('TOPLEFT',psa,'BOTTOMLEFT',0,0)
    pst:SetPoint('TOPLEFT',psc,'BOTTOMLEFT',0,0)

    md:SetPoint('TOPLEFT',10,-220)
    ov:SetPoint('LEFT',md,'RIGHT',20,0)
    ct:SetPoint('TOPLEFT',10,-(220+50))
    cb:SetPoint('LEFT',ct,'RIGHT',20,0)
end
