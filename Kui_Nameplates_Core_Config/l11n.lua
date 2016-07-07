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
}
opt.titles = {
    nameonly = 'Use nameonly mode',
    hide_names = 'Hide unimportant unit names',
    tank_mode = 'Enable tank mode',
    threat_brackets = 'Show threat brackets',
    profile = 'Profile',
    new_profile = 'New profile...',
}
