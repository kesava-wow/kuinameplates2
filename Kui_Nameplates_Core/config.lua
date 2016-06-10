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
    tank_mode = true,
    threat_brackets = false,
}
-- config changed functions ####################################################
local configChanged = {}
function configChanged.tank_mode(v)
    if v then
        addon:GetPlugin('TankMode'):Enable()
    else
        addon:GetPlugin('TankMode'):Disable()
    end
end
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
