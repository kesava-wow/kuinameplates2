local L = KuiNameplatesCoreConfig:Locale('ptBR')
if not L then return end

L["page_names"] = {
	["auras"] = "Auras",
	["bossmod"] = "Boss mods.",
	["castbars"] = "Barras de lançamento",
	["classpowers"] = "Recursos de classe",
	["nameonly"] = "Apenas-nomes",
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
	["classpowers_enable"] = "Mostrar recursos de classe",
	["combat_friendly"] = "Ação em combate: aliados",
	["combat_hostile"] = "Ação em combate: inimigos",
	["cvar_name_only"] = "Esconder a barra de vida padrão",
	["cvar_personal_show_combat"] = [=[Mostrar placa de identificação pessoal quando em combate
]=],
	["dd_combat_toggle_hide"] = [=[Esconder, depois mostrar
]=],
	["dd_combat_toggle_nothing"] = "Não fazer nada",
	["dd_combat_toggle_show"] = "Mostrar, depois esconder",
	["fade_avoid_nameonly"] = "Em apenas-nomes",
	["nameonly"] = "Usar modo de apenas-nomes",
	["nameonly_all_enemies"] = "Em inimigos",
	["nameonly_damaged_friends"] = "Em aliados feridos",
	["nameonly_enemies"] = "Em inimigos inatacáveis",
	["nameonly_health_colour"] = "Cor da vida",
	["nameonly_neutral"] = "Em inimigos neutros",
	["nameonly_no_font_style"] = [=[Nenhum contorno de texto
]=],
	["nameonly_target"] = "No alvo",
	["nameonly_text_sep"] = "Texto",
	["nameonly_visibility_sep"] = "Visiblidade",
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
	["cvar_name_only"] = [=[|cffffcc00nameplateShowOnlyNames|r|n|nOculte a barra de vida das placas de identificação padrão em situações em que placas de identificação aliadas ​​não podem ser alteradas de outra forma por addons.
]=],
	["nameonly_health_colour"] = "Colorir parcialmente o texto para representar a porcentagem de vida.",
	["nameonly_no_font_style"] = [=[Ocultar o contorno do texto quando estiver no modo apenas-nomes (definindo o estilo da fonte como nulo).
]=],
	["nameonly_target"] = "Também usar apenas-nomes no seu alvo.",
}
