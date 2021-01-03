local L = KuiNameplatesCoreConfig:Locale('zhCN')
if not L then return end

L["common"] = {
	["copy"] = "复制",
	["delete"] = "删除",
	["font_size"] = "字号",
	["height"] = "高度",
	["layout"] = "布局",
	["offset"] = "偏移",
	["offset_x"] = "水平偏移量",
	["offset_y"] = "垂直偏移量",
	["page"] = "页",
	["paste"] = "粘贴",
	["point"] = "位置",
	["point_x"] = "水平定位点",
	["point_y"] = "垂直定位点",
	["position"] = "位置",
	["profile"] = "配置",
	["rename"] = "重命名",
	["reset"] = "重置",
	["size"] = "大小",
	["text"] = "文本",
	["width"] = "宽度",
}

L["page_names"] = {
	["auras"] = "光环设置",
	["bossmod"] = "Boss模式",
	["castbars"] = "施法条",
	["classpowers"] = "职业能量",
	["cvars"] = "CVars",
	["fade_rules"] = "渐隐规则",
	["framesizes"] = "框架尺寸",
	["general"] = "基本设置",
	["healthbars"] = "生命条",
	["nameonly"] = "名字模式",
	["text"] = "文本设置",
	["threat"] = "仇恨",
}

L["titles"] = {
	["absorb_enable"] = "显示护盾",
	["absorb_striped"] = "条纹化护盾材质",
	["auras_cd_movable"] = "冷却",
	["auras_centre"] = "中心对齐",
	["auras_colour_long"] = "长时间",
	["auras_colour_medium"] = "中等长度时间",
	["auras_colour_short"] = "短时间",
	["auras_count_movable"] = "计数",
	["auras_enabled"] = "启用光环",
	["auras_filtering_sep"] = "过滤",
	["auras_hide_all_other"] = "隐藏他人施放的所有光环",
	["auras_icon_minus_size"] = "图标尺寸(次要单位)",
	["auras_icon_normal_size"] = "图标尺寸(标准)",
	["auras_icon_squareness"] = "图标长宽比例",
	["auras_icons_sep"] = "图标",
	["auras_kslc_hint"] = "KuiSpellListConfig(可在Curse上取得)可以让任何施法者编辑光环黑名单和白名单.",
	["auras_offset"] = "垂直偏移量",
	["auras_on_personal"] = "显示在个人框架",
	["auras_pulsate"] = "闪烁图标",
	["auras_purge_opposite"] = "净化在另一侧",
	["auras_purge_size"] = "图标大小(净化)",
	["auras_show_all_self"] = "显示自己施放的所有光环",
	["auras_show_purge"] = "显示净化",
	["auras_side"] = "侧边",
	["auras_sort"] = "排序方式",
	["auras_time_threshold"] = "计时器阈值",
	["bar_animation"] = "状态条动画",
	["bar_texture"] = "状态条材质",
	["bossmod_clickthrough"] = "姓名板自动显示时启用点击穿越",
	["bossmod_control_visibility"] = "允许首领警报插件控制姓名板是否可见",
	["bossmod_enable"] = "启用首领提醒插件交流",
	["bossmod_icon_size"] = "图标大小",
	["bossmod_x_offset"] = "水平偏移",
	["bossmod_y_offset"] = "垂直偏移",
	["bot_vertical_offset"] = "等级/血量垂直偏移",
	["castbar_animate"] = "动画",
	["castbar_animate_change_colour"] = "改变颜色",
	["castbar_colour"] = "施法条颜色",
	["castbar_detach"] = "分离",
	["castbar_detach_combine"] = "法术图标叠加",
	["castbar_detach_nameonly"] = "名字模式下显示",
	["castbar_enable"] = "启用",
	["castbar_height"] = "施法条高度",
	["castbar_icon"] = "法术图标",
	["castbar_icon_side"] = "法术图标大小",
	["castbar_name"] = "法术名称",
	["castbar_name_vertical_offset"] = "法术名称垂直偏移",
	["castbar_shield"] = "显示盾牌图标",
	["castbar_showall"] = "在所有姓名板上",
	["castbar_showenemy"] = "敌方",
	["castbar_showfriend"] = "友方",
	["castbar_showpersonal"] = "显示玩家施法条",
	["castbar_unin_colour"] = "免疫打断的施法条颜色",
	["class_colour_enemy_names"] = "敌方姓名职业染色",
	["class_colour_friendly_names"] = "友方姓名职业染色",
	["classpowers_bar_height"] = "能量条高度",
	["classpowers_bar_width"] = "能量条宽度",
	["classpowers_colour"] = "图标颜色",
	["classpowers_colour_inactive"] = "能量闲置",
	["classpowers_colour_overflow"] = "能量溢出",
	["classpowers_enable"] = "显示职业能量",
	["classpowers_on_enemies"] = "在敌方上显示",
	["classpowers_on_friends"] = "在友方上显示",
	["classpowers_on_target"] = "在目标上显示",
	["classpowers_size"] = "图标大小",
	["clickthrough_enemy"] = "敌方",
	["clickthrough_friend"] = "友方",
	["clickthrough_self"] = "自身",
	["clickthrough_sep"] = "点击穿越",
	["colour_absorb"] = "护盾覆盖",
	["colour_enemy_class"] = "敌方玩家职业颜色",
	["colour_enemy_pet"] = "宠物",
	["colour_enemy_player"] = "敌方玩家",
	["colour_friendly"] = "友善",
	["colour_friendly_pet"] = "宠物",
	["colour_hated"] = "仇恨",
	["colour_neutral"] = "中立",
	["colour_player"] = "玩家",
	["colour_player_class"] = "友方玩家职业颜色",
	["colour_self"] = "自身",
	["colour_self_class"] = "职业颜色",
	["colour_tapped"] = "无拾取权",
	["combat_friendly"] = "战斗动作:友方",
	["combat_hostile"] = "战斗动作:敌方",
	["copy_profile_label"] = "给新配置输入名称",
	["copy_profile_title"] = "拷贝配置",
	["cvar_clamp_bottom"] = "固定底部",
	["cvar_clamp_top"] = "固定顶部",
	["cvar_disable_alpha"] = "停用淡出",
	["cvar_disable_scale"] = "停用缩放",
	["cvar_enable"] = "允许Kui Nameplates修改CVars",
	["cvar_max_distance"] = "最大可视距离",
	["cvar_name_only"] = "隐藏预设生命条",
	["cvar_occluded_mult"] = "超出距离透明度",
	["cvar_overlap_v"] = "垂直堆叠间距",
	["cvar_personal_show_always"] = "总是显示个人姓名板",
	["cvar_personal_show_combat"] = "战斗中显示个人姓名板",
	["cvar_personal_show_target"] = "有目标时显示个人姓名板",
	["cvar_self_alpha"] = "透明度",
	["cvar_self_clamp_bottom"] = "固定底部",
	["cvar_self_clamp_top"] = "固定顶部",
	["cvar_show_friendly_npcs"] = "总是显示友方NPC姓名板",
	["dd_auras_sort_index"] = "光环索引",
	["dd_auras_sort_time"] = "剩余时间",
	["dd_bar_animation_cutaway"] = "切换",
	["dd_bar_animation_smooth"] = "平滑",
	["dd_combat_toggle_hide"] = "战斗隐藏,脱战显示",
	["dd_combat_toggle_nothing"] = "无动作",
	["dd_combat_toggle_show"] = "战斗显示，脱战隐藏",
	["dd_font_style_monochrome"] = "单色",
	["dd_font_style_none"] = "无",
	["dd_font_style_outline"] = "描边",
	["dd_font_style_shadow"] = "阴影",
	["dd_font_style_shadowandoutline"] = "阴影+描边",
	["dd_health_text_blank"] = "空",
	["dd_health_text_current"] = "当前值",
	["dd_health_text_current_deficit"] = "当前+损失值",
	["dd_health_text_current_percent"] = "当前+百分比",
	["dd_health_text_deficit"] = "损失值",
	["dd_health_text_maximum"] = "最大值",
	["dd_health_text_percent"] = "百分比",
	["delete_profile_label"] = "删除配置|cffffffff%s|r?",
	["delete_profile_title"] = "删除配置",
	["execute_auto"] = "自动检测斩杀血量",
	["execute_colour"] = "斩杀染色",
	["execute_enabled"] = "启用斩杀染色",
	["execute_percent"] = "斩杀阈值",
	["execute_sep"] = "斩杀阶段",
	["fade_all"] = "默认淡出",
	["fade_avoid_casting_friendly"] = "施法中(友方)",
	["fade_avoid_casting_hostile"] = "施法中(敌方)",
	["fade_avoid_casting_interruptible"] = "可打断",
	["fade_avoid_casting_uninterruptible"] = "不可打断",
	["fade_avoid_combat"] = "战斗中",
	["fade_avoid_execute_friend"] = "低生命值友方",
	["fade_avoid_execute_hostile"] = "低生命值敌方",
	["fade_avoid_mouseover"] = "鼠标悬停",
	["fade_avoid_nameonly"] = "在名字模式下",
	["fade_avoid_raidicon"] = "有团队标记图标",
	["fade_avoid_sep"] = "不淡出...",
	["fade_avoid_tracked"] = "追踪或者战斗中",
	["fade_conditional_alpha"] = "透明条件",
	["fade_friendly_npc"] = "渐隐友方NPC",
	["fade_neutral_enemy"] = "渐隐中立单位",
	["fade_non_target_alpha"] = "非目标透明度",
	["fade_speed"] = "动画速度",
	["fade_untracked"] = "渐隐非追踪单位",
	["font_face"] = "文本字体",
	["font_size_normal"] = "常规字体大小",
	["font_size_small"] = "辅助字体大小",
	["font_style"] = "文本样式",
	["frame_glow_size"] = "框架发光尺寸",
	["frame_glow_size_shadow"] = "阴影尺寸",
	["frame_glow_size_target"] = "目标光亮尺寸",
	["frame_glow_size_threat"] = "仇恨光亮尺寸",
	["frame_glow_threat"] = "仇恨高亮",
	["frame_height_personal"] = "个人姓名板高度",
	["frame_minus_size"] = "次要单位框体大小",
	["frame_padding_x"] = "点击框填充宽度",
	["frame_padding_y"] = "点击框填充高度",
	["frame_target_size"] = "目标框体大小",
	["frame_width_personal"] = "个人姓名板宽度",
	["global_scale"] = "全局缩放",
	["glow_as_shadow"] = "框架阴影",
	["guild_text_npcs"] = "显示NPC头衔",
	["guild_text_players"] = "显示玩家公会",
	["health_text"] = "显示生命值",
	["health_text_friend_dmg"] = "损血友方",
	["health_text_friend_max"] = "满血友方",
	["health_text_hostile_dmg"] = "损血敌方",
	["health_text_hostile_max"] = "满血敌方",
	["health_text_percent_symbol"] = "显示百分比符号",
	["health_text_sep"] = "生命值文字",
	["hide_names"] = "隐藏未追踪单位名字",
	["ignore_uiscale"] = "像素校正",
	["level_nameonly"] = "显示等级",
	["level_text"] = "显示等级",
	["mouseover_glow"] = "鼠标悬停发光",
	["mouseover_glow_colour"] = "鼠标悬停发光的颜色",
	["mouseover_highlight"] = "鼠标悬停高亮",
	["name_colour_npc_friendly"] = "友善",
	["name_colour_npc_hostile"] = "敌对",
	["name_colour_npc_neutral"] = "中立",
	["name_colour_player_friendly"] = "友方玩家",
	["name_colour_player_hostile"] = "敌对玩家",
	["name_colour_sep"] = "名字颜色",
	["name_colour_white_in_bar_mode"] = "生命条上显示白色名字",
	["name_text"] = "显示姓名",
	["name_vertical_offset"] = "名字垂直偏移",
	["nameonly"] = "启用名字模式",
	["nameonly_all_enemies"] = "可攻击的",
	["nameonly_combat_friends"] = "进入战斗的",
	["nameonly_combat_hostile"] = "进入战斗的",
	["nameonly_combat_hostile_player"] = "目标是你",
	["nameonly_damaged_enemies"] = "受到伤害的",
	["nameonly_damaged_friends"] = "受到伤害的",
	["nameonly_enemies"] = "敌对NPC",
	["nameonly_friendly_players"] = "友方玩家",
	["nameonly_friends"] = "友方NPC",
	["nameonly_health_colour"] = "生命百分比染色",
	["nameonly_hostile_players"] = "敌对玩家",
	["nameonly_neutral"] = "中立单位",
	["nameonly_no_font_style"] = "无字型描边",
	["nameonly_target"] = "目标",
	["nameonly_visibility_sep"] = "使用名字模式于...",
	["new_profile"] = "新建配置",
	["new_profile_label"] = "输入配置名称",
	["paste_page_label"] = "复制|cffffffff%s|r配置从|cffffffff%s|r到|cffffffff%s|r吗?",
	["powerbar_height"] = "能量条高度",
	["profile"] = "配置",
	["reaction_colour_sep"] = "颜色",
	["rename_profile_label"] = "给|cffffffff%s输入新名称",
	["rename_profile_title"] = "配置重命名",
	["reset_page_label"] = "重置所有|cffffffff%s|r的选项吗?",
	["reset_profile_label"] = "重置配置|cffffffff%s|r?",
	["reset_profile_title"] = "重置配置",
	["show_quest_icon"] = "任务图示",
	["show_raid_icon"] = "团队图示",
	["state_icons"] = "状态图标",
	["tank_mode"] = "坦克模式启用",
	["tankmode_colour_sep"] = "坦克模式颜色",
	["tankmode_force_enable"] = "强制启用坦克模式",
	["tankmode_force_offtank"] = "强制换坦检测",
	["tankmode_glow_colour_sep"] = "仇恨颜色",
	["tankmode_other_colour"] = "仇恨丢失",
	["tankmode_tank_colour"] = "当前仇恨",
	["tankmode_tank_glow_colour"] = "当前坦克",
	["tankmode_trans_colour"] = "换坦",
	["tankmode_trans_glow_colour"] = "换坦",
	["target_arrows"] = "目标方向箭头",
	["target_arrows_size"] = "目标箭头尺寸",
	["target_glow"] = "目标高亮",
	["target_glow_colour"] = "目标高亮颜色",
	["threat_brackets"] = "仇恨指示器",
	["title_text_players"] = "显示玩家头衔",
	["use_blizzard_personal"] = "忽略个人姓名板",
	["use_blizzard_powers"] = "显示默认职业能量",
	["version"] = "%s 由%s 在%s|n版本 %s",
}

L["tooltips"] = {
	["absorb_enable"] = "在生命条上显示护盾",
	["absorb_striped"] = "在吸收盾上使用条纹材质。如果未勾选，继承生命条材质",
	["auras_cd_size"] = "设置为0以使用“正常”字号",
	["auras_colour_long"] = "大于20秒",
	["auras_colour_medium"] = "少于20秒",
	["auras_colour_short"] = "少于5秒",
	["auras_count_size"] = "设置为0以使用“小”字号",
	["auras_enabled"] = "友方的增益,敌方的减益",
	["auras_hide_all_other"] = "不显示任何他人施放的光环(如控制和减速)",
	["auras_icon_minus_size"] = "较小框架的图标大小",
	["auras_icon_normal_size"] = "常规框架的图标大小",
	["auras_icon_squareness"] = "光环图标的长宽比例，设为1代表正方形",
	["auras_on_personal"] = "在个人姓名板上显示增益",
	["auras_pulsate"] = "快要结束时闪烁图标",
	["auras_show_all_self"] = "显示你施放的所有光环,不仅仅是被暴雪标记的重要的光环",
	["auras_show_purge"] = "在敌方显示你可以偷取、驱散或净化的增益",
	["auras_time_threshold"] = "剩余秒数高于这个数值时隐藏计时器. 设置为-1时可一直显示.",
	["bar_animation"] = "生命/能量条变化的动画方式",
	["bar_texture"] = "状态条使用的材质(由LibSharedMedia提供)",
	["bossmod_clickthrough"] = "当姓名板自动显示的时候禁用点击",
	["bossmod_control_visibility"] = "如果在首领战中使用技能提醒插件,允许提醒插件显示.",
	["bossmod_enable"] = "支持的首领提醒插件可以与KNP交流,显示特定首领战的光环并在姓名板上显示.",
	["castbar_animate"] = "当施法结束时淡出施法条.",
	["castbar_animate_change_colour"] = "当施法结束时变更施法条颜色,这样可以更好分辨成功,中止以及被打断施法的区别.",
	["castbar_colour"] = "施法条颜色.|n|n如果有启用动画,也用于表示成功施放.",
	["castbar_enable"] = "启用施法条",
	["castbar_name_vertical_offset"] = "法术名称文本垂直偏移量",
	["castbar_shield"] = "在免疫打断的施法条上显示盾牌图标",
	["castbar_showall"] = "在所有姓名板上显示施法条,而不是只针对当前目标",
	["castbar_showenemy"] = "显示敌方施法条",
	["castbar_showfriend"] = "显示友方施法条,(注意:启用名字模式时不会显示施法条)",
	["castbar_showpersonal"] = "如果启用个人姓名板,在其上显示玩家施法条",
	["castbar_unin_colour"] = "染色无法被打断的施法条.|n|n如果有启用动画,也用于表示中断施放.",
	["classpowers_enable"] = "显示职业特殊能量，像是连击点、圣能等等.",
	["classpowers_on_target"] = "显示于目标框体，不仅仅是个人姓名板",
	["clickthrough_enemy"] = "在敌方姓名板上禁用单击",
	["clickthrough_friend"] = "在友方姓名板上禁用单击",
	["clickthrough_self"] = "在个人姓名板上禁用单击",
	["colour_friendly_pet"] = "注意,友方玩家宠物一般不会显示姓名板",
	["colour_player"] = "其他友方玩家生命条的颜色",
	["colour_self"] = "个人姓名板的生命条颜色",
	["colour_self_class"] = "在个人姓名板上使用职业颜色",
	["combat_friendly"] = "进入与离开战斗时在友方框体上采取的动作.",
	["combat_hostile"] = "进入与离开战斗时在敌方框体上采取的动作.",
	["cvar_clamp_bottom"] = "|cffffcc00nameplateOtherBottomInset|nnameplateLargeBottomInset|r",
	["cvar_clamp_top"] = "|cffffcc00nameplateOtherTopInset|nnameplateLargeTopInset|r|n|n姓名板与屏幕顶部边缘的距离，当设置为0代表完全贴齐边缘，设置为-0.1代表不要贴齐在萤幕边缘。|n|n只影响你的当前目标。",
	["cvar_disable_alpha"] = "|cffffcc00nameplateMinAlpha|nnameplateMaxAlpha|nnameplateSelectedAlpha|r|n|n停用姓名条的透明CVars参数 (除了以下的) 让它们不会干扰KNP的淡出规则。",
	["cvar_disable_scale"] = "|cffffcc00nameplateMinScale|nnameplateMaxScale|nnameplateLargerScale|nnameplateSelectedScale|nnameplateSelfScale|r|n|n停用名条距离缩放CVars参数，它会破坏像素校正。",
	["cvar_enable"] = "启用后,Kui Nameplates将尝试将此页面上的CVar参数锁定到你所设置的值.|n|n如果取消此选项,KNP不会修改CVars,并将它们恢复为默认值.",
	["cvar_max_distance"] = "|cffffcc00nameplateMaxDistance|r|n|n姓名板可视的最大距离（不包含当前目标）",
	["cvar_name_only"] = "|cffffcc00nameplateShowOnlyNames|r|n|n在友方姓名板无法被插件修改的情形下，隐藏预设姓名版的生命条。",
	["cvar_occluded_mult"] = "|cffffcc00nameplateOccludedAlphaMult|r|n|n透明度系数适用于不在玩家视线内的姓名条。",
	["cvar_overlap_v"] = "|cffffcc00nameplateOverlapV|r|n|n姓名板彼此之间的垂直距离（只有在Esc > 介面 > 姓名板的选项中将排列类型设定为堆叠才有效）。",
	["cvar_personal_show_always"] = "|cffffcc00nameplatePersonalShowAlways|r",
	["cvar_personal_show_combat"] = "|cffffcc00nameplatePersonalShowInCombat|r",
	["cvar_personal_show_target"] = "|cffffcc00nameplatePersonalShowWithTarget|r|n|n如果你有可攻击的目标就显示个人姓名板。",
	["cvar_self_alpha"] = "|cffffcc00nameplateOccludedAlphaMult|r|n|n透明度乘数适用于不在玩家视线内的名条。",
	["cvar_self_clamp_bottom"] = "|cffffcc00nameplateSelfBottomInset|r",
	["cvar_self_clamp_top"] = "|cffffcc00nameplateSelfTopInset|r",
	["cvar_show_friendly_npcs"] = "|cffffcc00nameplateShowFriendlyNPCs|r",
	["execute_auto"] = "自动侦测你的天赋专精所需的斩杀阈值，对于无斩杀的角色默认为20%",
	["execute_colour"] = "斩杀阶段使用的颜色",
	["execute_enabled"] = "当单位进入斩杀阶段时，重新染色生命条",
	["execute_percent"] = "手动设定斩杀阶段生命值阈值",
	["fade_all"] = "默认情况下,将所有框架淡出至非目标透明度",
	["fade_avoid_execute_friend"] = "生命值处于斩杀阶段的友方姓名板",
	["fade_avoid_execute_hostile"] = "生命值处于斩杀阶段的敌方姓名板",
	["fade_avoid_tracked"] = "可以通过\"NPC名字\"下拉菜单和 界面设置 > 名字 中的复选框选项来设定是否追踪一个单位.",
	["fade_conditional_alpha"] = "当符合以下条件时非透明框架将会淡出",
	["fade_friendly_npc"] = "默认淡出友方NPC姓名板(包含名字模式)",
	["fade_neutral_enemy"] = "默认淡出可攻击的中立单位姓名板(包含名字模式)",
	["fade_non_target_alpha"] = "当你有目标时其他框架将会淡出.|n|n不可见的姓名板仍然可以被点击.",
	["fade_speed"] = "框体淡出的速度，1是最慢的，0是立即淡出",
	["fade_untracked"] = "默认淡出非追踪目标姓名板(包含名字模式).|n|n通过改变 Esc > 界面 > 姓名 > ”NPC名字”菜单的选项,来设定是否进行追踪\"",
	["font_face"] = "字体由LibSharedMedia提供.",
	["font_size_normal"] = "用于名字,等级,生命值和光环.",
	["font_size_small"] = "用户公会和法术名称.",
	["frame_glow_threat"] = "以高亮的颜色变化来指示仇恨状态",
	["frame_minus_size"] = "标记为\"次要单位\"的小型怪物的备用框体尺寸",
	["frame_target_size"] = "当前目标的备用框体尺寸",
	["frame_width_personal"] = "个人姓名板宽度(在界面设置 > 名字 选项中启用)",
	["global_scale"] = "根据此数值缩放所有姓名板(按照像素网格)",
	["guild_text_npcs"] = "例如飞行管理员,军需官等.",
	["health_text_friend_dmg"] = "友方单位损血时的血量文字格式",
	["health_text_friend_max"] = "友方单位满血时的血量文字格式",
	["health_text_hostile_dmg"] = "敌方单位损血时的血量文字格式",
	["health_text_hostile_max"] = "敌方单位满血时的血量文字格式",
	["hide_names"] = "通过改变 Esc > 界面 > 姓名 > NPC名字 菜单的选项,来设定一个单位是否进行追踪.|n|n此设定在名字模式下无效.",
	["ignore_uiscale"] = "修复与界面缩放相关的像素对齐问题,通过调整 /knp > 框架尺寸 > 全局缩放 来补偿大小差异,|n|n这是非常必要的,即使你并没有启用UI缩放.",
	["name_colour_white_in_bar_mode"] = "(包含玩家职业颜色)",
	["nameonly_all_enemies"] = "只适用于敌对NPC",
	["nameonly_combat_hostile"] = "注意,这并不适用于训练假人或其他没有仇恨数据的单位",
	["nameonly_health_colour"] = "以部份染色的方式来显示血量百分比",
	["nameonly_no_font_style"] = "使用名字模式时,不使用字体描边",
	["nameonly_target"] = "使用名字模式下允许目标的设置保留",
	["powerbar_height"] = "个人姓名板中的能量条的高度",
	["reload_hint"] = "需要重新加载UI.",
	["state_icons"] = "在首领与精英单位上显示图标(启用”显示等级文字”时隐藏)",
	["tank_mode"] = "当你是坦克时，重新染色你正在坦住的单位姓名板颜色",
	["tankmode_force_enable"] = "总是使用坦克模式,不管你是否处于坦克专精",
	["tankmode_force_offtank"] = "染色被团队中其他坦克所坦住的单位姓名板,即使你目前并非坦克专精",
	["tankmode_other_colour"] = "团队中其他坦克坦住时的姓名板颜色(或者是玩家宠物,坐骑或图腾|n|n只对坦克专精生效，并且只对同个团队中、职责要设定为坦克的角色生效.",
	["tankmode_tank_colour"] = "稳定坦住时的姓名板颜色",
	["tankmode_trans_colour"] = "获得或失去仇恨时的姓名板颜色",
	["target_indicators"] = "在当前目标周围显示指示器.它们继承上面设置的目标发光颜色.",
	["use_blizzard_personal"] = "不要剥离个人姓名板显示,可以在 界面设置 > 名字 设置中启用.",
}

