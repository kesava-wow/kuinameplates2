--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- element create/update functions
--------------------------------------------------------------------------------
local folder,ns=...
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local core = KuiNameplatesCore
-- create functions ############################################################
function core:CreateHealthBar(f)
    local healthbar = CreateFrame('StatusBar',nil,f)
    healthbar:SetStatusBarTexture(kui.m.t.bar)
    healthbar:SetFrameLevel(0)

    healthbar:SetSize(130,10)
    healthbar:SetPoint('CENTER')

    f.handler:SetBarAnimation(healthbar,'cutaway')
    f.handler:RegisterElement('HealthBar',healthbar)
end
