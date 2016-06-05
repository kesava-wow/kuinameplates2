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
    self:CreatePowerBar(f)
    self:CreateFrameGlow(f)
    self:CreateTargetGlow(f)
    self:CreateNameText(f)
    self:CreateGuildText(f)
    self:CreateHighlight(f)
    self:CreateCastBar(f)
    self:CreateAuras(f)
    self:CreateThreatBrackets(f)
end
function core:Show(f)
    f.state.player = UnitIsUnit(f.unit,'player')

    -- go into nameonly mode if desired
    self:NameOnlyUpdate(f)
    -- hide name if desired
    self:ShowNameUpdate(f)
    -- show/hide power bar
    f:UpdatePowerBar(true)
    -- set initial frame size
    f:UpdateFrameSize()
    -- set initial glow colour
    f:UpdateFrameGlow()
    -- set name text colour
    f:UpdateNameText()
end
function core:Hide(f)
    self:NameOnlyUpdate(f,true)
end
function core:HealthUpdate(f)
    self:NameOnlyHealthUpdate(f)
end
function core:HealthColourChange(f)
    -- update nameonly upon faction changes
    self:NameOnlyUpdate(f)

    f:UpdateNameText()
    f:UpdateFrameGlow()
end
function core:PowerUpdate(f)
    f:UpdatePowerBar()
end
function core:GlowColourChange(f)
    f:UpdateFrameGlow()
    f:UpdateThreatBrackets()
end
function core:CastBarShow(f)
    f:ShowCastBar()
end
function core:CastBarHide(f)
    f:HideCastBar()
end
function core:GainedTarget(f)
    f.state.target = true

    -- disable nameonly on target
    self:NameOnlyUpdate(f)
    -- show name on target
    self:ShowNameUpdate(f)

    f:UpdateFrameSize()
    f:UpdateNameText()
    f:UpdateFrameGlow()
end
function core:LostTarget(f)
    f.state.target = nil

    -- toggle nameonly depending on state
    self:NameOnlyUpdate(f)
    -- hide name depending on state
    self:ShowNameUpdate(f)

    f:UpdateFrameSize()
    f:UpdateNameText()
    f:UpdateFrameGlow()
end
-- events ######################################################################
function core:QUESTLINE_UPDATE()
    -- TODO this isn't really the right event, but the others fire too soon
    -- update to show name of new quest NPCs
    for _,frame in addon:Frames() do
        if frame:IsShown() then
            self:ShowNameUpdate(frame)
            frame:UpdateFrameSize()
            frame:UpdateNameText()
        end
    end
end
function core:UNIT_THREAT_LIST_UPDATE(event,f)
    -- update to show name of units which are in combat with the player
    self:ShowNameUpdate(f)
    f:UpdateFrameSize()
    f:UpdateNameText()
end
function core:UNIT_NAME_UPDATE(event,f)
    -- update name text colour
    f:UpdateNameText()
end
-- register ####################################################################
function core:Initialise()
    -- element configuration
    self.Auras = {
        font = self.font
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
