-- listen for castbar events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('CastBar')
local _
-- local functions #############################################################
local function OnCastBarUpdate(f,elapsed)
    f = f.parent
    if not f.state.casting then return end

    f.cast_state.duration = f.cast_state.duration + elapsed

    if f.cast_state.channel then
        if f.elements.CastBar then
            f.CastBar:SetValue(f.cast_state.max - f.cast_state.duration)
        end
        if f.cast_state.duration > f.cast_state.max then
            f.handler:CastBarHide()
        end
    else
        if f.elements.CastBar then
            f.CastBar:SetValue(f.cast_state.duration)
        end
        if f.cast_state.duration >= f.cast_state.max then
            f.handler:CastBarHide()
        end
    end
end
-- prototype additions #########################################################
function addon.Nameplate.CastBarShow(f)
    f = f.parent

    if f.elements.CastBar then
        f.CastBar:SetMinMaxValues(0,f.cast_state.max)

        if f.cast_state.channel then
            f.CastBar:SetValue(f.cast_state.max)
        else
            f.CastBar:SetValue(0)
        end

        f.CastBar:Show()
    end

    if f.elements.SpellName then
        f.SpellName:SetText(f.cast_state.name)
    end

    if f.elements.SpellIcon then
        f.SpellIcon:SetTexture(f.cast_state.icon)
    end

    if f.elements.SpellShield and not f.cast_state.interruptible then
        f.SpellShield:Show()
    end

    addon:DispatchMessage('CastBarShow', f)

    f.CastBarUpdateFrame:Show()
    f.CastBarUpdateFrame:SetScript('OnUpdate', OnCastBarUpdate)
end
function addon.Nameplate.CastBarHide(f)
    f = f.parent
    if not f.state.casting then return end

    f.state.casting = nil
    wipe(f.cast_state)

    if f.elements.CastBar then
        f.CastBar:Hide()
    end

    if f.elements.SpellShield then
        f.SpellShield:Hide()
    end

    addon:DispatchMessage('CastBarHide', f)

    f.CastBarUpdateFrame:Hide()
    f.CastBarUpdateFrame:SetScript('OnUpdate',nil)
end
-- messages ####################################################################
function ele:Create(f)
    f.CastBarUpdateFrame = CreateFrame('Frame')
    f.CastBarUpdateFrame:Hide()
    f.CastBarUpdateFrame.parent = f
    f.cast_state = {}
end
function ele:Show(f)
    local name = UnitCastingInfo(f.unit)
    if name then
        self:CastStart('UNIT_SPELLCAST_START',f,f.unit)
        return
    end

    name = UnitChannelInfo(f.unit)
    if name then
        self:CastStart('UNIT_SPELLCAST_CHANNEL_START',f,f.unit)
        return
    end
end
function ele:Hide(f)
    f.handler:CastBarHide()
end
-- events ######################################################################
function ele:CastStart(event,f,unit)
    local name,text,texture,startTime,endTime,notInterruptible
    if event == 'UNIT_SPELLCAST_CHANNEL_START' then
        name,_,text,texture,startTime,endTime,_,_,notInterruptible = UnitChannelInfo(unit)
    else
        name,_,text,texture,startTime,endTime,_,_,notInterruptible = UnitCastingInfo(unit)
    end
    if not name then return end

    startTime = startTime / 1000
    endTime   = endTime / 1000

    f.state.casting            = true
    f.cast_state.name          = text
    f.cast_state.icon          = texture
    f.cast_state.duration      = GetTime() - startTime
    f.cast_state.max           = endTime - startTime
    f.cast_state.interruptible = not notInterruptible

    if event == 'UNIT_SPELLCAST_CHANNEL_START' then
        f.cast_state.channel = true
    end

    f.handler:CastBarShow()
end
function ele:CastStop(event,f,unit)
    f.handler:CastBarHide()
end
function ele:CastUpdate(event,f,unit)
    local startTime,endTime
    if f.cast_state.channel then
        _,_,_,_,startTime,endTime = UnitChannelInfo(unit)
    else
        _,_,_,_,startTime,endTime = UnitCastingInfo(unit)
    end

    if not startTime or not endTime then
        f.handler:CastBarHide()
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    f.cast_state.duration = GetTime() - startTime
    f.cast_state.max = endTime - startTime

    f.handler:CastBarShow()
end
-- enable/disable per frame ####################################################
function ele:EnableOnFrame(frame)
    if frame:IsShown() then
        self:Show(frame)
    end
end
function ele:DisableOnFrame(frame)
    self:Hide(frame)
end
-- register ####################################################################
function ele:OnDisable()
    for i,f in addon:Frames() do
        self:DisableOnFrame(f)
    end
end
function ele:OnEnable()
    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')

    self:RegisterUnitEvent('UNIT_SPELLCAST_START','CastStart')
    self:RegisterUnitEvent('UNIT_SPELLCAST_STOP','CastStop')
    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START','CastStart')
    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP','CastStop')
    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE','CastUpdate')
    self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED','CastStop')
    self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED','CastUpdate')
end
