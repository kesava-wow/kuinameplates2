local opt = KuiNameplatesCoreConfig
local LSM = LibStub('LibSharedMedia-3.0')
local L = opt:GetLocale()

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

opt:ShowPage(1)

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
    local mouseover_glow = self:CreateCheckBox('mouseover_glow')
    local mouseover_glow_colour = self:CreateColourPicker('mouseover_glow_colour')
    local mouseover_highlight = self:CreateCheckBox('mouseover_highlight')
    local target_arrows = self:CreateCheckBox('target_arrows')
    local target_arrows_size = self:CreateSlider('target_arrows_size',20,60)

    target_glow_colour.enabled = function(p) return p.target_glow or p.target_arrows end
    mouseover_glow_colour.enabled = function(p) return p.mouseover_glow end
    target_arrows_size.enabled = function(p) return p.target_arrows end

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

    state_icons:SetPoint('TOPLEFT',ignore_uiscale,'BOTTOMLEFT',0,-10)
    target_glow:SetPoint('TOPLEFT',state_icons,'BOTTOMLEFT')
    target_glow_colour:SetPoint('LEFT',target_glow,'RIGHT',194,0)
    mouseover_glow:SetPoint('TOPLEFT',target_glow,'BOTTOMLEFT')
    mouseover_glow_colour:SetPoint('LEFT',mouseover_glow,'RIGHT',194,0)
    mouseover_highlight:SetPoint('TOPLEFT',mouseover_glow,'BOTTOMLEFT')
    glow_as_shadow:SetPoint('TOPLEFT',mouseover_highlight,'BOTTOMLEFT')
    target_arrows:SetPoint('TOPLEFT',glow_as_shadow,'BOTTOMLEFT',0,-20)
    target_arrows_size:SetPoint('LEFT',target_arrows,'RIGHT',184,0)

    local clickthrough_sep = self:CreateSeparator('clickthrough_sep')
    local clickthrough_self = self:CreateCheckBox('clickthrough_self')
    local clickthrough_friend = self:CreateCheckBox('clickthrough_friend')
    local clickthrough_enemy = self:CreateCheckBox('clickthrough_enemy')

    clickthrough_sep:SetPoint('TOP',0,-305)
    clickthrough_self:SetPoint('TOPLEFT',10,-320)
    clickthrough_friend:SetPoint('TOPLEFT',(10+155),-320)
    clickthrough_enemy:SetPoint('TOPLEFT',(10+155*2),-320)
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
    local avoid_sep = self:CreateSeparator('fade_avoid_sep')
    local avoid_no = self:CreateCheckBox('fade_avoid_nameonly')
    local avoid_ri = self:CreateCheckBox('fade_avoid_raidicon')
    local avoid_mo = self:CreateCheckBox('fade_avoid_mouseover')
    local avoid_xf = self:CreateCheckBox('fade_avoid_execute_friend')
    local avoid_xh = self:CreateCheckBox('fade_avoid_execute_hostile')
    local avoid_t = self:CreateCheckBox('fade_avoid_tracked')
    local avoid_c = self:CreateCheckBox('fade_avoid_combat')
    local avoid_cf = self:CreateCheckBox('fade_avoid_casting_friendly')
    local avoid_ch = self:CreateCheckBox('fade_avoid_casting_hostile')
    local avoid_ci = self:CreateCheckBox('fade_avoid_casting_interruptible',true)
    local avoid_cu = self:CreateCheckBox('fade_avoid_casting_uninterruptible',true)

    avoid_ci.enabled = function(p) return p.fade_avoid_casting_friendly or p.fade_avoid_casting_hostile end
    avoid_cu.enabled = avoid_ci.enabled
    avoid_c.enabled = function(p) return not p.fade_avoid_tracked end

    nt_alpha:SetWidth(120)
    nt_alpha:SetValueStep(.05)
    cond_alpha:SetWidth(120)
    cond_alpha:SetValueStep(.05)
    fade_speed:SetWidth(120)
    fade_speed:SetValueStep(.05)

    nt_alpha:SetPoint('TOPLEFT',10,-25)
    cond_alpha:SetPoint('LEFT',nt_alpha,'RIGHT',20,0)
    fade_speed:SetPoint('LEFT',cond_alpha,'RIGHT',20,0)

    fade_all:SetPoint('TOPLEFT',10,-65)
    fade_fnpc:SetPoint('LEFT',fade_all,'RIGHT',190,0)
    fade_ne:SetPoint('TOPLEFT',fade_all,'BOTTOMLEFT')
    fade_ut:SetPoint('LEFT',fade_ne,'RIGHT',190,0)

    avoid_sep:SetPoint('TOP',0,-150)

    avoid_mo:SetPoint('TOPLEFT',fade_ne,'BOTTOMLEFT',0,-50)
    avoid_no:SetPoint('TOPLEFT',avoid_mo,'BOTTOMLEFT',0,-10)
    avoid_ri:SetPoint('LEFT',avoid_no,'RIGHT',190,0)
    avoid_xf:SetPoint('TOPLEFT',avoid_no,'BOTTOMLEFT')
    avoid_xh:SetPoint('LEFT',avoid_xf,'RIGHT',190,0)
    avoid_t:SetPoint('TOPLEFT',avoid_xf,'BOTTOMLEFT')
    avoid_c:SetPoint('LEFT',avoid_t,'RIGHT',190,0)

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
    -- TODO THIS ISN'T ALIGNED AGH
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
        for _,f in ipairs(LSM:List(LSM.MediaType.STATUSBAR)) do
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
    local name_vertical_offset = self:CreateSlider('name_vertical_offset',-20,20)
    local bot_vertical_offset = self:CreateSlider('bot_vertical_offset',-20,20)

    font_style.SelectTable = {
        L.titles.dd_font_style_none,
        L.titles.dd_font_style_outline,
        L.titles.dd_font_style_shadow,
        L.titles.dd_font_style_shadowandoutline,
        L.titles.dd_font_style_monochrome,
    }

    bot_vertical_offset.enabled = function(p) return p.level_text or p.health_text end

    font_face:SetPoint('TOPLEFT',10,-10)
    font_style:SetPoint('LEFT',font_face,'RIGHT',10,0)

    font_size_normal:SetPoint('TOPLEFT',10,-70)
    font_size_small:SetPoint('LEFT',font_size_normal,'RIGHT',20,0)

    name_vertical_offset:SetPoint('TOPLEFT',font_size_normal,'BOTTOMLEFT',0,-30)
    bot_vertical_offset:SetPoint('LEFT',name_vertical_offset,'RIGHT',20,0)

    name_text:SetPoint('TOPLEFT',name_vertical_offset,'BOTTOMLEFT',0,-20)
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
        for _,f in ipairs(LSM:List(LSM.MediaType.FONT)) do
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
    local nameonly_target = self:CreateCheckBox('nameonly_target')
    local nameonly_all_enemies = self:CreateCheckBox('nameonly_all_enemies',true)
    local nameonly_neutral = self:CreateCheckBox('nameonly_neutral')
    local nameonly_enemies = self:CreateCheckBox('nameonly_enemies')
    local nameonly_hostile_players = self:CreateCheckBox('nameonly_hostile_players')
    local nameonly_damaged_enemies = self:CreateCheckBox('nameonly_damaged_enemies',true)
    local nameonly_friends = self:CreateCheckBox('nameonly_friends')
    local nameonly_friendly_players = self:CreateCheckBox('nameonly_friendly_players')
    local nameonly_damaged_friends = self:CreateCheckBox('nameonly_damaged_friends',true)
    local nameonly_combat_hostile = self:CreateCheckBox('nameonly_combat_hostile',true)
    local nameonly_combat_hostile_player = self:CreateCheckBox('nameonly_combat_hostile_player',true)
    local nameonly_combat_friends = self:CreateCheckBox('nameonly_combat_friends',true)
    local guild_text_npcs = self:CreateCheckBox('guild_text_npcs')
    local guild_text_players = self:CreateCheckBox('guild_text_players')
    local title_text_players = self:CreateCheckBox('title_text_players')
    local vis_sep = self:CreateSeparator('nameonly_visibility_sep')
    local text_sep = self:CreateSeparator('nameonly_text_sep','text')

    nameonly_no_font_style.enabled = function(p) return p.nameonly end
    nameonly_health_colour.enabled = nameonly_no_font_style.enabled
    guild_text_npcs.enabled = nameonly_no_font_style.enabled
    guild_text_players.enabled = nameonly_no_font_style.enabled
    title_text_players.enabled = nameonly_no_font_style.enabled

    nameonlyCheck:SetPoint('TOPLEFT',10,-10)

    -- "use name-only mode on..."
    vis_sep:SetPoint('TOP',0,-65)
    -- left
    nameonly_target:SetPoint('TOPLEFT',10,-75)
    nameonly_friendly_players:SetPoint('TOPLEFT',nameonly_target,'BOTTOMLEFT')
    nameonly_friends:SetPoint('TOPLEFT',nameonly_friendly_players,'BOTTOMLEFT')
    nameonly_damaged_friends:SetPoint('TOPLEFT',nameonly_friends,'BOTTOMLEFT',10,0)
    nameonly_combat_friends:SetPoint('TOPLEFT',nameonly_damaged_friends,'BOTTOMLEFT')

    nameonly_target.enabled = nameonly_no_font_style.enabled
    nameonly_friends.enabled = nameonly_no_font_style.enabled
    nameonly_friendly_players.enabled = nameonly_no_font_style.enabled
    nameonly_damaged_friends.enabled = function(p)
        return p.nameonly and (p.nameonly_friends or p.nameonly_friendly_players)
    end
    nameonly_combat_friends.enabled = nameonly_damaged_friends.enabled
    -- right
    nameonly_neutral:SetPoint('LEFT',nameonly_target,'RIGHT',190,0)
    nameonly_hostile_players:SetPoint('TOPLEFT',nameonly_neutral,'BOTTOMLEFT')
    nameonly_enemies:SetPoint('TOPLEFT',nameonly_hostile_players,'BOTTOMLEFT')
    nameonly_all_enemies:SetPoint('TOPLEFT',nameonly_enemies,'BOTTOMLEFT',10,0)
    nameonly_damaged_enemies:SetPoint('TOPLEFT',nameonly_all_enemies,'BOTTOMLEFT')
    nameonly_combat_hostile:SetPoint('TOPLEFT',nameonly_damaged_enemies,'BOTTOMLEFT')
    nameonly_combat_hostile_player:SetPoint('TOPLEFT',nameonly_combat_hostile,'BOTTOMLEFT',10,0)

    nameonly_neutral.enabled = function(p) return p.nameonly end
    nameonly_enemies.enabled = nameonly_neutral.enabled
    nameonly_hostile_players.enabled = nameonly_neutral.enabled
    nameonly_all_enemies.enabled = function(p)
        return p.nameonly and p.nameonly_enemies
    end
    nameonly_damaged_enemies.enabled = function(p)
        return p.nameonly and (p.nameonly_neutral or p.nameonly_enemies or p.nameonly_hostile_players)
    end
    nameonly_combat_hostile.enabled = nameonly_damaged_enemies.enabled
    nameonly_combat_hostile_player.enabled = function(p)
        return p.nameonly and p.nameonly_combat_hostile and (p.nameonly_neutral or p.nameonly_enemies)
    end

    -- "text"
    text_sep:SetPoint('TOP',0,-285)
    nameonly_health_colour:SetPoint('TOPLEFT',text_sep,'BOTTOMLEFT',0,-10)
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

    local element_sep = self:CreateSeparator('framesizes_element_sep')
    local powerbar_height = self:CreateSlider('powerbar_height',1,20)
    local frame_glow_size = self:CreateSlider('frame_glow_size',4,16)

    local scale_sep = self:CreateSeparator('framesizes_scale_sep')
    local global_scale = self:CreateSlider('global_scale',.5,2)
    global_scale:SetValueStep(.05)

    frame_height_personal.enabled = function(p) return not p.use_blizzard_personal end

    frame_width:SetPoint('TOPLEFT',10,-25)
    frame_height:SetPoint('LEFT',frame_width,'RIGHT',20,0)
    frame_width_personal:SetPoint('TOPLEFT',frame_width,'BOTTOMLEFT',0,-35)
    frame_height_personal:SetPoint('LEFT',frame_width_personal,'RIGHT',20,0)
    frame_width_minus:SetPoint('TOPLEFT',frame_width_personal,'BOTTOMLEFT',0,-35)
    frame_height_minus:SetPoint('LEFT',frame_width_minus,'RIGHT',20,0)

    element_sep:SetPoint('TOP',0,-195)
    powerbar_height:SetPoint('TOPLEFT',10,-225)
    frame_glow_size:SetPoint('LEFT',powerbar_height,'RIGHT',20,0)

    scale_sep:SetPoint('TOP',0,-295)
    global_scale:SetPoint('TOP',0,-325)
end
-- auras #######################################################################
function auras:Initialise()
    local auras_enabled = self:CreateCheckBox('auras_enabled')
    local show_purge = self:CreateCheckBox('auras_show_purge')
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

    local auras_icons_sep = self:CreateSeparator('auras_icons_sep')
    local auras_icon_normal_size = self:CreateSlider('auras_icon_normal_size',10,50)
    local auras_icon_minus_size = self:CreateSlider('auras_icon_minus_size',10,50)
    local auras_icon_squareness = self:CreateSlider('auras_icon_squareness',0.5,1)
    local purge_size = self:CreateSlider('auras_purge_size',10,50)
    local side = self:CreateDropDown('auras_side')
    local purge_opposite = self:CreateCheckBox('auras_purge_opposite',true)
    local offset = self:CreateSlider('auras_offset',-1,30)
    side.SelectTable = {'Top','Bottom'} -- TODO l10n

    purge_size.enabled = function(p) return p.auras_show_purge end
    purge_opposite.enabled = function(p) return p.auras_show_purge end

    auras_icon_squareness:SetValueStep(.1)

    auras_enabled:SetPoint('TOPLEFT',10,-17)
    show_purge:SetPoint('TOPLEFT',auras_enabled,'BOTTOMLEFT')
    auras_on_personal:SetPoint('TOPLEFT',show_purge,'BOTTOMLEFT')
    auras_sort:SetPoint('LEFT',auras_enabled,'RIGHT',184,0)
    auras_time_threshold:SetPoint('LEFT',auras_on_personal,'RIGHT',184,5)
    auras_show_all_self:SetPoint('TOPLEFT',auras_on_personal,'BOTTOMLEFT')
    auras_hide_all_other:SetPoint('TOPLEFT',auras_show_all_self,'BOTTOMLEFT')
    auras_kslc_hint:SetPoint('TOP',0,-160)

    auras_icons_sep:SetPoint('TOP',auras_kslc_hint,'BOTTOM',0,-35)
    auras_pulsate:SetPoint('TOPLEFT',auras_icons_sep,'BOTTOMLEFT',0,-10)
    auras_centre:SetPoint('LEFT',auras_pulsate,'RIGHT',190,0)
    side:SetPoint('TOPLEFT',auras_pulsate,'BOTTOMLEFT',-4,-10)
    purge_opposite:SetPoint('TOPLEFT',side,'BOTTOMLEFT',10,0)
    offset:SetPoint('LEFT',side,'RIGHT',10,0)
    auras_icon_normal_size:SetPoint('TOPLEFT',auras_icons_sep,0,-130)
    auras_icon_minus_size:SetPoint('LEFT',auras_icon_normal_size,'RIGHT',20,0)
    auras_icon_squareness:SetPoint('TOPLEFT',auras_icon_normal_size,'BOTTOMLEFT',0,-30)
    purge_size:SetPoint('LEFT',auras_icon_squareness,'RIGHT',20,0)

    local auras_text_sep = self:CreateSeparator('auras_text_sep','text')
    local auras_cd_size = self:CreateSlider('auras_cd_size',0,20,nil,'font_size')
    local auras_count_size = self:CreateSlider('auras_count_size',0,20,nil,'font_size')
    local colour_short = self:CreateColourPicker('auras_colour_short')
    local colour_medium = self:CreateColourPicker('auras_colour_medium')
    local colour_long = self:CreateColourPicker('auras_colour_long')
    local auras_cd_text_sep = self:CreateSeparator('auras_cd_text_sep')
    local auras_count_text_sep = self:CreateSeparator('auras_count_text_sep')

    local auras_cd_point_x = self:CreateDropDown('auras_cd_point_x','point_x')
    local auras_cd_point_y = self:CreateDropDown('auras_cd_point_y','point_y')
    local auras_cd_offset_x = self:CreateSlider('auras_cd_offset_x',-20,20,nil,'offset_x')
    local auras_cd_offset_y = self:CreateSlider('auras_cd_offset_y',-20,20,nil,'offset_y')
    local auras_count_point_x = self:CreateDropDown('auras_count_point_x','point_x')
    local auras_count_point_y = self:CreateDropDown('auras_count_point_y','point_y')
    local auras_count_offset_x = self:CreateSlider('auras_count_offset_x',-20,20,nil,'offset_x')
    local auras_count_offset_y = self:CreateSlider('auras_count_offset_y',-20,20,nil,'offset_y')

    local point_x_SelectTable = { 'LEFT', 'CENTER', 'RIGHT' } -- TODO l10n?
    local point_y_SelectTable = { 'TOP', 'CENTER', 'BOTTOM' }

    auras_cd_point_x.SelectTable = point_x_SelectTable
    auras_cd_point_y.SelectTable = point_y_SelectTable
    auras_count_point_x.SelectTable = point_x_SelectTable
    auras_count_point_y.SelectTable = point_y_SelectTable

    colour_short:SetWidth(135)
    auras_cd_point_x:SetWidth(95)
    auras_cd_point_y:SetWidth(95)
    auras_count_point_x:SetWidth(95)
    auras_count_point_y:SetWidth(95)

    auras_text_sep:SetPoint('TOP',0,-460)
    colour_short:SetPoint('TOPLEFT',auras_text_sep,'BOTTOMLEFT',4,-15)
    colour_medium:SetPoint('LEFT',colour_short,'RIGHT')
    colour_long:SetPoint('LEFT',colour_medium,'RIGHT')

    auras_cd_text_sep:SetWidth(190)
    auras_count_text_sep:SetWidth(190)
    auras_cd_text_sep:SetPoint('TOPLEFT',10,-540)
    auras_count_text_sep:SetPoint('LEFT',auras_cd_text_sep,210,0)

    auras_cd_size:SetPoint('TOPLEFT',colour_short,'BOTTOMLEFT',-4,-60)
    auras_count_size:SetPoint('LEFT',auras_cd_size,'RIGHT',20,0)

    auras_cd_point_x:SetPoint('TOPLEFT',auras_cd_size,'BOTTOMLEFT',0,-20)
    auras_cd_point_y:SetPoint('LEFT',auras_cd_point_x,'RIGHT')
    auras_cd_offset_x:SetPoint('TOPLEFT',auras_cd_point_x,'BOTTOMLEFT',0,-15)
    auras_cd_offset_y:SetPoint('TOPLEFT',auras_cd_offset_x,'BOTTOMLEFT',0,-30)

    auras_count_point_x:SetPoint('TOPLEFT',auras_count_size,'BOTTOMLEFT',0,-20)
    auras_count_point_y:SetPoint('LEFT',auras_count_point_x,'RIGHT')
    auras_count_offset_x:SetPoint('TOPLEFT',auras_count_point_x,'BOTTOMLEFT',0,-15)
    auras_count_offset_y:SetPoint('TOPLEFT',auras_count_offset_x,'BOTTOMLEFT',0,-30)
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
    local animate = self:CreateCheckBox('castbar_animate')
    local animate_cc = self:CreateCheckBox('castbar_animate_change_colour',true)

    local castbar_layout_sep = self:CreateSeparator('castbar_layout_sep','layout')
    local castbar_height = self:CreateSlider('castbar_height',3,30)
    local name_v_offset = self:CreateSlider('castbar_name_vertical_offset',-20,20)
    local castbar_detach = self:CreateCheckBox('castbar_detach')
    local castbar_detach_width = self:CreateSlider('castbar_detach_width',6,200,nil,'width')
    local castbar_detach_height = self:CreateSlider('castbar_detach_height',3,50,nil,'height')
    local castbar_detach_offset = self:CreateSlider('castbar_detach_offset',1,20,nil,'offset')
    local castbar_detach_combine = self:CreateCheckBox('castbar_detach_combine',true)
    local castbar_icon_side = self:CreateDropDown('castbar_icon_side')
    castbar_icon_side.SelectTable = { 'Left','Right' } -- TODO l10n

    castbar_enable:SetPoint('TOPLEFT',10,-10)
    castbar_name:SetPoint('TOPLEFT',castbar_enable,'BOTTOMLEFT')
    castbar_shield:SetPoint('TOPLEFT',castbar_name,'BOTTOMLEFT')

    castbar_icon:SetPoint('TOPLEFT',castbar_shield,'BOTTOMLEFT',0,0)

    castbar_personal:SetPoint('TOPLEFT',castbar_icon,'BOTTOMLEFT',0,-10)
    castbar_all:SetPoint('TOPLEFT',castbar_personal,'BOTTOMLEFT')
    castbar_friend:SetPoint('TOPLEFT',castbar_all,'BOTTOMLEFT',10,0)
    castbar_enemy:SetPoint('TOPLEFT',castbar_friend,'BOTTOMLEFT')

    animate:SetPoint('LEFT',castbar_personal,'RIGHT',190,0)
    animate_cc:SetPoint('TOPLEFT',animate,'BOTTOMLEFT',10,0)

    castbar_colour:SetPoint('LEFT',castbar_enable,220,0)
    castbar_unin_colour:SetPoint('LEFT',castbar_name,220,0)

    castbar_detach_width:SetWidth(120)
    castbar_detach_height:SetWidth(120)
    castbar_detach_offset:SetWidth(120)

    castbar_layout_sep:SetPoint('TOP',0,-260)
    castbar_detach:SetPoint('TOPLEFT',10,-260-15)
    castbar_detach_combine:SetPoint('TOPLEFT',castbar_detach,'BOTTOMLEFT',10,0)
    castbar_icon_side:SetPoint('LEFT',castbar_detach,'RIGHT',170,-8)
    castbar_detach_width:SetPoint('TOPLEFT',castbar_detach,'BOTTOMLEFT',0,-50)
    castbar_detach_height:SetPoint('LEFT',castbar_detach_width,'RIGHT',22,0)
    castbar_detach_offset:SetPoint('LEFT',castbar_detach_height,'RIGHT',22,0)

    castbar_height:SetPoint('TOPLEFT',castbar_detach_width,'BOTTOMLEFT',0,-40)
    name_v_offset:SetPoint('LEFT',castbar_height,'RIGHT',20,0)

    castbar_colour.enabled = function(p) return p.castbar_enable end
    castbar_unin_colour.enabled = castbar_colour.enabled
    castbar_personal.enabled = castbar_colour.enabled
    castbar_icon.enabled = castbar_colour.enabled
    castbar_icon_side.enabled = function(p)
        return p.castbar_icon and (not p.castbar_detach or not p.castbar_detach_combine)
    end
    castbar_name.enabled = castbar_colour.enabled
    castbar_shield.enabled = castbar_colour.enabled
    castbar_all.enabled = castbar_colour.enabled
    castbar_height.enabled = function(p) return p.castbar_enable and not p.castbar_detach end
    castbar_friend.enabled = function(p) return p.castbar_enable and p.castbar_showall end
    castbar_enemy.enabled = castbar_friend.enabled
    name_v_offset.enabled = function(p) return p.castbar_enable and p.castbar_name end
    animate.enabled = castbar_colour.enabled
    animate_cc.enabled = function(p) return p.castbar_animate and p.castbar_enable end

    castbar_detach.enabled = castbar_colour.enabled
    castbar_detach_width.enabled = function(p) return p.castbar_enable and p.castbar_detach end
    castbar_detach_height.enabled = castbar_detach_width.enabled
    castbar_detach_offset.enabled = castbar_detach_width.enabled
    castbar_detach_combine.enabled = function(p)
        return p.castbar_enable and p.castbar_detach and p.castbar_icon
    end
end
-- threat ######################################################################
function threat:Initialise()
    local tankmodeCheck = self:CreateCheckBox('tank_mode')
    local tankmode_force_enable = self:CreateCheckBox('tankmode_force_enable',true)
    local tankmode_force_offtank = self:CreateCheckBox('tankmode_force_offtank',true)
    local threatbracketsCheck = self:CreateCheckBox('threat_brackets')
    local frame_glow_threat = self:CreateCheckBox('frame_glow_threat')
    local tankmode_colour_sep = self:CreateSeparator('tankmode_colour_sep')
    local tankmode_tank_colour = self:CreateColourPicker('tankmode_tank_colour')
    local tankmode_trans_colour = self:CreateColourPicker('tankmode_trans_colour')
    local tankmode_other_colour = self:CreateColourPicker('tankmode_other_colour')
    local tankmode_glow_colour_sep = self:CreateSeparator('tankmode_glow_colour_sep')
    local tankmode_tank_glow_colour = self:CreateColourPicker('tankmode_tank_glow_colour')
    local tankmode_trans_glow_colour = self:CreateColourPicker('tankmode_trans_glow_colour')

    tankmode_force_enable.enabled = function(p)
        return p.tank_mode
    end
    tankmode_force_offtank.enabled = function(p)
        return p.tank_mode and p.tankmode_force_enable
    end

    tankmode_tank_colour.enabled = tankmode_force_enable.enabled
    tankmode_trans_colour.enabled = tankmode_force_enable.enabled
    tankmode_other_colour.enabled = tankmode_force_enable.enabled

    tankmode_tank_glow_colour.enabled = function(p)
        return p.threat_brackets or p.frame_glow_threat
    end
    tankmode_trans_glow_colour.enabled = tankmode_tank_glow_colour.enabled

    tankmodeCheck:SetPoint('TOPLEFT',10,-10)
    tankmode_force_enable:SetPoint('TOPLEFT',tankmodeCheck,'BOTTOMLEFT',10,0)
    tankmode_force_offtank:SetPoint('TOPLEFT',tankmode_force_enable,'BOTTOMLEFT')
    threatbracketsCheck:SetPoint('LEFT',tankmodeCheck,'RIGHT',190,0)
    frame_glow_threat:SetPoint('TOPLEFT',threatbracketsCheck,'BOTTOMLEFT')

    tankmode_colour_sep:SetWidth(190)
    tankmode_colour_sep:SetPoint('TOPLEFT',10,-120)
    tankmode_tank_colour:SetPoint('TOPLEFT',tankmode_colour_sep,'BOTTOMLEFT',10,-10)
    tankmode_trans_colour:SetPoint('TOPLEFT',tankmode_tank_colour,'BOTTOMLEFT')
    tankmode_other_colour:SetPoint('TOPLEFT',tankmode_trans_colour,'BOTTOMLEFT')

    tankmode_glow_colour_sep:SetWidth(190)
    tankmode_glow_colour_sep:SetPoint('LEFT',tankmode_colour_sep,210,0)
    tankmode_tank_glow_colour:SetPoint('TOPLEFT',tankmode_glow_colour_sep,'BOTTOMLEFT',10,-10)
    tankmode_trans_glow_colour:SetPoint('TOPLEFT',tankmode_tank_glow_colour,'BOTTOMLEFT')
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
        opt.config:SetKey(self.env,col)
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

    bossmod_icon_size:SetPoint('TOP',0,-170)
    bossmod_x_offset:SetPoint('TOPLEFT',10,-(170+50))
    bossmod_y_offset:SetPoint('LEFT',bossmod_x_offset,'RIGHT',20,0)
end
-- cvars #######################################################################
function cvars:Initialise()
    -- "allow KNP to manage the cvars on this page"
    local enable = self:CreateCheckBox('cvar_enable')
    -- nameplateShowFriendlyNPCs
    local sfn = self:CreateCheckBox('cvar_show_friendly_npcs')
    sfn.enabled = function(p) return p.cvar_enable end
    -- nameplateShowOnlyNames
    local no = self:CreateCheckBox('cvar_name_only')
    no.enabled  = sfn.enabled
    -- nameplate{Min,Max}Scale
    local ds = self:CreateCheckBox('cvar_disable_scale')
    ds.enabled  = sfn.enabled
    -- nameplatePersonalShowAlways
    local psa = self:CreateCheckBox('cvar_personal_show_always')
    psa.enabled = sfn.enabled
    -- nameplatePersonalShowInCombat
    local psc = self:CreateCheckBox('cvar_personal_show_combat')
    psc.enabled = sfn.enabled
    -- nameplatePersonalShowWithTarget
    local pst = self:CreateCheckBox('cvar_personal_show_target')
    pst.enabled = sfn.enabled
    -- nameplateMaxDistance
    local md = self:CreateSlider('cvar_max_distance',5,100)
    md:SetValueStep(5)
    md.enabled  = sfn.enabled
    -- nameplate{Other,Large}TopInset
    local ct = self:CreateSlider('cvar_clamp_top',-.1,.5)
    ct:SetValueStep(.01)
    ct.enabled  = sfn.enabled
    -- nameplate{Other,Large}BottomInset
    local cb = self:CreateSlider('cvar_clamp_bottom',-.1,.5)
    cb:SetValueStep(.01)
    cb.enabled  = sfn.enabled
    -- nameplateSelfTopInset
    local self_clamp_top = self:CreateSlider('cvar_self_clamp_top',-.1,.5)
    self_clamp_top:SetValueStep(.01)
    self_clamp_top.enabled = sfn.enabled
    -- nameplateSelfBottomInset
    local self_clamp_bottom = self:CreateSlider('cvar_self_clamp_bottom',-.1,.5)
    self_clamp_bottom:SetValueStep(.01)
    self_clamp_bottom.enabled = sfn.enabled
    -- nameplateOverlapV
    local ov = self:CreateSlider('cvar_overlap_v',0,5)
    ov:SetValueStep(.1)
    ov.enabled  = sfn.enabled
    -- nameplate{Min,Max,Selected}Alpha
    local disable_alpha = self:CreateCheckBox('cvar_disable_alpha')
    disable_alpha.enabled = sfn.enabled
    -- nameplateSelfAlpha
    local self_alpha = self:CreateSlider('cvar_self_alpha',0,1)
    self_alpha:SetWidth(120)
    self_alpha:SetValueStep(.05)
    self_alpha.enabled = sfn.enabled
    -- nameplateOccludedAlphaMult
    local occluded_mult = self:CreateSlider('cvar_occluded_mult',0,1)
    occluded_mult:SetWidth(120)
    occluded_mult:SetValueStep(.05)
    occluded_mult.enabled = sfn.enabled

    enable:SetPoint('TOPLEFT',10,-10)

    sfn:SetPoint('TOPLEFT',enable,'BOTTOMLEFT',0,-10)
    no:SetPoint('TOPLEFT',sfn,'BOTTOMLEFT')
    ds:SetPoint('TOPLEFT',no,'BOTTOMLEFT')
    disable_alpha:SetPoint('TOPLEFT',ds,'BOTTOMLEFT')

    self_alpha:SetPoint('TOPLEFT',83,-170)
    occluded_mult:SetPoint('LEFT',self_alpha,'RIGHT',14,0)

    psa:SetPoint('TOPLEFT',disable_alpha,'BOTTOMLEFT',0,-65)
    psc:SetPoint('TOPLEFT',psa,'BOTTOMLEFT',0,0)
    pst:SetPoint('TOPLEFT',psc,'BOTTOMLEFT',0,0)

    md:SetPoint('TOPLEFT',10,-330)
    ov:SetPoint('LEFT',md,'RIGHT',20,0)
    ct:SetPoint('TOPLEFT',md,'BOTTOMLEFT',0,-35)
    cb:SetPoint('TOPLEFT',ov,'BOTTOMLEFT',0,-35)
    self_clamp_top:SetPoint('TOPLEFT',ct,'BOTTOMLEFT',0,-35)
    self_clamp_bottom:SetPoint('TOPLEFT',cb,'BOTTOMLEFT',0,-35)
end
