local folder,ns=...
local addon = KuiNameplates
if not addon then return end

local layout = addon:Layout()
-- another layout is already registered
if not layout then return end

local WIDTH,HEIGHT = 122,12

-- creation functions ##########################################################
local function CreateBackground(f)
    local bg = f:CreateTexture(nil,'BACKGROUND')
    bg:SetTexture('interface/buttons/white8x8')
    bg:SetSize(WIDTH,HEIGHT)
    bg:SetVertexColor(0,0,0,.8)
    bg:SetPoint('CENTER')

    f.bg = bg
end
local function CreateHealthBar(f)
    local bar = CreateFrame('StatusBar',nil,f)
    bar:SetStatusBarTexture('interface/raidframe/raid-bar-hp-fill')

    bar:SetPoint('TOPLEFT',f.bg,1,-1)
    bar:SetPoint('BOTTOMRIGHT',f.bg,-1,1)

    -- we need to inherit the parent frame-level to prevent intersecting
    bar:SetFrameLevel(0)

    -- update the bar using the HealthBar element found in:
    -- Kui_Nameplates/elements/healthbar.lua
    f.handler:RegisterElement('HealthBar',bar)
    -- after this call, the bar can be found at f.HealthBar
end
local function CreateNameText(f)
    local text = f:CreateFontString(nil,'OVERLAY')
    text:SetFont('fonts/frizqt__.ttf',11,'OUTLINE',0,-1)
    text:SetWordWrap()

    text:SetPoint('BOTTOMLEFT',f.HealthBar,'TOPLEFT')
    text:SetPoint('BOTTOMRIGHT',f.HealthBar,'TOPRIGHT')

    -- update the text using the NameText element
    f.handler:RegisterElement('NameText',text)
end
local function CreateHealthText(f)
    local text = f:CreateFontString(nil,'OVERLAY')
    text:SetFont('fonts/frizqt__.ttf',10,'OUTLINE')
    text:SetWordWrap()
    text:Hide()

    text:SetPoint('CENTER',f.HealthBar,'BOTTOM',0,1.5)

    -- this isn't provided by an element file, we update it manually using
    -- the HealthUpdate message
    f.HealthText = text
end
-- messages ####################################################################
function layout:Create(f)
    -- run on nameplate creation;
    -- create nameplate frame elements
    CreateBackground(f)
    CreateHealthBar(f)
    CreateNameText(f)
    CreateHealthText(f)
end
function layout:Show(f)
    -- run whenever a nameplate is shown;
    -- set inital health text
    self:HealthUpdate(f)
end
function layout:HealthUpdate(f)
    -- run by the HealthBar element on health update (UNIT_HEALTH);
    -- use the percent state provided by the HealthBar element
    if f.state.health_per == 100 then
        f.HealthText:Hide()
    else
        f.HealthText:SetText(ceil(f.state.health_per)..'%')
        f.HealthText:Show()
    end
end
-- initialise ##################################################################
function layout:Initialise()
    print('|cff9966ffKui Nameplates|r: |cffff6666You are using Kui_Nameplates_Example which is not updated by the Curse package.|r If you experience errors, check the repository on GitHub for updates.')

    self:RegisterMessage('Create')
    self:RegisterMessage('Show')

    -- update health text
    self:RegisterMessage('HealthUpdate')

    -- tell KNP we want clean pixel alignment
    addon.IGNORE_UISCALE = v
    addon:UI_SCALE_CHANGED()
end
