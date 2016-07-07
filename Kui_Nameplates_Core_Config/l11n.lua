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
    nameonly = 'Hide the healthbars of friendly or unattackable units',
    hide_names = 'Whether or not a unit is "unimportant" can be set by changing the default interface options under "Names"',
    tank_mode = 'Recolour the health bars of units you are actively tanking',
    threat_brackets = 'Show triangles around nameplates which indicate threat status',

    frame_width = 'Width of the standard nameplates',
    frame_height = 'Height of the standard nameplates',
    frame_width_minus = 'Width of nameplates used on low-health mobs',
    frame_height_minus = 'Height of nameplates used on low-health mobs',

    castbar_showpersonal = 'Show the castbar on your character\'s nameplate if it is enabled',
    castbar_showall = 'Show castbars on all nameplates, rather than on just the current target',
    castbar_showfriend = 'Show castbars on friendly nameplates',
}
opt.titles = {
    nameonly = 'Use nameonly mode',
    hide_names = 'Hide unimportant unit names',
    tank_mode = 'Enable tank mode',
    threat_brackets = 'Show threat brackets',
    profile = 'Profile',
    new_profile = 'New profile...',

    frame_width = 'Frame width',
    frame_height = 'Frame height',
    frame_width_minus = 'Minus frame width',
    frame_height_minus = 'Minus frame height',

    castbar_showpersonal = 'Show own castbar',
    castbar_showall = 'Show castbars on all nameplates',
    castbar_showfriend = 'Show friendly castbars',
}
