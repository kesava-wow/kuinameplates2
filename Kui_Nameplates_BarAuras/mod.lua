local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local mod = addon:NewPlugin('BarAuras',101)

local orig_UpdateCooldown
local auras_sort = function(a,b)
    -- we have to recreate this base sorting function to maintain
    -- definitive sorting, since we're replacing ArrangeButtons
    if not a.index and not b.index then
        return
    elseif a.index and not b.index then
        return true
    elseif not a.index and b.index then
        return
    end
    return a.parent.sort(a,b)
end

-- function replacements #######################################################
local function ButtonUpdate(self)
    local remaining = self.expiration - GetTime()

    if remaining > 0 and remaining <= 10 then
        -- update bar for last 10 seconds
        self.bar:SetValue(remaining)
    end

    if remaining > 20 then
        self.cd:SetTextColor(1,1,1)
    end

    self.cd:SetText(kui.FormatTime(remaining))
    self.cd:Show()
end
local function ButtonUpdateCooldown(button,duration,expiration)
    orig_UpdateCooldown(button,duration,expiration)

    if expiration and expiration > 0 then
        button.bar:Show()
        button.bar:SetValue(10)
        button:HookScript('OnUpdate',ButtonUpdate)
    else
        button.bar:Hide()
    end
end
-- callbacks ###################################################################
function ArrangeButtons(self)
    -- arrange in single column
    table.sort(self.buttons,auras_sort)

    local prev
    self.visible = 0

    for _,button in ipairs(self.buttons) do
        if button.spellid then
            if not self.max or self.visible < self.max then
                self.visible = self.visible + 1
                button:ClearAllPoints()

                if not prev then
                    button:SetPoint(self.point[1])
                else
                    button:SetPoint('BOTTOMLEFT',prev,'TOPLEFT',0,self.y_spacing)
                end

                prev = button
                button:Show()
            else
                button:Hide()
            end
        end
    end
end
local function PostCreateAuraButton(button)
    -- add status bar
    local bar = CreateFrame('StatusBar',nil,button)
    bar:SetPoint('TOPLEFT',button.icon,'TOPRIGHT',1,0)
    bar:SetPoint('BOTTOMLEFT',button.icon,'BOTTOMRIGHT')
    bar:SetPoint('RIGHT',button,'RIGHT',-1,0)
    bar:SetStatusBarTexture(kui.m.t.sbar)
    bar:SetStatusBarColor(.8,.8,1)
    bar:SetMinMaxValues(0,10)
    bar:Hide()

    bar:GetStatusBarTexture():SetDrawLayer('ARTWORK',2)

    button.cd:SetParent(bar)
    button.cd:ClearAllPoints()
    button.cd:SetPoint('LEFT',1,-1)

    button.count:SetParent(bar)
    button.count:ClearAllPoints()
    button.count:SetPoint('RIGHT',1,-1)

    button:SetWidth(button.parent:GetWidth())
    button:SetHeight(10)

    button.icon:SetSize(8,8)
    button.icon:ClearAllPoints()
    button.icon:SetPoint('BOTTOMLEFT',1,1)
    button.icon:SetTexCoord(.1,.9,.1,.9)

    if not orig_UpdateCooldown then
        orig_UpdateCooldown = button.UpdateCooldown
    end

    button.UpdateCooldown = ButtonUpdateCooldown
    button.bar = bar
end
-- register ####################################################################
function mod:Initialise()
    self:AddCallback('Auras','ArrangeButtons',ArrangeButtons)
    self:AddCallback('Auras','PostCreateAuraButton',PostCreateAuraButton)
end
