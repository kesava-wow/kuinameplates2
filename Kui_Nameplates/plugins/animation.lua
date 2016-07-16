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

                kui.frameFade(self.KuiFader, {
                    mode = 'OUT',
                    timeToFade = .2
                })
            end
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

    local function SetValueSmooth(self,value)
        if not self:IsVisible() then
            self:orig_anim_SetValue(value)
            return
        end

        if value == self:GetValue() then
            ClearBar(self)
            self:orig_anim_SetValue(value)
        else
            SmoothBar(self,value)
        end
    end
    local function SmootherOnUpdate(bar)
        local limit = 30/GetFramerate()

        for bar, value in pairs(smoothing) do
            local cur = bar:GetValue()
            local new = cur + min((value-cur)/3, max(value-cur, limit))

            if cur == value or abs(new-value) < .005 then
                bar:orig_anim_SetValue(value)
                ClearBar(bar)
            else
                bar:orig_anim_SetValue(new)
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
function addon.Nameplate.SetBarAnimation(f,bar,anim_id)
    f = f.parent

    if bar.animation and anims[bar.animation] then
        -- disable current animation
        anims[bar.animation].disable(bar)
    end

    if anim_id and anims[anim_id] then
        anims[anim_id].set(bar)
    else
        -- no animation; remove from animated bars
        if f.animated_bars and #f.animated_bars > 0 then
            for i,a_bar in ipairs(f.animated_bars) do
                if bar == a_bar then
                    tremove(f.animated_bars,i)
                end
            end
        end

        return
    end

    if not f.animated_bars then
        f.animated_bars = {}
    end

    if not bar.animation then
        tinsert(f.animated_bars, bar)
    end

    bar.animation = anim_id
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
function mod:OnEnable()
    self:RegisterMessage('Hide')
end
