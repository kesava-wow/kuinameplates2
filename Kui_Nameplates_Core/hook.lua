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

-- positioned and "shown" on the player's frame when/if it is shown
local anchor = CreateFrame('Frame','KuiNameplatesPlayerAnchor')
anchor:Hide()

if addon.draw_frames then
    anchor:SetBackdrop({ edgeFile = kui.m.t.solid, edgeSize = 1 })
    anchor:SetBackdropBorderColor(0,0,1)
end

local plugin_fading
local plugin_classpowers
-- messages ####################################################################
function core:Create(f)
    self:CreateBackground(f)
    self:CreateHealthBar(f)
    self:CreatePowerBar(f)
    self:CreateAbsorbBar(f)
    self:CreateFrameGlow(f)
    self:CreateTargetGlow(f)
    self:CreateTargetArrows(f)
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
    self:CreateNameOnlyGlow(f)
end
function core:Show(f)
    -- state helpers
    f.state.player = UnitIsUnit(f.unit,'player')
    f.state.friend = UnitIsFriend('player',f.unit)
    f.state.class = select(2,UnitClass(f.unit))

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
    -- enable/disable auras
    f:UpdateAuras()
    -- set guild text
    f:UpdateGuildText()

    if f.TargetArrows then
        -- show/hide target arrows
        f:UpdateTargetArrows()
    end

    if f.state.player then
        anchor:SetParent(f)
        anchor:SetAllPoints(f.bg)
        anchor:Show()

        if addon.ClassPowersFrame and plugin_classpowers.enabled then
            -- force class powers position update
            -- as our post function uses state.player
            plugin_classpowers:TargetUpdate()
        end
    end
end
function core:Hide(f)
    if f.state.player then
        anchor:ClearAllPoints()
        anchor:Hide()
    end

    self:NameOnlyUpdate(f,true)
end
function core:HealthUpdate(f)
    f:UpdateHealthText()

    self:NameOnlyHealthUpdate(f)
end
function core:HealthColourChange(f)
    f.state.friend = UnitIsFriend('player',f.unit)

    -- update nameonly upon faction changes
    self:NameOnlyUpdate(f)
    self:NameOnlyUpdateFunctions(f)
end
function core:PowerTypeUpdate(f)
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
    plugin_fading:UpdateFrame(f)
end
function core:ExecuteUpdate(f)
    -- registered by configChanged, fade_avoid_execute_friend/hostile
    plugin_fading:UpdateFrame(f)
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
    -- enable/disable nameonly if enabled on enemies
    self:NameOnlyCombatUpdate(f)

    -- update to show name of units which are in combat with the player
    self:ShowNameUpdate(f)
    f:UpdateFrameSize()
    f:UpdateNameText()
end
function core:UNIT_NAME_UPDATE(event,f)
    -- update name text colour
    f:UpdateNameText()
end
-- #############################################################################
local CreateLODHandler
do
    local opt,saved_command
    local function LoadConfig()
        if IsAddOnLoaded('Kui_Nameplates_Core_Config') then return end
        if InCombatLockdown() then
            print('|cff9966ffKui Nameplates|r: Delaying configuration load until after combat ends.')
            opt:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        opt:SetScript('OnShow',nil)
        opt:SetScript('OnEvent',nil)
        opt:UnregisterEvent('PLAYER_REGEN_ENABLED')

        SLASH_KUINAMEPLATES_LOD1 = nil
        SLASH_KUINAMEPLATES_LOD2 = nil
        SlashCmdList.KUINAMEPLATES_LOD = nil
        hash_SlashCmdList["/kuinameplates"] = nil
        hash_SlashCmdList["/knp"] = nil

        return LoadAddOn('Kui_Nameplates_Core_Config')
    end
    local function lod_OnShow(self)
        if LoadConfig() then
            -- re-trigger OnShow of config elements as page is already open
            self:Hide()
            self:Show()
        end
    end
    local function lod_OnEvent(self,event)
        if event == 'PLAYER_REGEN_ENABLED' then
            if LoadConfig() then
                SlashCmdList.KUINAMEPLATESCORE(saved_command)
                saved_command = nil
            end
        end
    end
    local function lod_Slash(msg)
        if InCombatLockdown() then
            -- save command to passthrough upon leaving combat
            saved_command = msg
        end
        if LoadConfig() then
            -- passthrough command
            SlashCmdList.KUINAMEPLATESCORE(msg)
        end
    end

    function CreateLODHandler()
        -- create LOD slash commands
        SLASH_KUINAMEPLATES_LOD1 = '/knp'
        SLASH_KUINAMEPLATES_LOD2 = '/kuinameplates'
        SlashCmdList.KUINAMEPLATES_LOD = lod_Slash

        -- create options category
        opt = CreateFrame('Frame','KuiNameplatesCoreConfig',InterfaceOptionsFramePanelContainer)
        opt:Hide()
        opt.name = 'Kui |cff9966ffNameplates Core'

        opt:SetScript('OnShow',lod_OnShow)
        opt:SetScript('OnEvent',lod_OnEvent)

        InterfaceOptions_AddCategory(opt)
    end
end
-- register ####################################################################
function core:Initialise()
    self:InitialiseConfig()

    -- we don't want the distance scaling to affect the clickbox
    SetCVar('NameplateMinScale',1)
    SetCVar('NameplateMaxScale',1)

    -- register messages
    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')
    self:RegisterMessage('HealthUpdate')
    self:RegisterMessage('HealthColourChange')
    self:RegisterMessage('PowerTypeUpdate')
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
    self:AddCallback('ClassPowers','CreateBar',self.ClassPowers_CreateBar)

    -- update layout's locals with configuration
    self:SetLocals()

    -- set element configuration tables
    self:InitialiseElements()

    CreateLODHandler()

    plugin_fading = addon:GetPlugin('Fading')
    plugin_classpowers = addon:GetPlugin('ClassPowers')
end
