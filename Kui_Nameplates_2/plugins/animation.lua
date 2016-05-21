-- provide status bar animations
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('Animation')
local anims = {}
-- local functions #############################################################
-- cutaway #####################################################################
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
anims['cutaway'] = SetAnimationCutaway
-- prototype additions #########################################################
function addon.Nameplate.SetBarAnimation(f,bar,anim)
    if anims[anim] then
        anims[anim](bar)
    end
end
-- messages ####################################################################
function mod:Hide(f)
    -- reset animations
    if f.KuiFader then
        kui.frameFadeRemoveFrame(f.KuiFader)
        f.KuiFader:SetAlpha(0)
    end
end
-- register ####################################################################
mod:RegisterMessage('Hide')
