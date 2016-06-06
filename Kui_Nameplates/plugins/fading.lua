-- fade nameplate frames based on current target
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Fading')

local abs = math.abs
local UnitIsUnit = UnitIsUnit
local kff,kffr = kui.frameFade, kui.frameFadeRemoveFrame
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
        timeToFade = abs(alpha_change) * .5,
        startAlpha = cur_alpha,
        endAlpha = to,
        finishedFunc = ResetFrameFade
    })
end
local function GetDesiredAlpha(frame)
    if  UnitIsUnit(frame.unit,'player') or
        not target_exists or
        frame.handler:IsTarget()
    then
        return 1
    else
        return .5
    end
end
-- messages ####################################################################
function mod:TargetUpdate()
    target_exists = UnitExists('target')
    for _,frame in addon:Frames() do
        if frame:IsVisible() then
            FrameFade(frame,GetDesiredAlpha(frame))
        end
    end
end
function mod:Show(f)
    f:SetAlpha(0)
    FrameFade(f,GetDesiredAlpha(f))
end
function mod:Hide(f)
    ResetFrameFade(f)
end
-- register ####################################################################
mod:RegisterEvent('PLAYER_TARGET_CHANGED','TargetUpdate')
mod:RegisterEvent('PLAYER_ENTERING_WORLD','TargetUpdate')
mod:RegisterMessage('GainedTarget','TargetUpdate')
mod:RegisterMessage('LostTarget','TargetUpdate')
mod:RegisterMessage('Show')
mod:RegisterMessage('Hide')
