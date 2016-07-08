--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
local folder,ns=...
local kui = LibStub('Kui-1.0')
local kc = LibStub('KuiConfig-1.0')
local addon = KuiNameplates
local core = KuiNameplatesCore
-- default configuration #######################################################
local default_config = {
    nameonly = true,

    hide_names = true,
    font_size_normal = 11,
    font_size_small = 9,

    frame_width = 132,
    frame_height = 13,
    frame_width_minus = 72,
    frame_height_minus = 9,

    castbar_enable = true,
    castbar_showpersonal = false,
    castbar_showall = true,
    castbar_showfriend = true,
    castbar_showenemy = true,

    tank_mode = true,
    threat_brackets = false,
}
-- config changed functions ####################################################
-- TODO need to apply this stuff on init
local configChanged = {}
function configChanged.tank_mode(v)
    if v then
        addon:GetPlugin('TankMode'):Enable()
    else
        addon:GetPlugin('TankMode'):Disable()
    end
end

function configChanged.castbar_enable(v)
    if v then
        addon:GetPlugin('CastBar'):Enable()
    else
        addon:GetPlugin('CastBar'):Disable()
    end
end

local function configChangedFrameSize()
    core:configChangedFrameSize()
end
configChanged.frame_width = configChangedFrameSize
configChanged.frame_height = configChangedFrameSize
configChanged.frame_width_minus = configChangedFrameSize
configChanged.frame_height_minus = configChangedFrameSize

local function configChangedFontOption()
    core:configChangedFontOption()
end
configChanged.font_face = configChangedFontOption
configChanged.font_size_normal = configChangedFontOption
configChanged.font_size_small = configChangedFontOption
-- init config #################################################################
function core:InitialiseConfig()
    self.config = kc:Initialise('KuiNameplatesCore',default_config)
    self.profile = self.config:GetConfig()

    self.config:RegisterConfigChanged(function(self,k,v)
        core.profile = self:GetConfig()

        if configChanged[k] then
            configChanged[k](v)
        end

        for i,f in addon:Frames() do
            if f:IsShown() then
                f.handler:OnHide()
                f.handler:OnUnitAdded(f.parent.namePlateUnitToken)
            end
        end
    end)

    -- inform config addon that the config table is available if it's loaded
    if KuiNameplatesCoreConfig then
        KuiNameplatesCoreConfig:LayoutLoaded()
    end
end
