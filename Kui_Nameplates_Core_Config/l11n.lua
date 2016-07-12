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
    bar_texture = 'The texture used for the health bar',
    nameonly = 'Hide the healthbars of friendly or unattackable units',
    hide_names = 'Whether or not a unit is "unimportant" can be set by changing the default interface options under "Names"',
    tank_mode = 'Recolour the health bars of units you are actively tanking',
    threat_brackets = 'Show triangles around nameplates which indicate threat status',

    font_face = 'The font used for all strings on nameplates (provided by LibSharedMedia)',
    font_size_normal = 'Standard font size (name, etc)',
    font_size_small = 'Smaller font size (vendor, spell name, etc)',

    frame_width = 'Width of the standard nameplates',
    frame_height = 'Height of the standard nameplates',
    frame_width_minus = 'Width of nameplates used on low-health mobs',
    frame_height_minus = 'Height of nameplates used on low-health mobs',

    castbar_enable = 'Enable the castbar element',
    castbar_showpersonal = 'Show the castbar on your character\'s nameplate if it is enabled',
    castbar_showall = 'Show castbars on all nameplates, rather than on just the current target',
    castbar_showfriend = 'Show castbars on friendly nameplates (note that castbars are not shown on frames which have nameonly mode active)',
    castbar_showenemy = 'Show castbars on enemy nameplates',
}
opt.titles = {
    profile = 'Profile',
    new_profile = 'New profile...',

    bar_texture = 'Bar texture',
    nameonly = 'Use nameonly mode',
    glow_as_shadow = 'Show frame shadow',
    target_glow = 'Show target glow',
    target_glow_colour = 'Target glow colour',

    font_face = 'Font face',
    font_style = 'Font style',
    font_size_normal = 'Normal font size',
    font_size_small = 'Small font size',
    hide_names = 'Hide unimportant unit names',
    level_text = 'Show level text',
    health_text = 'Show health text',

    frame_width = 'Frame width',
    frame_height = 'Frame height',
    frame_width_minus = 'Minus frame width',
    frame_height_minus = 'Minus frame height',

    castbar_enable = 'Enable',
    castbar_showpersonal = 'Show own castbar',
    castbar_showall = 'Show castbars on all nameplates',
    castbar_showfriend = 'Show friendly castbars',
    castbar_showenemy = 'Show enemy castbars',

    tank_mode = 'Enable tank mode',
    threat_brackets = 'Show threat brackets',
}
