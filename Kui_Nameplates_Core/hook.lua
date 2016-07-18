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
-- messages ####################################################################
function core:Create(f)
    self:CreateBackground(f)
    self:CreateHealthBar(f)
    self:CreatePowerBar(f)
    self:CreateFrameGlow(f)
    self:CreateTargetGlow(f)
    self:CreateNameText(f)
    self:CreateLevelText(f)
    self:CreateGuildText(f)
    self:CreateHealthText(f)
    self:CreateHighlight(f)
    self:CreateCastBar(f)
    self:CreateAuras(f)
    self:CreateThreatBrackets(f)
    self:CreateStateIcon(f)
    self:CreateRaidIcon(f)
end
function core:Show(f)
    f.state.player = UnitIsUnit(f.unit,'player')
    f.state.friend = UnitIsFriend('player',f.unit)
    f.state.enemy = UnitIsEnemy('player',f.unit)

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
    -- show/hide threat brackets
    f:UpdateThreatBrackets()
    -- set name text colour
    f:UpdateNameText()
    -- show/hide level text
    f:UpdateLevelText()
    -- show/hide, set initial health text
    f:UpdateHealthText()
    -- set state icon
    f:UpdateStateIcon()
    -- position raid icon
    f:UpdateRaidIcon()
    -- enable/disable castbar
    f:UpdateCastBar()
end
function core:Hide(f)
    self:NameOnlyUpdate(f,true)
end
function core:HealthUpdate(f)
    f:UpdateHealthText()

    self:NameOnlyHealthUpdate(f)
end
function core:HealthColourChange(f)
    f.state.friend = UnitIsFriend('player',f.unit)
    f.state.enemy = UnitIsEnemy('player',f.unit)

    -- update nameonly upon faction changes
    self:NameOnlyUpdate(f)
    self:NameOnlyUpdateFunctions(f)
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
    self:NameOnlyUpdate(f,true)
    -- show name on target
    self:ShowNameUpdate(f)

    f:UpdateFrameSize()
    f:UpdateLevelText()
    self:NameOnlyUpdateFunctions(f)
end
function core:LostTarget(f)
    f.state.target = nil

    -- toggle nameonly depending on state
    self:NameOnlyUpdate(f)
    -- hide name depending on state
    self:ShowNameUpdate(f)

    f:UpdateFrameSize()
    f:UpdateLevelText()
    self:NameOnlyUpdateFunctions(f)
end
function core:ClassificationChanged(f)
    f:UpdateStateIcon()
end
function core:RaidIconUpdate(f)
    -- registered by configChanged, fade_avoid_raidicon
    f:UpdateRaidIcon()
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
            frame:UpdateLevelText()
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
    self:InitialiseConfig()

    -- TODO resets upon changing any interface options
    C_NamePlate.SetNamePlateOtherSize(100,20)

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
    self:RegisterMessage('ClassificationChanged')

    -- register events
    self:RegisterEvent('QUESTLINE_UPDATE')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')

    -- register callbacks
    self:AddCallback('Auras','PostCreateAuraButton',self.Auras_PostCreateAuraButton)
    self:AddCallback('Auras','DisplayAura',self.Auras_DisplayAura)
    self:AddCallback('ClassPowers','PostPositionFrame',self.ClassPowers_PostPositionFrame)

    -- update layout's locals with configuration
    self:SetLocals()

    -- set element configuration tables
    self:InitialiseElements()
end
