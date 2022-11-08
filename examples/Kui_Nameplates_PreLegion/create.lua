local folder,ns=...
local addon = KuiNameplates
local layout = KuiNameplatesPreLegion
local kui = LibStub('Kui-1.0')

local MEDIA='interface/addons/kui_nameplates_prelegion/media/'
local SCALE = 1

function layout:CreateBorder(f)
    local border = f:CreateTexture(nil,'ARTWORK',nil,1)
    border:SetTexture(MEDIA..'Nameplate-Border')
    border:SetPoint('CENTER')
    border:SetSize(128*SCALE,32*SCALE)

    local name = f:CreateFontString(nil,'OVERLAY')
    name:SetWordWrap(false)
    name:SetFont('fonts/frizqt__.ttf',12*SCALE)
    name:SetShadowOffset(1,-1)
    name:SetShadowColor(0,0,0)
    name:SetPoint('BOTTOM',border,'TOP',0,-18*SCALE)

    f.handler:RegisterElement('NameText',name)

    local level = f:CreateFontString(nil,'OVERLAY')
    level:SetWordWrap(false)
    level:SetFont('fonts/frizqt__.ttf',12*SCALE)
    level:SetShadowOffset(1,-1)
    level:SetShadowColor(0,0,0)
    level:SetPoint('LEFT',border,'RIGHT',-32*SCALE,-7*SCALE)
    level:SetJustifyH('CENTER')
    level:SetWidth(37*SCALE)

    -- we don't want the classification symbol, so don't use the level element
    f.LevelText = level

    f.border = border
end
function layout:CreateHealthBar(f)
    local healthbar = CreateFrame('StatusBar',nil,f)
    healthbar:SetFrameLevel(0)
    healthbar:SetStatusBarTexture('interface/targetingframe/ui-statusbar')
    healthbar:SetSize(103*SCALE,9*SCALE)
    healthbar:SetPoint('LEFT',f.border,4*SCALE,-8*SCALE)

    f.handler:RegisterElement('HealthBar',healthbar)
end
function layout:UpdateCastBar(f)
    if f.cast_state.interruptible then
        f.CastBar.bg:SetTexture(MEDIA..'Nameplate-CastBar')
    else
        f.CastBar.bg:SetTexture(MEDIA..'Nameplate-CastBar-Shield')
    end
end
function layout:CreateCastBar(f)
    local bg = f:CreateTexture(nil,'ARTWORK',nil,2)
    bg:SetSize(128*SCALE,32*SCALE)
    bg:SetPoint('CENTER',0,-28*SCALE)

    local bar = CreateFrame('StatusBar',nil,f)
    bar:SetFrameLevel(0)
    bar:SetStatusBarTexture('interface/targetingframe/ui-statusbar')
    bar:SetSize(103*SCALE,9*SCALE)
    bar:SetPoint('LEFT',bg,21*SCALE,0)

    local spellicon = f:CreateTexture(nil,'ARTWORK',nil,3)
    spellicon:SetTexCoord(.1, .9, .1, .9)
    spellicon:SetPoint('LEFT',bg,6*SCALE,0)
    spellicon:SetSize(13*SCALE,13*SCALE)

    bar.bg = bg
    bar.icon = spellicon

    bar:Hide()
    bar.bg:Hide()
    bar.icon:Hide()

    f.handler:RegisterElement('CastBar',bar)
    f.handler:RegisterElement('SpellIcon',spellicon)
end
function layout:UpdateStateIcon(f)
    if f.state.classification == 'rare' or f.state.classification == 'rareelite' then
        f.StateIcon:SetVertexColor(1,1,1)
        f.StateIcon:Show()
    elseif f.state.classification == 'worldboss' or f.state.classification == 'elite' then
        f.StateIcon:SetVertexColor(1,1,1)
        f.StateIcon:Show()
    else
        f.StateIcon:Hide()
    end
end
function layout:CreateStateIcon(f)
    local state = f:CreateTexture(nil,'ARTWORK',nil,3)
    state:SetTexture(MEDIA..'EliteNameplateIcon')
    state:SetSize(64*SCALE,32*SCALE)
    state:SetPoint('LEFT',f.border,'RIGHT',-27*SCALE,-11*SCALE)
    state:Hide()

    f.StateIcon = state
end
