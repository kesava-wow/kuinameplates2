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
    local function SetValueCutaway(self, value)
        if not self:IsVisible() then
            -- passthrough initial calls
            self:orig_anim_SetValue(value)
            return
        end

        local ok = pcall(function()
            if value < self:GetValue() then
                if not kui.frameIsFading(self.KuiFader) then
                    self.KuiFader:SetPoint(
                        'RIGHT', self, 'LEFT',
                        (self:GetValue() / select(2, self:GetMinMaxValues())) * self:GetWidth(), 0
                    )

                    -- store original rightmost value
                    self.KuiFader.right = self:GetValue()

                    kui.frameFade(self.KuiFader, {
                        mode = 'OUT',
                        timeToFade = .2
                    })
                end
            end

            if self.KuiFader.right and value > self.KuiFader.right then
                kui.frameFadeRemoveFrame(self.KuiFader)
                self.KuiFader:SetAlpha(0)
            end
        end)

        self:orig_anim_SetValue(value)

        if not ok and self.KuiFader then
            kui.frameFadeRemoveFrame(self.KuiFader)
            self.KuiFader:SetAlpha(0)
        end
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
        if not bar.KuiFader then return end
        kui.frameFadeRemoveFrame(bar.KuiFader)
        bar.KuiFader:SetAlpha(0)
    end
    local function DisableAnimationCutaway(bar)
        ClearAnimationCutaway(bar)

        bar.SetValue = bar.orig_anim_SetValue
        bar.orig_anim_SetValue = nil

        bar.SetStatusBarColor = bar.orig_anim_SetStatusBarColor
        bar.orig_anim_SetStatusBarColor = nil

        bar.KuiFader = nil
    end
    anims['cutaway'] = {
        set   = SetAnimationCutaway,
        clear = ClearAnimationCutaway,
        disable = DisableAnimationCutaway
    }
end
-- smooth ######################################################################
do
    local smoother,smoothing,num_smoothing = nil,{},0

    local function SmoothBar(bar,val)
        if not smoothing[bar] then
            num_smoothing = num_smoothing + 1
        end

        smoothing[bar] = val
        smoother:Show()
    end
    local function ClearBar(bar)
        if smoothing[bar] then
            num_smoothing = num_smoothing - 1
            smoothing[bar] = nil
        end

        if num_smoothing <= 0 then
            num_smoothing = 0
            smoother:Hide()
        end
    end

    local function SetValueSmooth(self, value)
        if not self:IsVisible() then
            self:orig_anim_SetValue(value)
            return
        end

        local ok, same = pcall(function()
            return value == self:GetValue()
        end)

        if not ok then
            ClearBar(self)
            self:orig_anim_SetValue(value)
            return
        end

        if same then
            ClearBar(self)
            self:orig_anim_SetValue(value)
        else
            SmoothBar(self, value)
        end
    end
    local function SmootherOnUpdate()
        local limit = 30 / GetFramerate()

        for bar, value in pairs(smoothing) do
            local ok = pcall(function()
                local cur = bar:GetValue()
                local new = cur + min((value - cur) / 3, max(value - cur, limit))

                if cur == value or abs(new - value) < .005 then
                    bar:orig_anim_SetValue(value)
                    ClearBar(bar)
                else
                    bar:orig_anim_SetValue(new)
                end
            end)

            if not ok then
                bar:orig_anim_SetValue(value)
                ClearBar(bar)
            end
        end
    end
    local function SetAnimationSmooth(bar)
        if not smoother then
            smoother = CreateFrame('Frame')
            smoother:Hide()
            smoother:SetScript('OnUpdate',SmootherOnUpdate)
        end

        bar.orig_anim_SetValue = bar.SetValue
        bar.SetValue = SetValueSmooth
    end
    local function ClearAnimationSmooth(bar)
        if smoother and smoothing[bar] then
            ClearBar(bar)
        end
    end
    local function DisableAnimationSmooth(bar)
        ClearAnimationSmooth(bar)

        bar.SetValue = bar.orig_anim_SetValue
        bar.orig_anim_SetValue = nil
    end
    anims['smooth'] = {
        set   = SetAnimationSmooth,
        clear = ClearAnimationSmooth,
        disable = DisableAnimationSmooth
    }
end
-- prototype additions #########################################################
function addon.Nameplate.SetBarAnimation(f, bar, anim_id)
    if not bar then return end
    f = f.parent

    if f and f.animated_bars then
        for i = #f.animated_bars, 1, -1 do
            if f.animated_bars[i] == bar then
                table.remove(f.animated_bars, i)
            end
        end
    end

    bar.animation = nil
end
-- messages ####################################################################
function mod:Hide(f)
    -- no custom animations in Midnight
end
-- register ####################################################################
function mod:OnEnable()
    self:RegisterMessage('Hide')
end
