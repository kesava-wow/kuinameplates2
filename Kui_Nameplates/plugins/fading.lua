--[[
-- Fade nameplates based on rules
--
-- Return values:
-- 1   = stop iterating, fade to 1
-- 0   = stop iterating, fade to 0
-- -1  = stop iterating, fade to mod.conditional_alpha
-- nil = continue to iterate fade rules table
-- end = fade to mod.non_target_alpha
--
-- Lower priority (1 < 100) = first execution.
-- Rules which result in fading nameplates OUT should generally be between
-- priority 20 and 100, as per the default fade rules set in :ResetFadeRules.
-- ]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Fading')

local abs,pairs,ipairs,type,tinsert = math.abs,pairs,ipairs,type,tinsert
local kff,kffr = kui.frameFade, kui.frameFadeRemoveFrame

local UpdateFrame = CreateFrame('Frame')
local fade_rules,delayed_frames = {},{}
local target_exists

-- local functions #############################################################
local function ResetFrameFade(frame)
    kffr(frame)
    frame.fading_to = nil
end
local function FrameFade(frame,to)
    if frame.fading_to and to == frame.fading_to then return end

    ResetFrameFade(frame)

    local cur_alpha = frame:GetAlpha()
    if to == cur_alpha then return end

    local alpha_change = to - cur_alpha
    frame.fading_to = to

    kff(frame, {
        mode = alpha_change < 0 and 'OUT' or 'IN',
        timeToFade = abs(alpha_change) * mod.fade_speed,
        startAlpha = cur_alpha,
        endAlpha = to,
        finishedFunc = ResetFrameFade
    })
end
local function GetDesiredAlpha(frame)
    for _,f_t in ipairs(fade_rules) do
        if f_t then
            local a = f_t[2](frame)
            if a then
                if a < 0 then
                    return mod.conditional_alpha
                else
                    return a
                end
            end
        end
    end

    return mod.non_target_alpha
end
local function InstantUpdateFrame(f)
    if not f:IsShown() then return end

    if mod.fade_speed > 0 then
        FrameFade(f,GetDesiredAlpha(f))
    else
        f:SetAlpha(GetDesiredAlpha(f))
    end
end
-- update frame ################################################################
local function OnUpdate(self)
    for f,_ in pairs(delayed_frames) do
        delayed_frames[f] = nil
        InstantUpdateFrame(f)
    end

    UpdateFrame:SetScript('OnUpdate',nil)
end
-- mod functions ###############################################################
function mod:UpdateFrame(f)
    -- add frame to delayed update table
    if not self.enabled then return end
    delayed_frames[f] = true
    UpdateFrame:SetScript('OnUpdate',OnUpdate)
end
function mod:UpdateAllFrames()
    -- update alpha of all visible frames
    for _,f in addon:Frames() do
        if f:IsShown() then
            self:UpdateFrame(f)
        end
    end
end
function mod:ResetFadeRules()
    -- reset to default fade rules
    fade_rules = {
        -- don't fade the personal nameplate
        { 10, function(f) return f.state.personal and 1 end, 'avoid_personal' },
        -- don't fade the target nameplate
        { 20, function(f) return f.handler:IsTarget() and 1 end, 'avoid_target' },
        -- fade in all nameplates if there is no target
        { 100, function() return not target_exists and 1 end, 'no_target' },
    }

    -- let plugins re/add their own rules
    mod:RunCallback('FadeRulesReset')
end
function mod:AddFadeRule(func,priority,uid)
    if not self.enabled then return end
    if type(func) ~= 'function' or not tonumber(priority) then
        error('AddFadeRule expects function(function),priority(number)')
    end

    uid = uid and tostring(uid)
    if uid and self:GetFadeRuleIndex(uid) then
        addon:print('fade rule already exists:',uid)
        return
    end

    local insert_tbl = {priority,func,uid}
    local inserted

    for k,f_t in ipairs(fade_rules) do
        if priority < f_t[1] then
            tinsert(fade_rules,k,insert_tbl)
            inserted = true
            break
        end
    end

    if not inserted then
        tinsert(fade_rules,insert_tbl)
    end

    return inserted
end
function mod:RemoveFadeRule(index)
    if tonumber(index) then
        if fade_rules[index] then
            fade_rules[index] = nil
        end
    elseif type(index) == 'string' then
        -- remove by uid
        local i = self:GetFadeRuleIndex(index)
        if i then
            self:RemoveFadeRule(i)
        end
    end
end
function mod:GetFadeRuleIndex(uid)
    if type(uid) ~= 'string' then return end
    for i,f_t in ipairs(fade_rules) do
        if f_t[3] and f_t[3] == uid then
            return i
        end
    end
end
-- messages ####################################################################
function mod:TargetUpdate()
    target_exists = UnitExists('target')
    self:UpdateAllFrames()
end
function mod:Show(f)
    f:SetAlpha(0)
    self:UpdateFrame(f)
end
function mod:Hide(f)
    ResetFrameFade(f)
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterEvent('PLAYER_TARGET_CHANGED','TargetUpdate')
    self:RegisterEvent('PLAYER_ENTERING_WORLD','TargetUpdate')
    self:RegisterMessage('GainedTarget','TargetUpdate')
    self:RegisterMessage('LostTarget','TargetUpdate')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')

    self:ResetFadeRules()
    self:UpdateAllFrames()
end
function mod:OnDisable()
    wipe(delayed_frames)
    wipe(fade_rules)
    UpdateFrame:SetScript('OnUpdate',nil)

    for _,f in addon:Frames() do
        f:SetAlpha(1)
    end
end
function mod:Initialise()
    self:RegisterCallback('FadeRulesReset')

    self.non_target_alpha = .5
    self.conditional_alpha = .3
    self.fade_speed = .5
end
