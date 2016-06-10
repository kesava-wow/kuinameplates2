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
    self:CreateGuildText(f)
    self:CreateHighlight(f)
    self:CreateCastBar(f)
    self:CreateAuras(f)
    self:CreateThreatBrackets(f)
    self:CreateStateIcon(f)
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
    -- show/hide threat brackets
    f:UpdateThreatBrackets()
    -- set name text colour
    f:UpdateNameText()
    -- set state icon
    f:UpdateStateIcon()
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
    f:UpdateStateIcon()
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
    f:UpdateStateIcon()
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
    f:UpdateStateIcon()
end
function core:ClassificationChanged(f)
    f:UpdateStateIcon()
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
    -- TODO resets upon changing any interface options
    C_NamePlate.SetNamePlateOtherSize(100,20)

    -- element configuration
    self.Auras = {
        font = self.font
    }

    self.ClassPowers = {
        icon_size = 10,
        icon_texture = 'interface/addons/kui_nameplates/media/combopoint-round',
        glow_texture = 'interface/addons/kui_nameplates/media/combopoint-glow',
        cd_texture = 'interface/playerframe/classoverlay-runecooldown',
        point = { 'TOP','bg','BOTTOM',0,4 }
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
    self:RegisterMessage('ClassificationChanged')

    -- register events
    self:RegisterEvent('QUESTLINE_UPDATE')
    self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE')
    self:RegisterUnitEvent('UNIT_NAME_UPDATE')

    -- register callbacks
    self:AddCallback('Auras','PostCreateAuraButton',self.Auras_PostCreateAuraButton)
    --[[
    -- TODO callback testing
    self:AddCallback('Auras','CreateAuraButton',function(parent)
        button = CreateFrame('Frame',nil,parent)
        button:SetWidth(parent.size)
        button:SetHeight(parent.icon_height)

        local icon = button:CreateTexture(nil, 'ARTWORK', nil, 1)
        icon:SetTexCoord(0,1,0,1)

        local bg = button:CreateTexture(nil, 'ARTWORK', nil, 0)
        bg:SetTexture('interface/buttons/white8x8')
        bg:SetVertexColor(1,1,1,1)
        bg:SetAllPoints(button)

        icon:SetPoint('TOPLEFT',bg,'TOPLEFT',1,-1)
        icon:SetPoint('BOTTOMRIGHT',bg,'BOTTOMRIGHT',-1,1)

        local cd = button:CreateFontString(nil,'OVERLAY')
        cd:SetFont(kui.m.f.francois,20,'OUTLINE')
        cd:SetPoint('CENTER')

        local count = button:CreateFontString(il,'OVERLAY')
        cd:SetFont(kui.m.f.francois,20,'OUTLINE')
        count:SetPoint('BOTTOMRIGHT', 2, -2)
        count:Hide()

        button.icon   = icon
        button.cd     = cd
        button.count  = count

        return button
    end)
    ]]

    -- layout configuration stuff
    self:InitialiseConfig()
end
