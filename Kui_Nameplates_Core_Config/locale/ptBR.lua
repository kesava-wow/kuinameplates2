local L = KuiNameplatesCoreConfig:Locale('ptBR')
if not L then return end

L["page_names"] = {
	["auras"] = "Auras",
	["bossmod"] = "Boss mods.",
	["castbars"] = "Barras de lançamento",
	["classpowers"] = "Recursos de classe",
--[[Translation missing --]]
	["cvars"] = "CVars",
--[[Translation missing --]]
	["fade_rules"] = "Fade rules",
--[[Translation missing --]]
	["framesizes"] = "Frame sizes",
--[[Translation missing --]]
	["general"] = "General",
--[[Translation missing --]]
	["healthbars"] = "Health bars",
	["nameonly"] = "Apenas-nomes",
--[[Translation missing --]]
	["text"] = "Text",
--[[Translation missing --]]
	["threat"] = "Threat",
}

L["titles"] = {
	["absorb_enable"] = "Mostra absorções.",
	["absorb_striped"] = "Textura de absorção listrada",
	["auras_centre"] = "Alinha os ícones ao centro",
	["auras_colour_long"] = "Longa duração",
	["auras_colour_medium"] = "Média duração",
	["auras_colour_short"] = "Curta duração",
	["auras_enabled"] = "Mostrar auras.",
	["auras_filtering_sep"] = "Filtros",
	["auras_hide_all_other"] = "Bloquear todas as outras auras",
	["auras_icon_minus_size"] = [=[Tamanho do ícone (minus)
]=],
	["auras_icon_normal_size"] = [=[Tamanho do ícone (normal)
]=],
	["auras_icon_squareness"] = "Quadriculação do ícone",
	["auras_icons_sep"] = "Ícones",
	["auras_kslc_hint"] = [=[KuiSpellListConfig do Curse pode ser usado para adicionar auras de qualquer lançador à lista de auras permitidas ou auras bloqueadas.
]=],
	["auras_offset"] = "Deslocamento vertical",
	["auras_on_personal"] = [=[Mostrar no quadro pessoal
]=],
	["auras_pulsate"] = "Pulsar",
	["auras_purge_opposite"] = [=[Expurgar no lado oposto
]=],
	["auras_purge_size"] = [=[Tamanho do ícone (expurgar)
]=],
	["auras_show_all_self"] = "Por todas as suas auras na lista de auras permitidas",
	["auras_show_purge"] = "Mostrar expurgar",
	["auras_side"] = "Lado",
	["auras_sort"] = [=[Método de classificação
]=],
	["auras_time_threshold"] = [=[Limite do temporizador
]=],
	["bar_animation"] = "Animação da barra",
	["bar_texture"] = "Textura da barra",
	["bossmod_clickthrough"] = [=[Ativar "clicar em" quando mostrado automaticamente.
]=],
	["bossmod_control_visibility"] = [=[Permitir que os boss mods controlem a visibilidade das placas de identificação.
]=],
	["bossmod_enable"] = "Habilitar módulo de comunicação de boss mod.",
	["bossmod_icon_size"] = "Tamanho do ícone",
	["bossmod_x_offset"] = "Deslocamento horizontal",
	["bossmod_y_offset"] = "Deslocamento vertical",
	["bot_vertical_offset"] = "Deslocamento vertical nível/vida",
	["castbar_animate"] = "Animação",
	["castbar_animate_change_colour"] = "Mudar cor",
	["castbar_colour"] = "Cor da barra",
	["castbar_enable"] = "Habilitado",
	["castbar_height"] = "Altura da barra",
	["castbar_icon"] = "Ícone do feitiço",
	["castbar_name"] = "Nome do feitiço",
	["castbar_name_vertical_offset"] = "D.vertical do nome do feitiço",
	["castbar_shield"] = [=[Escudo ininterrupto.
]=],
	["castbar_showall"] = "Em todas as placas de identificação",
	["castbar_showenemy"] = "Inimigo",
	["castbar_showfriend"] = "Aliado",
	["castbar_showpersonal"] = "No quadro pessoal",
	["castbar_unin_colour"] = "Cor ininterrupta. ",
	["class_colour_enemy_names"] = "Cores de classe de inimigos",
	["class_colour_friendly_names"] = "Cores de classe de aliados",
	["classpowers_bar_height"] = "Altura da barra de recursos",
	["classpowers_bar_width"] = "Largura da barra de recursos",
	["classpowers_colour"] = "Cor do ícone",
	["classpowers_colour_inactive"] = "Cor inativa",
--[[Translation missing --]]
	["classpowers_colour_overflow"] = "Overflow colour",
	["classpowers_enable"] = "Mostrar recursos de classe",
--[[Translation missing --]]
	["classpowers_on_target"] = "Show on target",
--[[Translation missing --]]
	["classpowers_size"] = "Icon size",
--[[Translation missing --]]
	["clickthrough_enemy"] = "Enemy",
--[[Translation missing --]]
	["clickthrough_friend"] = "Friendly",
--[[Translation missing --]]
	["clickthrough_self"] = "Personal",
--[[Translation missing --]]
	["clickthrough_sep"] = "Clickthrough frames",
--[[Translation missing --]]
	["colour_absorb"] = "Absorb overlay",
--[[Translation missing --]]
	["colour_enemy_class"] = "Class colour hostile players",
--[[Translation missing --]]
	["colour_enemy_pet"] = "Hostile player pet",
--[[Translation missing --]]
	["colour_enemy_player"] = "Hostile player",
--[[Translation missing --]]
	["colour_friendly"] = "Friendly",
--[[Translation missing --]]
	["colour_friendly_pet"] = "Friendly player pet",
--[[Translation missing --]]
	["colour_hated"] = "Hated",
--[[Translation missing --]]
	["colour_neutral"] = "Neutral",
--[[Translation missing --]]
	["colour_player"] = "Player",
--[[Translation missing --]]
	["colour_player_class"] = "Class colour friendly players",
--[[Translation missing --]]
	["colour_self"] = "Self",
--[[Translation missing --]]
	["colour_self_class"] = "Class colour self",
--[[Translation missing --]]
	["colour_tapped"] = "Tapped",
	["combat_friendly"] = "Ação em combate: aliados",
	["combat_hostile"] = "Ação em combate: inimigos",
--[[Translation missing --]]
	["copy_profile_label"] = "Enter name for new profile",
--[[Translation missing --]]
	["copy_profile_title"] = "Copy profile",
--[[Translation missing --]]
	["cvar_clamp_bottom"] = "Bottom clamp distance",
--[[Translation missing --]]
	["cvar_clamp_top"] = "Top clamp distance",
--[[Translation missing --]]
	["cvar_disable_scale"] = "Disable default scaling",
--[[Translation missing --]]
	["cvar_enable"] = "Allow Kui Nameplates to modify CVars",
--[[Translation missing --]]
	["cvar_max_distance"] = "Max render distance",
	["cvar_name_only"] = "Esconder a barra de vida padrão",
--[[Translation missing --]]
	["cvar_overlap_v"] = "Vertical overlap",
--[[Translation missing --]]
	["cvar_personal_show_always"] = "Always show personal nameplate",
	["cvar_personal_show_combat"] = [=[Mostrar placa de identificação pessoal quando em combate
]=],
--[[Translation missing --]]
	["cvar_personal_show_target"] = "Show personal nameplate with a target",
--[[Translation missing --]]
	["cvar_show_friendly_npcs"] = "Always show friendly NPCs' nameplates",
--[[Translation missing --]]
	["dd_auras_sort_index"] = "Aura index",
--[[Translation missing --]]
	["dd_auras_sort_time"] = "Time remaining",
--[[Translation missing --]]
	["dd_bar_animation_cutaway"] = "Cutaway",
--[[Translation missing --]]
	["dd_bar_animation_smooth"] = "Smooth",
	["dd_combat_toggle_hide"] = [=[Esconder, depois mostrar
]=],
	["dd_combat_toggle_nothing"] = "Não fazer nada",
	["dd_combat_toggle_show"] = "Mostrar, depois esconder",
--[[Translation missing --]]
	["dd_font_style_monochrome"] = "Monochrome",
--[[Translation missing --]]
	["dd_font_style_none"] = "None",
--[[Translation missing --]]
	["dd_font_style_outline"] = "Outline",
--[[Translation missing --]]
	["dd_font_style_shadow"] = "Shadow",
--[[Translation missing --]]
	["dd_font_style_shadowandoutline"] = "Shadow+Outline",
--[[Translation missing --]]
	["dd_health_text_blank"] = "Blank",
--[[Translation missing --]]
	["dd_health_text_current"] = "Current",
--[[Translation missing --]]
	["dd_health_text_current_deficit"] = "Current + deficit",
--[[Translation missing --]]
	["dd_health_text_current_percent"] = "Current + percent",
--[[Translation missing --]]
	["dd_health_text_deficit"] = "Deficit",
--[[Translation missing --]]
	["dd_health_text_maximum"] = "Maximum",
--[[Translation missing --]]
	["dd_health_text_percent"] = "Percent",
--[[Translation missing --]]
	["delete_profile_label"] = "Delete profile |cffffffff%s|r?",
--[[Translation missing --]]
	["delete_profile_title"] = "Delete profile",
--[[Translation missing --]]
	["execute_auto"] = "Auto-detect range",
--[[Translation missing --]]
	["execute_colour"] = "Execute colour",
--[[Translation missing --]]
	["execute_enabled"] = "Enable execute range",
--[[Translation missing --]]
	["execute_percent"] = "Execute range",
--[[Translation missing --]]
	["execute_sep"] = "Execute range",
--[[Translation missing --]]
	["fade_all"] = "Fade out by default",
--[[Translation missing --]]
	["fade_avoid_casting_friendly"] = "Casting (friendly)",
--[[Translation missing --]]
	["fade_avoid_casting_hostile"] = "Casting (hostile)",
--[[Translation missing --]]
	["fade_avoid_casting_interruptible"] = "Interruptible",
--[[Translation missing --]]
	["fade_avoid_casting_uninterruptible"] = "Uninterruptible",
--[[Translation missing --]]
	["fade_avoid_combat"] = "In combat",
--[[Translation missing --]]
	["fade_avoid_execute_friend"] = "Low health friends",
--[[Translation missing --]]
	["fade_avoid_execute_hostile"] = "Low health enemies",
--[[Translation missing --]]
	["fade_avoid_mouseover"] = "Mouseover",
	["fade_avoid_nameonly"] = "Em apenas-nomes",
--[[Translation missing --]]
	["fade_avoid_raidicon"] = "With raid icon",
--[[Translation missing --]]
	["fade_avoid_sep"] = "Don't fade...",
--[[Translation missing --]]
	["fade_avoid_tracked"] = "Tracked or in combat",
--[[Translation missing --]]
	["fade_conditional_alpha"] = "Conditional alpha",
--[[Translation missing --]]
	["fade_friendly_npc"] = "Fade friendly NPCs",
--[[Translation missing --]]
	["fade_neutral_enemy"] = "Fade neutral enemies",
--[[Translation missing --]]
	["fade_non_target_alpha"] = "Non-target alpha",
--[[Translation missing --]]
	["fade_speed"] = "Animation speed",
--[[Translation missing --]]
	["fade_untracked"] = "Fade non-tracked units",
--[[Translation missing --]]
	["font_face"] = "Font face",
--[[Translation missing --]]
	["font_size_normal"] = "Normal font size",
--[[Translation missing --]]
	["font_size_small"] = "Small font size",
--[[Translation missing --]]
	["font_style"] = "Font style",
--[[Translation missing --]]
	["frame_glow_size"] = "Frame glow size",
--[[Translation missing --]]
	["frame_glow_threat"] = "Show threat glow",
--[[Translation missing --]]
	["frame_height"] = "Frame height",
--[[Translation missing --]]
	["frame_height_minus"] = "Minus frame height",
--[[Translation missing --]]
	["frame_height_personal"] = "Personal frame height",
--[[Translation missing --]]
	["frame_width"] = "Frame width",
--[[Translation missing --]]
	["frame_width_minus"] = "Minus frame width",
--[[Translation missing --]]
	["frame_width_personal"] = "Personal frame width",
--[[Translation missing --]]
	["framesizes_element_sep"] = "Elements",
--[[Translation missing --]]
	["framesizes_scale_sep"] = "Scale",
--[[Translation missing --]]
	["global_scale"] = "Global scale",
--[[Translation missing --]]
	["glow_as_shadow"] = "Frame shadow",
--[[Translation missing --]]
	["guild_text_npcs"] = "Show NPC titles",
--[[Translation missing --]]
	["guild_text_players"] = "Show player guilds",
--[[Translation missing --]]
	["health_text"] = "Show health text",
--[[Translation missing --]]
	["health_text_friend_dmg"] = "Damaged friend",
--[[Translation missing --]]
	["health_text_friend_max"] = "Max. health friend",
--[[Translation missing --]]
	["health_text_hostile_dmg"] = "Damaged hostile",
--[[Translation missing --]]
	["health_text_hostile_max"] = "Max. health hostile",
--[[Translation missing --]]
	["health_text_sep"] = "Health text",
--[[Translation missing --]]
	["hide_names"] = "Hide non-tracked names",
--[[Translation missing --]]
	["ignore_uiscale"] = "Pixel correction",
--[[Translation missing --]]
	["level_text"] = "Show level text",
--[[Translation missing --]]
	["mouseover_glow"] = "Mouseover glow",
--[[Translation missing --]]
	["mouseover_glow_colour"] = "Mouseover glow colour",
--[[Translation missing --]]
	["name_colour_npc_friendly"] = "Friendly",
--[[Translation missing --]]
	["name_colour_npc_hostile"] = "Hostile",
--[[Translation missing --]]
	["name_colour_npc_neutral"] = "Neutral",
--[[Translation missing --]]
	["name_colour_player_friendly"] = "Friendly player",
--[[Translation missing --]]
	["name_colour_player_hostile"] = "Hostile player",
--[[Translation missing --]]
	["name_colour_sep"] = "Name text colour",
--[[Translation missing --]]
	["name_colour_white_in_bar_mode"] = "White names with visible health bar",
--[[Translation missing --]]
	["name_text"] = "Show name text",
--[[Translation missing --]]
	["name_vertical_offset"] = "Name v.offset",
	["nameonly"] = "Usar modo de apenas-nomes",
	["nameonly_all_enemies"] = "Em inimigos",
--[[Translation missing --]]
	["nameonly_combat_friends"] = "In combat",
--[[Translation missing --]]
	["nameonly_combat_hostile"] = "In combat",
--[[Translation missing --]]
	["nameonly_combat_hostile_player"] = "With you",
--[[Translation missing --]]
	["nameonly_damaged_enemies"] = "Damaged",
	["nameonly_damaged_friends"] = "Em aliados feridos",
	["nameonly_enemies"] = "Em inimigos inatacáveis",
--[[Translation missing --]]
	["nameonly_friendly_players"] = "Friendly players",
--[[Translation missing --]]
	["nameonly_friends"] = "Friendly NPCs",
	["nameonly_health_colour"] = "Cor da vida",
--[[Translation missing --]]
	["nameonly_hostile_players"] = "Hostile players",
	["nameonly_neutral"] = "Em inimigos neutros",
	["nameonly_no_font_style"] = [=[Nenhum contorno de texto
]=],
	["nameonly_target"] = "No alvo",
	["nameonly_text_sep"] = "Texto",
	["nameonly_visibility_sep"] = "Visiblidade",
--[[Translation missing --]]
	["new_profile"] = "New profile...",
--[[Translation missing --]]
	["new_profile_label"] = "Enter profile name",
--[[Translation missing --]]
	["powerbar_height"] = "Power bar height",
--[[Translation missing --]]
	["profile"] = "Profile",
--[[Translation missing --]]
	["reaction_colour_sep"] = "Colours",
--[[Translation missing --]]
	["rename_profile_label"] = "Enter new name for |cffffffff%s",
--[[Translation missing --]]
	["rename_profile_title"] = "Rename profile",
--[[Translation missing --]]
	["reset_profile_label"] = "Reset profile |cffffffff%s|r?",
--[[Translation missing --]]
	["reset_profile_title"] = "Reset profile",
--[[Translation missing --]]
	["state_icons"] = "State icons",
--[[Translation missing --]]
	["tank_mode"] = "Enable tank mode",
--[[Translation missing --]]
	["tankmode_colour_sep"] = "Tank mode bar colours",
--[[Translation missing --]]
	["tankmode_force_enable"] = "Force tank mode",
--[[Translation missing --]]
	["tankmode_force_offtank"] = "Force off-tank detection",
--[[Translation missing --]]
	["tankmode_other_colour"] = "Off-tank",
--[[Translation missing --]]
	["tankmode_tank_colour"] = "Tanking",
--[[Translation missing --]]
	["tankmode_trans_colour"] = "Transitional",
--[[Translation missing --]]
	["target_arrows"] = "Target arrows",
--[[Translation missing --]]
	["target_arrows_size"] = "Target arrow size",
--[[Translation missing --]]
	["target_glow"] = "Target glow",
--[[Translation missing --]]
	["target_glow_colour"] = "Target glow colour",
--[[Translation missing --]]
	["text_vertical_offset"] = "Text v.offset",
--[[Translation missing --]]
	["threat_brackets"] = "Show threat brackets",
--[[Translation missing --]]
	["title_text_players"] = "Show player titles",
--[[Translation missing --]]
	["use_blizzard_personal"] = "Ignore personal nameplate",
--[[Translation missing --]]
	["version"] = "%s by %s @ Curse, version %s",
}

L["tooltips"] = {
	["absorb_enable"] = "Mostra a absorção nas barras de vida.",
	["absorb_striped"] = "Usa uma textura listrada para absorções. Se desmarcada, herda a textura da barra de vida.",
	["auras_enabled"] = "Mostra auras que você casta nos nameplates - buffs em amigos, debuffs nos inimigos",
	["auras_hide_all_other"] = "Não mostrar auras lançadas por outros jogadores no quadro de aura principal (tal como CC ou slows).",
	["auras_icon_minus_size"] = [=[Tamanho do ícone em quadros menores
]=],
	["auras_icon_normal_size"] = [=[Tamanho do ícone em quadros de tamanho normal.
]=],
	["auras_icon_squareness"] = [=[Proporção de tamanho dos ícones de aura, em que 1 significa um quadrado perfeito.
]=],
	["auras_on_personal"] = [=[Mostrar buffs na exibição de recursos pessoais
]=],
	["auras_pulsate"] = [=[Pulsar ícones quando eles estão prestes a expirar
]=],
	["auras_show_all_self"] = [=[Mostra todas as auras que você lançou, em vez de apenas aquelas marcadas como importantes pela Blizzard.
]=],
	["auras_show_purge"] = [=[Mostrar buffs em inimigos que você pode dissipar, expurgar ou roubar o feitiço.
]=],
	["auras_time_threshold"] = [=[Oculte o temporizador acima desse número de segundos. Defina para -1 para sempre mostrar.
]=],
	["bar_animation"] = [=[O estilo de animação para usar em barras de vida/recursos.
]=],
	["bar_texture"] = "A textura usada para barras de status (fornecidas pelo LibSharedMedia).",
	["bossmod_clickthrough"] = [=[Desativar a caixa de clique das placas de identificação que são ativadas automaticamente.
]=],
	["bossmod_control_visibility"] = "Addons de boss mods podem mandar uma mensagem para addons de placas de identificação informando-os para mantar placas de identificação habilitadas durante um encontro, ignorando outras configurações como alternar automaticamente em combate, para que informações extras possam ser exibidas nelas.|n|n|cffff6666IfSe você desabilitar essa opção e e você geralmente não tiver placas de identificação habilitadas, boss mods não serão capazes de te mostrar essa informação.",
	["bossmod_enable"] = [=[Addons de boss mods podem se comunicar com addons de placa de identificação para exibir informações extras em placas de identificação em encontros relevantes, como buffs importantes ou debuffs lançados por chefes.
]=],
	["bossmod_icon_size"] = [=[Tamanho dos ícones de auras do chefe
]=],
	["bossmod_x_offset"] = [=[Deslocamento horizontal dos ícones de auras do chefe
]=],
	["bossmod_y_offset"] = "Deslocamento vertical dos ícones de auras do chefe",
	["castbar_animate"] = "Desaparecer a barra de lançamento quando um lançamento acabar.",
	["castbar_animate_change_colour"] = "Muda a cor da barra de lançamento quando um lançamento acaba, tornando mais fácil de dizer a diferença entre lançamentos interrompidos, cancelados e bem sucedidos.",
	["castbar_colour"] = "Cor da barra de lançamento.|n|nTambém usado para indicar um lançamento bem sucedido se a animação estiver habilitada.",
	["castbar_enable"] = "Habilita a barra de lançamento.",
	["castbar_name_vertical_offset"] = "Deslocamento vertical do texto do nome do feitiço.",
	["castbar_shield"] = "Mostra um ícone de escudo numa barra de lançamento que não possa ser interrompido.",
	["castbar_showall"] = "Mostrar barras de lançamento em todas as placas de identificação, em vez de apenas no alvo atual",
	["castbar_showenemy"] = "Mostrar barras de lançamento em placas de identificação de inimigos.",
	["castbar_showfriend"] = "Mostrar barras de lançamento em placas de identificação de aliados (note que barras de lançamento não são mostradas em quadros que tiverem o modo de somente-nome ativo).",
	["castbar_showpersonal"] = "Mostra a barra de lançamento na placa de identificação do seu personagem, se habilitado.",
	["castbar_unin_colour"] = "Cor da barra de lançamento quando não pode ser interrompido.|n|nTambém usado para indicar um lançamento interrompido se animação está habilitada.",
	["class_colour_enemy_names"] = "Cor dos nomes dos jogadores inimigos pela cor de suas classes.",
	["class_colour_friendly_names"] = "Cor dos nomes dos jogadores aliados pela cor de suas classes.",
	["classpowers_bar_height"] = "Altura da barra de recursos",
	["classpowers_bar_width"] = "Largura da barra de recursos",
	["classpowers_colour"] = "Cor dos recursos de classe para a classe atual",
	["classpowers_colour_inactive"] = [=[Cor dos ícones de recurso da classe inativo.
]=],
--[[Translation missing --]]
	["classpowers_colour_overflow"] = "Colour of class powers \"overflow\"",
--[[Translation missing --]]
	["classpowers_enable"] = "Show your class' special resource, such as combo points, holy power, etc.",
--[[Translation missing --]]
	["classpowers_on_target"] = "Show on the frame of your target, rather than on the personal nameplate",
--[[Translation missing --]]
	["classpowers_size"] = "Size of the class powers icons",
--[[Translation missing --]]
	["clickthrough_enemy"] = "Disable the click-box of enemy nameplates",
--[[Translation missing --]]
	["clickthrough_friend"] = "Disable the click-box of friendly nameplates",
--[[Translation missing --]]
	["clickthrough_self"] = "Disable the click-box of your personal nameplate",
--[[Translation missing --]]
	["colour_friendly_pet"] = "Note that friendly pets do not generally have nameplates rendered",
--[[Translation missing --]]
	["colour_player"] = "The colour of other friendly players' health bars",
--[[Translation missing --]]
	["colour_self"] = "The health bar colour of your personal nameplate",
--[[Translation missing --]]
	["colour_self_class"] = "Use your class colour on your personal nameplate",
--[[Translation missing --]]
	["combat_friendly"] = "Action to take on friendly frames upon entering and leaving combat.",
--[[Translation missing --]]
	["combat_hostile"] = "Action to take on hostile frames upon entering and leaving combat.",
--[[Translation missing --]]
	["cvar_clamp_bottom"] = "|cffffcc00nameplate{Other,Large}BottomInset|r",
--[[Translation missing --]]
	["cvar_clamp_top"] = "|cffffcc00nameplate{Other,Large}TopInset|r|n|nHow close nameplates will be rendered to the top edge of the screen, where 0 means on the edge. Set to -0.1 to disable clamping on the top of the screen.|n|nClamping only affects your current target.",
--[[Translation missing --]]
	["cvar_disable_scale"] = "|cffffcc00nameplate{Min,Max}Scale|r|n|nDisable the nameplate distance scaling CVars which would otherwise only be affecting the clickbox.",
--[[Translation missing --]]
	["cvar_enable"] = "When enabled, Kui Nameplates will attempt to lock the CVars on this page to the values set here.|n|nIf this option is disabled, KNP will not modify CVars, even to return them to defaults.",
--[[Translation missing --]]
	["cvar_max_distance"] = "|cffffcc00nameplateMaxDistance|r|n|nMaximum distance at which to render nameplates (not including your current target).",
	["cvar_name_only"] = [=[|cffffcc00nameplateShowOnlyNames|r|n|nOculte a barra de vida das placas de identificação padrão em situações em que placas de identificação aliadas ​​não podem ser alteradas de outra forma por addons.
]=],
--[[Translation missing --]]
	["cvar_overlap_v"] = "|cffffcc00nameplateOverlapV|r|n|nVertical distance between nameplates (only valid when motion type is set to stacking in the default interface options).",
--[[Translation missing --]]
	["cvar_personal_show_always"] = "|cffffcc00nameplatePersonalShowAlways|r",
--[[Translation missing --]]
	["cvar_personal_show_combat"] = "|cffffcc00nameplatePersonalShowInCombat|r",
--[[Translation missing --]]
	["cvar_personal_show_target"] = "|cffffcc00nameplatePersonalShowWithTarget|r|n|nShow the personal nameplate whenever you have an attackable target.",
--[[Translation missing --]]
	["cvar_show_friendly_npcs"] = "|cffffcc00nameplateShowFriendlyNPCs|r",
--[[Translation missing --]]
	["execute_auto"] = "Automatically detect the appropriate execute range from your talents, defaulting to 20% on a character with no execute",
--[[Translation missing --]]
	["execute_colour"] = "Colour to use within execute range",
--[[Translation missing --]]
	["execute_enabled"] = "Recolour health bars when units are within execute range",
--[[Translation missing --]]
	["execute_percent"] = "Manually set execute range",
--[[Translation missing --]]
	["fade_all"] = "Fade all frames to the non-target alpha by default",
--[[Translation missing --]]
	["fade_avoid_execute_friend"] = "Friendly nameplates in execute range",
--[[Translation missing --]]
	["fade_avoid_execute_hostile"] = "Hostile nameplates in execute range",
--[[Translation missing --]]
	["fade_avoid_tracked"] = "Whether or not a unit is tracked can by set by changing the \"NPC Names\" dropdown and other checkboxes in the default interface options under Esc > Interface > Names",
--[[Translation missing --]]
	["fade_conditional_alpha"] = "Opacity frames will fade to when matching one of the conditions below",
--[[Translation missing --]]
	["fade_friendly_npc"] = "Fade friendly NPC nameplates by default (including those in name-only mode)",
--[[Translation missing --]]
	["fade_neutral_enemy"] = "Fade attackable neutral nameplates by default (including those in name-only mode)",
--[[Translation missing --]]
	["fade_non_target_alpha"] = "Opacity other frames will fade to when you have a target.|n|nInvisible nameplates can still be clicked.",
--[[Translation missing --]]
	["fade_speed"] = "Speed of the frame fading animation, where 1 is slowest and 0 is instant",
--[[Translation missing --]]
	["fade_untracked"] = "Fade non-tracked nameplates by default (including those in name-only mode).|n|nWhether or not a unit is tracked can by set by changing the \"NPC Names\" dropdown and other checkboxes in the default interface options under Esc > Interface > Names",
--[[Translation missing --]]
	["font_face"] = "Fonts are provided by LibSharedMedia.",
--[[Translation missing --]]
	["font_size_normal"] = "Used for name, level, health and auras.",
--[[Translation missing --]]
	["font_size_small"] = "Used for guild and spell name.",
--[[Translation missing --]]
	["frame_glow_threat"] = "Change the colour of the frame glow to indicate threat status",
--[[Translation missing --]]
	["frame_height"] = "Height of the standard nameplates",
--[[Translation missing --]]
	["frame_height_minus"] = "Height of nameplates used on mobs flagged as \"minus\" (previously referred to as trivial), as well as nameless frames (i.e. \"unimportant\" units)",
--[[Translation missing --]]
	["frame_height_personal"] = "Height of the personal nameplate (enabled by Esc > Interface > Names > Personal Resource Display)",
--[[Translation missing --]]
	["frame_width"] = "Width of the standard nameplates",
--[[Translation missing --]]
	["frame_width_minus"] = "Width of nameplates used on mobs flagged as \"minus\" (previously referred to as trivial)",
--[[Translation missing --]]
	["frame_width_personal"] = "Width of the personal nameplate (enabled by Esc > Interface > Names > Personal Resource Display)",
--[[Translation missing --]]
	["global_scale"] = "Scale all nameplates by this amount (obeying the pixel grid)",
--[[Translation missing --]]
	["guild_text_npcs"] = "Such as Flight Master, Quartermaster, etc.",
--[[Translation missing --]]
	["health_text_friend_dmg"] = "Health text format used on damaged friendly units",
--[[Translation missing --]]
	["health_text_friend_max"] = "Health text format used on friendly units at full health",
--[[Translation missing --]]
	["health_text_hostile_dmg"] = "Health text format used on damaged hostile units",
--[[Translation missing --]]
	["health_text_hostile_max"] = "Health text format used on hostile units at full health",
--[[Translation missing --]]
	["hide_names"] = "Whether or not a unit is tracked can be set by changing the \"NPC Names\" dropdown and other checkboxes in the default interface options under Esc > Interface > Names.|n|nThis does not affect name-only mode.",
--[[Translation missing --]]
	["ignore_uiscale"] = "Fix pixel alignment issues related to interface scaling. Compensate for the size difference by adjusting /knp > frame sizes > global scale.|n|nThis is necessary even if you do not have UI scale enabled.",
--[[Translation missing --]]
	["name_colour_white_in_bar_mode"] = "Colour NPC's and player's names white (unless class colour is enabled).|n|nIf this is enabled, the colours below only apply to name-only mode.",
--[[Translation missing --]]
	["nameonly_combat_hostile"] = "Note that this doesn't apply to training dummies or other units which don't have a threat table",
	["nameonly_health_colour"] = "Colorir parcialmente o texto para representar a porcentagem de vida.",
	["nameonly_neutral"] = "Usar apenas-nomes em unidades neutras atacáveis.",
	["nameonly_no_font_style"] = [=[Ocultar o contorno do texto quando estiver no modo apenas-nomes (definindo o estilo da fonte como nulo).
]=],
	["nameonly_target"] = "Também usar apenas-nomes no seu alvo.",
--[[Translation missing --]]
	["powerbar_height"] = "Height of the power bar on the personal frame. Will not increase beyond frame height",
--[[Translation missing --]]
	["state_icons"] = "Show an icon on bosses and rare units (hidden when level text is shown)",
--[[Translation missing --]]
	["tank_mode"] = "Recolour the health bars of units you are actively tanking when in a tanking specialisation",
--[[Translation missing --]]
	["tankmode_force_enable"] = "Always use tank mode, even if you're not currently in a tanking specialisation",
--[[Translation missing --]]
	["tankmode_force_offtank"] = "Colour bars being tanked by other tanks in your group, even if you're not currently in a tanking specialisation",
--[[Translation missing --]]
	["tankmode_other_colour"] = "Health bar colour to use when another tank is tanking.|n|nThis is only used if you are currently in a tanking specialisation, and requires the other tank to be in your group and to have their group role set to tank.",
--[[Translation missing --]]
	["tankmode_tank_colour"] = "Health bar colour to use when securely tanking",
--[[Translation missing --]]
	["tankmode_trans_colour"] = "Health bar colour to use when gaining or losing threat",
--[[Translation missing --]]
	["target_arrows"] = "Show arrows around your current target. These inherit the target glow colour set above.",
--[[Translation missing --]]
	["text_vertical_offset"] = "Vertical offset applied to all strings. Can be used to compensate for fonts which render at odd vertical positions in WoW.",
--[[Translation missing --]]
	["threat_brackets"] = "Show triangles around nameplates to indicate threat status",
--[[Translation missing --]]
	["use_blizzard_personal"] = "Don't skin the personal nameplate or its class powers.|n|nRequires a UI reload.",
}
