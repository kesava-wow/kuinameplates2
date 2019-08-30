--[[
    Provides class power icons on nameplates for combo points, shards, etc.

    Icon container is created as addon.ClassPowersFrame after layout
    initialisation.

    In layout initialise
    ====================

    self.ClassPowers = {
        icon_size = size of class power icons
        icon_spacing = space between icons
        icon_texture = texture of class power icons
        cd_texture = cooldown spiral texture
        bar_texture = texture of class power bar
        bar_width = width of class power bar
        bar_height = height of class power bar
        frame_point = {
            position of the class powers container frame
            1 = point
            2 = relative point frame
            3 = relative point
            4 = x offset
            5 = y offset
        }
        colours = {
            custom class colours for power icons
            [class name] = {
                1 = red,
                2 = green,
                3 = blue
            }
            ...
        }
    }
        Configuration table. Must not be empty.
        Element will not initialise if this is missing or not a table.

    Callbacks
    =========

    PositionIcons
        Can be used to replace the built in icon positioning function.

    CreateIcon
        Can be used to replace the built in function which creates each
        individual power icon.

    PostCreateIcon(icon)
        Called after a power icon is created by the built in CreateIcon
        function.

    PostIconsCreated
        Called after icons are created.

    CreateBar
        Can be used to replace the built in function which creates a status bar
        for bar-style power types, such as stagger.

    PostCreateBar
        Called after the power bar is created.

    PostPowerUpdate
        Called after icons are set to active or inactive.

    PostRuneUpdate
        Called after updating rune icon cooldown data for death knights.

    PostPositionFrame(cpf,parent)
        Called after positioning the icon container frame.

]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('ClassPowers')
local class,power_type,power_type_tag,highlight_at,cpf,initialised
local power_mod,power_display_partial
local on_target
local orig_SetVertexColor
local powers,power_tags,bar_powers
-- icon config
local colours = {
    DEATHKNIGHT = { 1, .2, .3 },
    DRUID       = { 1, 1, .1 },
    PALADIN     = { 1, 1, .1 },
    ROGUE       = { 1, 1, .1 },
    MAGE        = { .5, .5, 1 },
    MONK        = { .3, 1, .9 },
    WARLOCK     = { 1, .5, 1 },
    overflow    = { 1, .3, .3 },
    inactive    = { .5, .5, .5, .5 }
}

-- stagger colours
local STAGGER_GREEN = { .52, 1, .52 }
local STAGGER_YELLOW = { 1, .98, .72 }
local STAGGER_RED = { 1, .42, .42 }

local ICON_SIZE
local ICON_SPACING
local ICON_TEXTURE
local GLOW_TEXTURE
local CD_TEXTURE
local BAR_TEXTURE,BAR_WIDTH,BAR_HEIGHT
local FRAME_POINT
local ICON_SPRITE

local BALANCE_FERAL_AFFINITY_TALENT_ID=22155
local GUARDIAN_FERAL_AFFINITY_TALENT_ID=22156
local RESTO_FERAL_AFFINITY_TALENT_ID=22367
local FIRES_OF_JUSTICE_SPELL_ID=209785
-- local functions #############################################################
local function AuraUtil_IDPredicate(IDToFind,_,_,_,_,_,_,_,_,_,_,_,spellID)
    -- spell ID predicate for AuraUtil
    return spellID == IDToFind
end
local function IsTalentKnown(id)
    return select(10,GetTalentInfoByID(id))
end
local function PositionIcons()
    -- position icons in the powers container frame
    if ele:RunCallback('PositionIcons') then
        return
    end

    local pv
    local full_size = (ICON_SIZE * #cpf.icons) + (ICON_SPACING * (#cpf.icons - 1))
    cpf:SetWidth(full_size)

    for i,icon in ipairs(cpf.icons) do
        icon:ClearAllPoints()

        if i == 1 then
            icon:SetPoint('LEFT')
        elseif i > 1 then
            icon:SetPoint('LEFT',pv,'RIGHT',ICON_SPACING,0)
        end

        pv = icon
    end
end
local function Icon_SetVertexColor(self,...)
    -- also set glow colour
    orig_SetVertexColor(self,...)

    if self.glow then
        self.glow:SetVertexColor(...)
        self.glow:SetAlpha(.5)
    end
end
local function Icon_GraduateFill(self,val)
    if not ICON_SPRITE or not val then return end
    val = (val < 0 and 0) or (val > 1 and 1) or val

    if val == 0 then
        -- empty
        self:SetTexCoord(.5,.75,.5,1)
    elseif val == 1 then
        -- full
        self:SetTexCoord(0,.25,0,.5)
    elseif val > .8 then
        self:SetTexCoord(.25,.5,.5,1)
    elseif val > .6 then
        self:SetTexCoord(0,.25,.5,1)
    elseif val > .4 then
        self:SetTexCoord(.75,1,0,.5)
    elseif val > .2 then
        self:SetTexCoord(.5,.75,0,.5)
    elseif val > 0 then
        self:SetTexCoord(.25,.5,0,.5)
    end
end
local function CreateIcon()
    -- create individual icon
    local icon = ele:RunCallback('CreateIcon')

    if not icon then
        icon = cpf:CreateTexture(nil,'ARTWORK',nil,1)

        if not orig_SetVertexColor then
            orig_SetVertexColor = icon.SetVertexColor
        end
        icon.SetVertexColor = Icon_SetVertexColor
        icon.GraduateFill = Icon_GraduateFill

        if ICON_SPRITE then
            icon:SetTexture(ICON_SPRITE)
            icon:GraduateFill(1)
        else
            icon:SetTexture(ICON_TEXTURE)
        end

        icon:SetSize(ICON_SIZE,ICON_SIZE)

        if GLOW_TEXTURE then
            -- create icon glow if a texture is set
            local ig = cpf:CreateTexture(nil,'ARTWORK',nil,0)
            ig:SetTexture(GLOW_TEXTURE)
            ig:SetPoint('TOPLEFT',icon,-5,5)
            ig:SetPoint('BOTTOMRIGHT',icon,5,-5)
            ig:Hide()

            icon.glow = ig
        end

        if class ~= 'DEATHKNIGHT' then
            icon.Active = function(self)
                self:SetVertexColor(unpack(colours[class]))
                self:SetAlpha(1)
            end
            icon.Inactive = function(self)
                self:SetVertexColor(unpack(colours.inactive))
            end
            icon.ActiveOverflow = function(self)
                self:SetVertexColor(unpack(colours.overflow))
                self:SetAlpha(1)
            end
        end
    end

    ele:RunCallback('PostCreateIcon',icon)

    return icon
end
local function CreateBar()
    local bar = ele:RunCallback('CreateBar')

    if not bar then
        bar = CreateFrame('StatusBar',nil,cpf)
        bar:SetStatusBarTexture(BAR_TEXTURE)
        bar:SetSize(BAR_WIDTH,BAR_HEIGHT)

        bar:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            insets={top=-1,right=-1,bottom=-1,left=-1}
        })
        bar:SetBackdropColor(0,0,0,.8)

        bar:SetPoint('CENTER',0,-1)
    end

    ele:RunCallback('PostCreateBar',bar)

    return bar
end
local function UpdateIcons()
    -- create/destroy icons based on player power max
    local power_max
    if power_type == 'stagger' then
        -- corrected by StaggerUpdate
        power_max = 1
    else
        power_max = UnitPowerMax('player',power_type)
    end

    if bar_powers and bar_powers[power_type] then
        -- create/update power bar
        if cpf.icons then
            -- destroy existing icons
            for i,icon in ipairs(cpf.icons) do
                icon:Hide()
                cpf.icons[i] = nil
            end
        end

        if not cpf.bar then
            cpf.bar = CreateBar()
        end

        cpf.bar:SetMinMaxValues(0,power_max)

        return
    else
        -- create/update power icons
        if cpf.bar then
            -- destroy power bar
            cpf.bar:Hide()
            cpf.bar = nil
        end

        if cpf.icons then
            if #cpf.icons > power_max then
                -- destroy overflowing icons if powermax has decreased
                for i,icon in ipairs(cpf.icons) do
                    if i > power_max then
                        icon:Hide()
                        cpf.icons[i] = nil
                    end
                end
            elseif #cpf.icons < power_max then
                -- create new icons
                for i=#cpf.icons+1,power_max do
                    cpf.icons[i] = CreateIcon()
                end
            end

            if ICON_SPRITE then
                -- reset icons to filled
                for _,icon in ipairs(cpf.icons) do
                    icon:GraduateFill(1)
                end
            end
        else
            -- create initial icons
            cpf.icons = {}
            for i=1,power_max do
                cpf.icons[i] = CreateIcon()
            end
        end

        PositionIcons()

        ele:RunCallback('PostIconsCreated')
    end
end
local function PowerUpdate()
    -- toggle icons based on current power
    local cur = UnitPower('player',power_type,true)

    if power_mod and power_mod > 1 then
        cur = cur / power_mod
    end

    if cpf.bar then
        cpf.bar:SetValue(cur)
    elseif cur > #cpf.icons then
        -- colour with overflow
        cur = cur - #cpf.icons
        for i,icon in ipairs(cpf.icons) do
            if i <= cur then
                icon:ActiveOverflow()
            else
                icon:Active()
            end

            icon:GraduateFill(1)

            if icon.glow then
                icon.glow:Show()
            end
        end
    else
        local at_max = cur == #cpf.icons
        for i,icon in ipairs(cpf.icons) do
            if at_max then
                icon:Active()
                icon:GraduateFill(1)

                if icon.glow then
                    icon.glow:Show()
                end
            else
                if i <= cur then
                    icon:Active()
                    icon:GraduateFill(1)
                else
                    if ICON_SPRITE and
                       power_display_partial and
                       (power_mod and power_mod > 1)
                    then
                        if i > ceil(cur) then
                            -- empty
                            icon:Inactive()
                            icon:GraduateFill(0)
                        else
                            -- partially filled
                            icon:Active()
                            icon:GraduateFill(cur - floor(cur))
                        end
                    else
                        icon:Inactive()
                    end
                end

                if highlight_at and i <= highlight_at and cur >= highlight_at then
                    icon.glow:Show()
                elseif icon.glow then
                    icon.glow:Hide()
                end
            end
        end
    end

    if class == 'PALADIN' and cur > 0 and highlight_at == 2 then
        -- colour first icon red to show fires of justice
        cpf.icons[1]:ActiveOverflow()
    end

    ele:RunCallback('PostPowerUpdate')
end
local function PositionFrame()
    if not power_type then
        cpf:Hide()
        return
    end

    local frame
    if on_target then
        if UnitIsPlayer('target') or UnitCanAttack('player','target') then
            frame = addon:GetActiveNameplateForUnit('target')
            if  not frame or
                not frame.state.reaction or
                frame.state.reaction > 4
            then
                frame = nil
            end
        end
    else
        frame = addon:GetActiveNameplateForUnit('player')
    end

    if not FRAME_POINT or not frame then
        cpf:Hide()
        return
    end

    local parent = frame[FRAME_POINT[2]]

    if parent then
        cpf:ClearAllPoints()
        cpf:SetParent(frame)
        cpf:SetFrameLevel(frame:GetFrameLevel()+1)
        cpf:SetPoint(
            FRAME_POINT[1],
            parent,
            FRAME_POINT[3],
            FRAME_POINT[4],
            FRAME_POINT[5]
        )
        cpf:Show()
    else
        cpf:Hide()
    end

    ele:RunCallback('PostPositionFrame',cpf,frame)
end
local function RuneDaemon_OnUpdate(self,elap)
    self.elap = (self.elap or 0) + elap
    if self.elap > .1 then
        self.active = nil
        self.elap = 0

        for _,icon in ipairs(cpf.icons) do
            if icon.startTime and icon.duration then
                self.active = true
                icon:GraduateFill((GetTime() - icon.startTime) / icon.duration)
            end
        end

        if not self.active then
            self:Hide()
        end
    end
end
-- mod functions ###############################################################
function ele:UpdateConfig()
    -- get config from layout
    if not self.enabled then return end
    if type(addon.layout.ClassPowers) ~= 'table' then
        return
    end

    on_target         = kui.CLASSIC or addon.layout.ClassPowers.on_target
    ICON_SIZE         = addon.layout.ClassPowers.icon_size or 10
    ICON_SPACING      = addon.layout.ClassPowers.icon_spacing or 1
    ICON_TEXTURE      = addon.layout.ClassPowers.icon_texture
    ICON_SPRITE       = addon.layout.ClassPowers.icon_sprite
    GLOW_TEXTURE      = addon.layout.ClassPowers.icon_glow_texture
    CD_TEXTURE        = addon.layout.ClassPowers.cd_texture
    BAR_TEXTURE       = addon.layout.ClassPowers.bar_texture
    BAR_WIDTH         = addon.layout.ClassPowers.bar_width or 50
    BAR_HEIGHT        = addon.layout.ClassPowers.bar_height or 3
    FRAME_POINT       = addon.layout.ClassPowers.point

    if on_target then
        self:RegisterMessage('GainedTarget','TargetUpdate')
        self:RegisterMessage('LostTarget','TargetUpdate')
    else
        self:UnregisterMessage('GainedTarget')
        self:UnregisterMessage('LostTarget')
    end

    if type(addon.layout.ClassPowers.colours) == 'table' then
        if addon.layout.ClassPowers.colours[class] then
            colours[class] = addon.layout.ClassPowers.colours[class]
        end
        if addon.layout.ClassPowers.colours.overflow then
            colours.overflow = addon.layout.ClassPowers.colours.overflow
        end
        if addon.layout.ClassPowers.colours.inactive then
            colours.inactive = addon.layout.ClassPowers.colours.inactive
        end
    end

    ICON_SIZE = ICON_SIZE * addon.uiscale

    if cpf then
        -- update existing frame
        cpf:SetHeight(ICON_SIZE)

        if cpf.icons then
            -- update icons
            for _,i in ipairs(cpf.icons) do
                i:SetSize(ICON_SIZE,ICON_SIZE)

                if ICON_SPRITE then
                    i:SetTexture(ICON_SPRITE)
                else
                    i:SetTexture(ICON_TEXTURE)
                end

                if i.glow then
                    i.glow:SetTexture(GLOW_TEXTURE)
                end

                if i.cd then
                    i.cd:SetSwipeTexture(CD_TEXTURE)
                end
            end

            PositionIcons()
            PositionFrame()
        end

        if cpf.bar then
            -- update bar
            cpf.bar:SetStatusBarTexture(BAR_TEXTURE)
            cpf.bar:SetSize(BAR_WIDTH,BAR_HEIGHT)
        end
    end
end
-- messages ####################################################################
function ele:TargetUpdate()
    PositionFrame()
end
-- events ######################################################################
function ele:PLAYER_ENTERING_WORLD()
    -- Update icons after zoning to workaround UnitPowerMax returning 0 when
    -- zoning into/out of instanced PVP (#125)
    UpdateIcons()
    PowerUpdate()
end
function ele:PowerInit()
    -- get current power type, register events
    power_type_tag = nil
    highlight_at = nil
    power_mod = nil
    power_display_partial = nil

    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM')
    self:UnregisterEvent('RUNE_POWER_UPDATE')
    cpf:UnregisterAllEvents()
    self.UNIT_AURA_func = nil

    if type(powers[class]) == 'table' then
        local spec = GetSpecialization()
        power_type = powers[class][spec]

        if class == 'PALADIN' then
            if power_type then
                -- ret paladin; watch for fires of justice procs
                highlight_at = 3

                cpf:RegisterUnitEvent('UNIT_AURA','player')
                self.UNIT_AURA_func = self.Paladin_WatchFiresOfJustice
            end
        elseif class == 'DRUID' and (
           (spec == 1 and IsTalentKnown(BALANCE_FERAL_AFFINITY_TALENT_ID)) or
           (spec == 3 and IsTalentKnown(GUARDIAN_FERAL_AFFINITY_TALENT_ID)) or
           (spec == 4 and IsTalentKnown(RESTO_FERAL_AFFINITY_TALENT_ID))
           )
        then
            -- if feral affinity is known, we need to watch for shapeshifts
            -- into cat form
            self:RegisterEvent('UPDATE_SHAPESHIFT_FORM')

            local form = GetShapeshiftForm()
            if form and form == 2 then
                power_type = Enum.PowerType.ComboPoints
            end
        end
    else
        power_type = powers[class]
    end

    if power_type then
        if class == 'DEATHKNIGHT' then
            self:RegisterEvent('RUNE_POWER_UPDATE','RuneUpdate')

            if not cpf.RuneDaemon then
                -- create rune time-keeper
                local r = CreateFrame('Frame',nil,cpf)
                r:SetScript('OnUpdate',RuneDaemon_OnUpdate)
                r:Hide()
                cpf.RuneDaemon = r
            end
        elseif power_type == 'stagger' then
            cpf:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED','player')
            cpf:RegisterUnitEvent('UNIT_MAXHEALTH','player')
        else
            power_mod = UnitPowerDisplayMod(power_type)
            power_type_tag = power_tags[power_type]

            if  class == 'WARLOCK' and
                GetSpecialization() == SPEC_WARLOCK_DESTRUCTION
            then
                power_display_partial = true
            else
                power_display_partial = nil
            end

            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            cpf:RegisterUnitEvent('UNIT_MAXPOWER','player')
            cpf:RegisterUnitEvent('UNIT_POWER_FREQUENT','player')
        end

        self:RegisterMessage('Show','TargetUpdate')
        self:RegisterMessage('HealthColourChange','TargetUpdate')

        UpdateIcons()

        -- set initial state
        if power_type == 'stagger' then
            self:StaggerUpdate()
        elseif class == 'DEATHKNIGHT' then
            self:RuneUpdate()
        else
            -- icon/generic bar powers
            PowerUpdate()
        end

        -- set initial position
        PositionFrame()
    else
        self:UnregisterMessage('Show')
        self:UnregisterMessage('HealthColourChange')
        cpf:Hide()
    end
end
function ele:RuneUpdate()
    -- set/clear cooldown on rune icons
    for i=1,6 do
        local startTime, duration, charged = GetRuneCooldown(i)
        local icon = cpf.icons[i]
        if not icon then return end

        if charged then
            icon:SetVertexColor(unpack(colours.DEATHKNIGHT))
            icon:SetAlpha(1)
            icon:GraduateFill(1)

            icon.startTime = nil
            icon.duration = nil

            if icon.glow then
                icon.glow:Show()
            end
        else
            icon:SetVertexColor(unpack(colours.inactive))
            icon:SetAlpha(1)
            icon:GraduateFill((GetTime() - startTime) / duration)

            icon.startTime = startTime
            icon.duration = duration
            cpf.RuneDaemon:Show()

            if icon.glow then
                icon.glow:Hide()
            end
        end
    end

    self:RunCallback('PostRuneUpdate')
end
function ele:StaggerUpdate()
    if not cpf.bar then return end

    local max = UnitHealthMax('player')
    local cur = UnitStagger('player')
    local per = (max == 0 or cur == 0 and 0) or (cur / max)

    if per == 0 then
        cpf.bar:Hide()
    else
        cpf.bar:SetMinMaxValues(0,max)
        cpf.bar:SetValue(cur)

        if per > STAGGER_RED_TRANSITION then
            cpf.bar:SetStatusBarColor(unpack(STAGGER_RED))
        elseif per > STAGGER_YELLOW_TRANSITION then
            cpf.bar:SetStatusBarColor(unpack(STAGGER_YELLOW))
        else
            cpf.bar:SetStatusBarColor(unpack(STAGGER_GREEN))
        end

        cpf.bar:Show()
    end
end
function ele:PowerEvent(event,_,power_type_rcv)
    -- validate power events + passthrough to PowerUpdate
    if power_type_rcv ~= power_type_tag then return end

    if event == 'UNIT_MAXPOWER' then
        UpdateIcons()
    end

    PowerUpdate()
end
function ele:UPDATE_SHAPESHIFT_FORM()
    self:PowerInit()
end
function ele:Paladin_WatchFiresOfJustice(_,unit)
    -- TODO it would definitely be more efficient to watch the combat log for this
    if AuraUtil.FindAura(AuraUtil_IDPredicate,unit,nil,FIRES_OF_JUSTICE_SPELL_ID) then
        highlight_at = 2
    else
        highlight_at = 3
    end

    PowerUpdate()
end
-- cpf event wrappers ##########################################################
-- wrap cpf unit events to mod functions
function ele:UNIT_AURA(...)
    self:UNIT_AURA_func(...)
end
function ele:UNIT_MAXPOWER(...)
    self:PowerEvent(...)
end
function ele:UNIT_POWER_FREQUENT(...)
    self:PowerEvent(...)
end
function ele:UNIT_ABSORB_AMOUNT_CHANGED()
    self:StaggerUpdate()
end
function ele:UNIT_MAXHEALTH()
    self:StaggerUpdate()
end
-- register ####################################################################
function ele:OnEnable()
    if not initialised then return end
    if not cpf then
        self:Disable()
        return
    end

    self:UpdateConfig()

    if not kui.CLASSIC then
        -- This event is sometimes spammed upon entering/leaving instanced PVP.
        -- It's always called at least once, and during this first call,
        -- UnitPowerMax returns 0 for some reason. (#125)
        self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED','PowerInit')
    end

    self:PowerInit()
end
function ele:OnDisable()
    if cpf then
        cpf:Hide()
        cpf:UnregisterAllEvents()
    end
end
function ele:Initialised()
    initialised = true
    class = select(2,UnitClass('player'))

    if  type(addon.layout.ClassPowers) ~= 'table' or
        not powers[class]
    then
        -- layout didn't initialise us, or this class has no special power
        self:Disable()
        return
    end

    -- create icon frame container
    -- (which also serves as an event frame for non-KNP unit events)
    cpf = CreateFrame('Frame')
    cpf:SetSize(2,2)
    cpf:SetPoint('CENTER')
    cpf:Hide()
    cpf:SetScript('OnEvent',function(_,event,...)
        ele[event](ele,event,...)
    end)

    addon.ClassPowersFrame = cpf

    if self.enabled then
        -- call this again since it's blocked until Initialised runs
        self:OnEnable()
    end
end
function ele:Initialise()
    -- register callbacks
    self:RegisterCallback('PositionIcons')
    self:RegisterCallback('CreateIcon',true)
    self:RegisterCallback('PostCreateIcon')
    self:RegisterCallback('CreateBar',true)
    self:RegisterCallback('PostCreateBar')
    self:RegisterCallback('PostIconsCreated')
    self:RegisterCallback('PostRuneUpdate')
    self:RegisterCallback('PostPowerUpdate')
    self:RegisterCallback('PostPositionFrame')

    -- initialise powers
    if kui.CLASSIC then
        -- power types by class/spec
        powers = {
            DRUID = Enum.PowerType.ComboPoints,
            ROGUE = Enum.PowerType.ComboPoints,
        }
        -- tags returned by the UNIT_POWER and UNIT_MAXPOWER events
        power_tags = {
            [Enum.PowerType.ComboPoints] = 'COMBO_POINTS',
        }
    else
        powers = {
            DEATHKNIGHT = Enum.PowerType.Runes,
            DRUID       = { [2] = Enum.PowerType.ComboPoints },
            PALADIN     = { [3] = Enum.PowerType.HolyPower },
            ROGUE       = Enum.PowerType.ComboPoints,
            MAGE        = { [1] = Enum.PowerType.ArcaneCharges },
            MONK        = { [1] = 'stagger', [3] = Enum.PowerType.Chi },
            WARLOCK     = Enum.PowerType.SoulShards,
        }
        power_tags = {
            [Enum.PowerType.Runes]         = 'RUNES',
            [Enum.PowerType.ComboPoints]   = 'COMBO_POINTS',
            [Enum.PowerType.HolyPower]     = 'HOLY_POWER',
            [Enum.PowerType.ArcaneCharges] = 'ARCANE_CHARGES',
            [Enum.PowerType.Chi]           = 'CHI',
            [Enum.PowerType.SoulShards]    = 'SOUL_SHARDS',
        }
        -- power types which render as a bar
        bar_powers = {
            ['stagger'] = true,
        }
    end
end
