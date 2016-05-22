-- provide status bar animations
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BarAnimation')

local anims = {}

local min,max,abs,pairs = math.min,math.max,math.abs,pairs
local GetFramerate = GetFramerate
-- local functions #############################################################
-- cutaway #####################################################################
do
    local function SetValueCutaway(self,value)
        if not self:IsVisible() then
            -- passthrough initial calls
            self:orig_anim_SetValue(value)
            return
        end

        if value < self:GetValue() then
            if not kui.frameIsFading(self.KuiFader) then
                self.KuiFader:SetPoint(
                    'RIGHT', self, 'LEFT',
                    (self:GetValue() / select(2,self:GetMinMaxValues())) * self:GetWidth(), 0
                )

                -- store original rightmost value
                self.KuiFader.right = self:GetValue()
            end

            kui.frameFade(self.KuiFader, {
                mode = 'OUT',
                timeToFade = .3
            })
        end

        if self.KuiFader.right and value > self.KuiFader.right then
            -- stop animation if new value overlaps old end point
            kui.frameFadeRemoveFrame(self.KuiFader)
            self.KuiFader:SetAlpha(0)
        end

        self:orig_anim_SetValue(value)
    end
    local function SetStatusBarColor(self,...)
        self:orig_anim_SetStatusBarColor(...)
        self.KuiFader:SetVertexColor(...)
    end
    local function SetAnimationCutaway(bar)
        local fader = bar:CreateTexture(nil,'ARTWORK')
        fader:SetTexture('interface/buttons/white8x8')
        fader:SetAlpha(0)

        fader:SetPoint('TOP')
        fader:SetPoint('BOTTOM')
        fader:SetPoint('LEFT',bar:GetStatusBarTexture(),'RIGHT')

        bar.orig_anim_SetValue = bar.SetValue
        bar.SetValue = SetValueCutaway

        bar.orig_anim_SetStatusBarColor = bar.SetStatusBarColor
        bar.SetStatusBarColor = SetStatusBarColor

        bar.KuiFader = fader
    end
    local function ClearAnimationCutaway(bar)
        kui.frameFadeRemoveFrame(bar.KuiFader)
        bar.KuiFader:SetAlpha(0)
    end
    anims['cutaway'] = {
        set   = SetAnimationCutaway,
        clear = ClearAnimationCutaway
    }
end
-- smooth ######################################################################
do
    local smoother,smoothing = nil,{}
    local function SetValueSmooth(self,value)
        if not self:IsVisible() then
            self:orig_anim_SetValue(value)
            return
        end

        if value == self:GetValue() then
            smoothing[self] = nil
            self:orig_anim_SetValue(value)
        else
            smoothing[self] = value
        end
    end
    local function SmootherOnUpdate(bar)
        local limit = 30/GetFramerate()

        for bar, value in pairs(smoothing) do
            local cur = bar:GetValue()
            local new = cur + min((value-cur)/3, max(value-cur, limit))

            if cur == value or abs(new-value) < .005 then
                bar:orig_anim_SetValue(value)
                smoothing[bar] = nil
            else
                bar:orig_anim_SetValue(new)
            end
        end
    end
    local function SetAnimationSmooth(bar)
        if not smoother then
            smoother = CreateFrame('Frame')
            smoother:SetScript('OnUpdate',SmootherOnUpdate)
        end

        bar.orig_anim_SetValue = bar.SetValue
        bar.SetValue = SetValueSmooth
    end
    local function ClearAnimationSmooth(bar)
        if smoother and smoothing[bar] then
            smoothing[bar] = nil
        end
    end
    anims['smooth'] = {
        set   = SetAnimationSmooth,
        clear = ClearAnimationSmooth
    }
end
-- prototype additions #########################################################
function addon.Nameplate.SetBarAnimation(f,bar,anim_id)
    if anims[anim_id] then
        anims[anim_id].set(bar)
    else
        return
    end

    f = f.parent
    if not f.animated_bars then
        f.animated_bars = {}
    end

    bar.animation = anim_id
    tinsert(f.animated_bars, bar)
end
-- messages ####################################################################
function mod:Hide(f)
    -- clear animations
    if type(f.animated_bars) == 'table' then
        for i,bar in ipairs(f.animated_bars) do
            anims[bar.animation].clear(bar)
        end
    end
end
-- register ####################################################################
mod:RegisterMessage('Hide')
