--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- handle messages, events, initialise
--------------------------------------------------------------------------------
local folder,ns=...
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')

KuiNameplatesCore = addon:Layout()
local core = KuiNameplatesCore

if not core then
    -- another layout is already loaded
    return
end
-- callbacks ###################################################################
local function Auras_PostCreateAuraButton(button)
    -- move text slightly for our font
    button.cd:ClearAllPoints()
    button.cd:SetPoint('CENTER',1,-1)
    button.cd:SetShadowOffset(1,-1)
    button.cd:SetShadowColor(0,0,0,1)

    button.count:ClearAllPoints()
    button.count:SetPoint('BOTTOMRIGHT',3,-3)
    button.count:SetShadowOffset(1,-1)
    button.count:SetShadowColor(0,0,0,1)
end
-- messages ####################################################################
function core:Create(f)
    self:CreateBackground(f)
    self:CreateHealthBar(f)
    self:CreateFrameGlow(f)
    self:CreateNameText(f)
    self:CreateHighlight(f)
end
function core:Show(f)
    f:UpdateFrameSize()
    f:UpdateFrameGlow()
end
function core:Hide(f)
end
function core:HealthUpdate(f)
end
function core:HealthColourChange(f)
end
function core:PowerUpdate(f,on_show)
end
function core:GlowColourChange(f)
    f:UpdateFrameGlow()
end
function core:CastBarShow(f)
end
function core:CastBarHide(f)
end
function core:GainedTarget(f)
    f:UpdateFrameGlow()
end
function core:LostTarget(f)
    f:UpdateFrameGlow()
end
-- events ######################################################################
function core:QUESTLINE_UPDATE()
end
function core:UNIT_THREAT_LIST_UPDATE(event,f)
end
function core:UNIT_NAME_UPDATE(event,f)
end
-- register ####################################################################
function core:Initialise()
    -- element configuration
    self.Auras = {
        font = FONT
    }

    self.ClassPowers = {
        icon_size = 10,
        icon_texture = 'interface/addons/kui_nameplates/media/combopoint-round',
        glow_texture = 'interface/addons/kui_nameplates/media/combopoint-glow',
        cd_texture = 'interface/playerframe/classoverlay-runecooldown',
        point = { 'TOP','HealthBar','BOTTOM',0,3 }
    }

    -- register messages
    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterMessage('HealthUpdate')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('PowerUpdate')
    self:RegisterMessage('GlowColourChange')
    self:RegisterMessage('CastBarShow')
    self:RegisterMessage('CastBarHide')
    self:RegisterMessage('GainedTarget')
    self:RegisterMessage('LostTarget')

    -- register events
    self:RegisterEvent('QUESTLINE_UPDATE')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')

    -- register callbacks
    self:AddCallback('Auras','PostCreateAuraButton',Auras_PostCreateAuraButton)

    -- layout configuration stuff
    self:InitialiseConfig()
end
