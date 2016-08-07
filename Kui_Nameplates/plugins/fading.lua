-- fade nameplate frames based on current target
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Fading')

local abs,pairs,type,tinsert = math.abs,pairs,type,tinsert
local UnitExists,UnitIsUnit = UnitExists,UnitIsUnit
local kff,kffr = kui.frameFade, kui.frameFadeRemoveFrame

local UpdateFrame = CreateFrame('Frame')
local delayed_frames = {}
local target_exists
local fade_rules

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
    for i,f_t in pairs(fade_rules) do
        if f_t then
            local a = f_t[2](frame)
            if a then
                if a < 0 then
                    return mod.faded_alpha
                else
                    return a
                end
            end
        end
    end

    return mod.faded_alpha
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
    delayed_frames[f] = true
    UpdateFrame:SetScript('OnUpdate',OnUpdate)
end
function mod:UpdateAllFrames()
    -- update alpha of all visible frames
    for k,f in addon:Frames() do
        if f:IsShown() then
            self:UpdateFrame(f)
        end
    end
end
function mod:ResetFadeRules()
    -- reset to default fade rules
    fade_rules = {
        { 10, function(f) return UnitIsUnit(f.unit,'player') and 1 end },
        { 20, function(f) return f.handler:IsTarget() and 1 end },
        { 100, function() return not target_exists and 1 end },
    }

    -- let plugins re/add their own rules
    mod:RunCallback('FadeRulesReset')
end
function mod:AddFadeRule(func,priority)
    if type(func) ~= 'function' or not tonumber(priority) then return end

    local inserted

    for k,f_t in ipairs(fade_rules) do
        if priority < f_t[1] then
            tinsert(fade_rules,k,{priority,func})
            inserted = true
            break
        end
    end

    if not inserted then
        tinsert(fade_rules,{priority,func})
    end

    return inserted
end
function mod:RemoveFadeRule(index)
    fade_rules[index] = nil
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
end
function mod:Initialise()
    self:RegisterCallback('FadeRulesReset')

    self.faded_alpha = .5
    self.fade_speed = .5

    self:ResetFadeRules()
end
