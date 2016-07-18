local folder,ns = ...
local opt = KuiNameplatesCoreConfig
-- strings
opt.page_names = {
    general     = 'General', -- fonts, textures, fading, nameonly, class colours
    text        = 'Text', -- level, health text
    framesizes  = 'Frame sizes',
    auras       = 'Auras',
    castbars    = 'Cast bars',
    classpowers = 'Class powers',
    threat      = 'Threat',
}
opt.tooltips = {
    bar_texture = 'The texture used for status bars (provided by LibSharedMedia)',
    bar_animation = 'The style of animation to use on health/power bars',

    nameonly = 'Hide the healthbars of friendly or unattackable units',
    nameonly_no_font_style = 'Hide text outline when in nameonly mode (by setting the font style to nil)',
    nameonly_damaged_friends = 'Use nameonly mode, even on damaged friendly frames. Their name will be coloured as a percentage of their health',
    nameonly_enemies = 'Use nameonly mode on unattackable enemies (not including enemy players under effects such as Ice Block)',

    fade_alpha = 'Opacity of faded frames',
    fade_speed = 'Speed of the frame fading animation, where 1 is slowest and 0 is instant',
    fade_all = 'Fade all frames out by default, rather than in',
    fade_avoid_nameonly = 'Don\'t fade nameplates which are currently in nameonly mode',
    fade_avoid_raidicon = 'Don\'t fade nameplates which have a raid icon visible',

    hide_names = 'Whether or not a unit is "unimportant" can be set by changing the default interface options under "Names". Note that this does not affect nameonly mode',
    font_face = 'The font used for all strings on nameplates (provided by LibSharedMedia)',
    font_size_normal = 'Standard font size (name, etc)',
    font_size_small = 'Smaller font size (vendor, spell name, etc)',
    text_vertical_offset = 'Vertical offset applied to all strings. Used as some fonts render at odd vertical positions in WoW. Note that this value ends in .5 by default as this helps to reduce vertical jittering when frames are moving',
    name_vertical_offset = 'Vertical offset of the name text',
    bot_vertical_offset = 'Vertical offset of the level and health text strings',

    frame_width = 'Width of the standard nameplates',
    frame_height = 'Height of the standard nameplates',
    frame_width_minus = 'Width of nameplates used on low-health mobs',
    frame_height_minus = 'Height of nameplates used on low-health mobs',

    auras_whitelist = 'Use KuiSpellList to filter spells. You can use the extra addon KuiSpellListConfig from Curse to customise this list',
    auras_pulsate = 'Pulsate icons when they are about to expire',
    auras_time_threshold = 'The countdown text will display when there is less than or equal to this amount of time left on an aura. Set to -1 to always display the timer',
    auras_minimum_length = 'Don\'t show auras with an initial length less than this value',
    auras_maximum_length = 'Don\'t show auras with an initial length greater than this value. Set to -1 to ignore',
    auras_icon_normal_size = 'Icon size on normal-size frames',
    auras_icon_minus_size = 'Icon size on smaller frames',
    auras_icon_squareness = 'Size ratio of the aura icons, where 1 means a perfect square',

    castbar_enable = 'Enable the castbar element',
    castbar_showpersonal = 'Show the castbar on your character\'s nameplate if it is enabled',
    castbar_showall = 'Show castbars on all nameplates, rather than on just the current target',
    castbar_showfriend = 'Show castbars on friendly nameplates (note that castbars are not shown on frames which have nameonly mode active)',
    castbar_showenemy = 'Show castbars on enemy nameplates',

    tank_mode = 'Recolour the health bars of units you are actively tanking when in a tanking specialisation',
    tankmode_force_enable = 'Always use tank mode, even if you\'re not currently in a tanking specialisation',
    threat_brackets = 'Show triangles around nameplates which indicate threat status (this does not require tank mode to be active)',
    tankmode_tank_colour = 'Health bar colour to use when securely tanking',
    tankmode_trans_colour = 'Health bar colour to use when gaining or losing threat',
    tankmode_other_colour = 'Health bar colour to use when another tank is tanking. This requires the other tank to be in your group and to have their group role set to tank',
}
opt.titles = {
    profile = 'Profile',
    new_profile = 'New profile...',
    new_profile_label = 'Enter profile name',
    delete_profile_label = 'Delete profile |cffffffff%s|r?',
    rename_profile_label = 'Enter new name for |cffffffff%s',

    bar_texture = 'Bar texture',
    bar_animation = 'Bar animation',

    nameonly_sep = 'Nameonly mode',
    nameonly = 'Use nameonly mode',
    nameonly_no_font_style = 'No text outline',
    nameonly_damaged_friends = 'On damaged friends',
    nameonly_enemies = 'On unattackable enemies',

    glow_as_shadow = 'Show frame shadow',
    target_glow = 'Show target glow',
    target_glow_colour = 'Target glow colour',

    fade_rules_sep = 'Frame fading',
    fade_alpha = 'Faded alpha',
    fade_speed = 'Fade animation speed',
    fade_all = 'Fade by default',
    fade_avoid_nameonly = 'Avoid nameonly',
    fade_avoid_raidicon = 'Avoid raid icon',

    reaction_colour_sep = 'Reaction colours',
    colour_hated = 'Hated',
    colour_neutral = 'Neutral',
    colour_friendly = 'Friendly',
    colour_tapped = 'Tapped',
    colour_player = 'Player',

    font_face = 'Font face',
    font_style = 'Font style',
    font_size_normal = 'Normal font size',
    font_size_small = 'Small font size',
    hide_names = 'Hide unimportant unit names',
    level_text = 'Show level text',
    health_text = 'Show health text',
    text_vertical_offset = 'Text v.offset',
    name_vertical_offset = 'Name v.offset',
    bot_vertical_offset = 'Level/health v.offset',

    frame_width = 'Frame width',
    frame_height = 'Frame height',
    frame_width_minus = 'Minus frame width',
    frame_height_minus = 'Minus frame height',
    castbar_height = 'Castbar height',

    auras_enabled = 'Show auras',
    auras_whitelist = 'Use whitelist',
    auras_pulsate = 'Pulsate icons',
    auras_filtering_sep = 'Filtering',
    auras_time_threshold = 'Timer threshold',
    auras_minimum_length = 'Minimum effect length',
    auras_maximum_length = 'Maximum effect length',
    auras_icons_sep = 'Icons',
    auras_icon_normal_size = 'Icon size (normal)',
    auras_icon_minus_size = 'Icon size (minus)',
    auras_icon_squareness = 'Icon squareness',

    castbar_enable = 'Enable',
    castbar_showpersonal = 'Show own castbar',
    castbar_showall = 'Show castbars on all nameplates',
    castbar_showfriend = 'Show friendly castbars',
    castbar_showenemy = 'Show enemy castbars',

    tank_mode = 'Enable tank mode',
    tankmode_force_enable = 'Force tank mode',
    threat_brackets = 'Show threat brackets',
    tankmode_colour_sep = 'Bar colours',
    tankmode_tank_colour = 'Tanking',
    tankmode_trans_colour = 'Transitional',
    tankmode_other_colour = 'Offtank',
}
