local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Fading')

local function fadeFrame(frame,to)
    if frame.fading_to and to == frame.fading_to then return end

    if kui.frameIsFading(frame) then
        kui.frameFadeRemoveFrame(frame)
    end

    local cur_alpha = frame:GetAlpha()
    if to == cur_alpha then return end

    local alpha_change = to - cur_alpha
    frame.fading_to = to

    kui.frameFade(frame, {
        mode = alpha_change < 0 and 'OUT' or 'IN',
        timeToFade = abs(alpha_change) * .5,
        startAlpha = cur_alpha,
        endAlpha = to,
        finishedFunc = function()
            frame.fading_to = nil
        end,
    })
end
-- messages ####################################################################
function mod:TargetUpdate()
    local target_exists = UnitExists('target')
    for _,frame in addon:Frames() do
        if not target_exists or frame.handler:IsTarget() then
            fadeFrame(frame,1)
        else
            fadeFrame(frame,.5)
        end
    end
end
function mod:Show(f)
    f:SetAlpha(0)
    self:TargetUpdate()
end
function mod:Hide(f)
    f:SetAlpha(0)
end
-- register ####################################################################
mod:RegisterEvent('PLAYER_TARGET_CHANGED','TargetUpdate')
mod:RegisterMessage('GainedTarget','TargetUpdate')
mod:RegisterMessage('LostTarget','TargetUpdate')
mod:RegisterMessage('Show')
mod:RegisterMessage('Hide')
