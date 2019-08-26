-- luacheck:globals SLASH_KUINAMEPLATES_LOD1 SLASH_KUINAMEPLATES_LOD2
-- luacheck:globals KuiNameplatesCore
--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- handle messages, events, initialise
--------------------------------------------------------------------------------
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')

KuiNameplatesCore = addon:Layout()
local core = KuiNameplatesCore

if not core then
    -- another layout is already loaded
    return
end

local plugin_fading
-- messages ####################################################################
function core:Create(f)
    self:CreateBackground(f)
    self:CreateHealthBar(f)
    self:CreatePowerBar(f)
    self:CreateAbsorbBar(f)
    self:CreateFrameGlow(f)
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
    f.state.friend = UnitIsFriend('player',f.unit)
    f.state.class = select(2,UnitClass(f.unit))
    f.state.player = UnitIsPlayer(f.unit)

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
    -- set guild text
    f:UpdateGuildText()

    if f.TargetArrows then
        -- show/hide target arrows
        f:UpdateTargetArrows()
    end
end
function core:Hide(f)
    self:NameOnlyUpdate(f,true)
    f:HideCastBar(nil,true)
end
function core:HealthUpdate(f)
    f:UpdateHealthText()

    self:NameOnlyHealthUpdate(f)
end
function core:HealthColourChange(f)
    f.state.friend = UnitIsFriend('player',f.unit)

    -- update nameonly upon faction changes
    self:NameOnlyCombatUpdate(f)
end
function core:PowerTypeUpdate(f)
    f:UpdatePowerBar()
end
function core:GlowColourChange(f)
    -- update nameonly upon threat state changes
    self:NameOnlyCombatUpdate(f)

    -- update to show name of units which are in combat with the player
    self:ShowNameUpdate(f)
    f:UpdateFrameSize()
    f:UpdateNameText()
end
function core:CastBarShow(f)
    f:ShowCastBar()
end
function core:CastBarHide(f,...)
    f:HideCastBar(...)
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
function core:OnEnter(f)
    f:UpdateHighlight()
end
function core:OnLeave(f)
    f:UpdateHighlight()
end
function core:Combat(f)
    -- enable/disable nameonly if enabled on enemies
    self:NameOnlyCombatUpdate(f)
end
-- events ######################################################################
function core:QUEST_POI_UPDATE()
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
function core:UNIT_NAME_UPDATE(_,f)
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
-- fade rules ##################################################################
do
    local avoid_cast_friend,avoid_cast_hostile,
          avoid_cast_interrupt,avoid_cast_uninterrupt,
          friendly_npc_exclude_titled

    -- table for simple rules where profile_key = {
    --   function,
    --   priority,
    --   post-add function or nil
    -- }
    local fade_rules = {}
    fade_rules.fade_all = function()
        plugin_fading:RemoveFadeRule('no_target')
    end
    fade_rules.fade_avoid_mouseover = { function(f)
        return f.state.highlight and 1
    end, 1 }
    fade_rules.fade_avoid_raidicon = { function(f)
        return f.RaidIcon and f.RaidIcon:IsShown() and 1
    end, 1, function() core:RegisterMessage('RaidIconUpdate') end }
    fade_rules.fade_avoid_execute_friend = { function(f)
        return f.state.friend and
               f.state.in_execute_range and 1
    end, 21, function() core:RegisterMessage('ExecuteUpdate') end }
    fade_rules.fade_avoid_execute_hostile = { function(f)
        return not f.state.friend and
               f.state.in_execute_range and 1
    end, 21, function() core:RegisterMessage('ExecuteUpdate') end }
    fade_rules.fade_avoid_tracked = { function(f)
        return f.state.tracked and 1
    end, 22 }
    fade_rules.fade_avoid_combat = { function(f)
        return UnitAffectingCombat(f.unit) and 1
    end, 23 }
    fade_rules.fade_neutral_enemy = { function(f)
        return f.state.reaction == 4 and
               UnitCanAttack('player',f.unit) and -1
    end, 25 }
    fade_rules.fade_friendly_npc = { function(f)
        if  f.state.reaction >= 4 and
            not UnitIsPlayer(f.unit) and
            -- (^ this can't use the layout's state helper)
            not UnitCanAttack('player',f.unit)
        then
            return (not friendly_npc_exclude_titled or
                    not f.state.guild_text) and -1
        end
    end, 25 }
    fade_rules.fade_untracked = { function(f)
        return not f.state.tracked and -1
    end, 25 }
    fade_rules.fade_avoid_nameonly = { function(f)
        return f.IN_NAMEONLY and 1
    end, 30 }

    -- casting fade rule helpers
    local function FadeRule_Casting_Interruptible(f)
        if f.cast_state.interruptible then
            return avoid_cast_interrupt and 1 or nil
        else
            return avoid_cast_uninterrupt and 1 or nil
        end
    end
    local function FadeRule_Casting_CanAttack(f)
        if UnitCanAttack('player',f.unit) then
            return avoid_cast_hostile and FadeRule_Casting_Interruptible(f) or nil
        else
            return avoid_cast_friend and FadeRule_Casting_Interruptible(f) or nil
        end
    end

    function core:InitialiseFadeRules()
        self:UnregisterMessage('RaidIconUpdate')
        self:UnregisterMessage('ExecuteUpdate')

        friendly_npc_exclude_titled = self.profile.fade_friendly_npc_exclude_titled

        if self.profile.fade_avoid_casting_interruptible or
           self.profile.fade_avoid_casting_uninterruptible
        then
            avoid_cast_friend = self.profile.fade_avoid_casting_friendly
            avoid_cast_hostile = self.profile.fade_avoid_casting_hostile
            avoid_cast_interrupt = self.profile.fade_avoid_casting_interruptible
            avoid_cast_uninterrupt = self.profile.fade_avoid_casting_uninterruptible
            plugin_fading:AddFadeRule(function(f)
                if f.state.casting then
                    return FadeRule_Casting_CanAttack(f)
                end
            end,24,'core_fade_avoid_casting')
        end

        for rule_name,rule_tbl in pairs(fade_rules) do
            if self.profile[rule_name] then
                if type(rule_tbl) == 'function' then
                    -- simple function
                    rule_tbl()
                else
                    -- complete rule
                    plugin_fading:AddFadeRule(
                        rule_tbl[1],
                        rule_tbl[2],
                        'core_'..rule_name)

                    if rule_tbl[3] then
                        -- run post-add
                        rule_tbl[3]()
                    end
                end
            end
        end
    end
end
-- register ####################################################################
function core:Initialise()
    plugin_fading = addon:GetPlugin('Fading')

    self:InitialiseConfig()

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
    self:RegisterMessage('OnEnter')
    self:RegisterMessage('OnLeave')
    self:RegisterMessage('Combat')

    -- register events
    if not kui.CLASSIC then
        self:RegisterEvent('QUEST_POI_UPDATE')
    end

    self:RegisterUnitEvent('UNIT_NAME_UPDATE')

    -- register callbacks
    self:AddCallback('Auras','PostCreateAuraButton',self.Auras_PostCreateAuraButton)
    self:AddCallback('Auras','PostDisplayAuraButton',self.Auras_PostDisplayAuraButton)
    self:AddCallback('Auras','PostUpdateAuraFrame',self.Auras_PostUpdateAuraFrame)
    self:AddCallback('Auras','DisplayAura',self.Auras_DisplayAura)
    self:AddCallback('ClassPowers','PostPositionFrame',self.ClassPowers_PostPositionFrame)
    self:AddCallback('ClassPowers','CreateBar',self.ClassPowers_CreateBar)

    -- set element configuration tables
    self:InitialiseElements()

    CreateLODHandler()
end
