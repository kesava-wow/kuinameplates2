-- listen for castbar events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('castbar')
local _
-- local functions #############################################################
local function OnCastbarUpdate(f,elapsed)
    f = f.parent
    if not f.state.casting then return end

    f.cast_state.duration = f.cast_state.duration + elapsed

    if f.cast_state.channel then
        f.Castbar:SetValue(f.cast_state.max - f.cast_state.duration)

        if f.cast_state.duration > f.cast_state.max then
            f.handler:CastbarHide()
        end
    else
        f.Castbar:SetValue(f.cast_state.duration)

        if f.cast_state.duration >= f.cast_state.max then
            f.handler:CastbarHide()
        end
    end
end
-- prototype additions #########################################################
function addon.Nameplate.CastbarShow(f)
    f = f.parent

    if f.elements.Castbar then
        f.Castbar:SetMinMaxValues(0,f.cast_state.max)

        if f.cast_state.channel then
            f.Castbar:SetValue(f.cast_state.max)
        else
            f.Castbar:SetValue(0)
        end

        f.Castbar:Show()
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

    addon:DispatchMessage('CastbarShow', f)

    f.CastbarUpdateFrame:Show()
    f.CastbarUpdateFrame:SetScript('OnUpdate', OnCastbarUpdate)
end
function addon.Nameplate.CastbarHide(f)
    f = f.parent

    f.state.casting = nil
    wipe(f.cast_state)

    if f.elements.Castbar then
        f.Castbar:Hide()
        f.Castbar:SetScript('OnUpdate',nil)
    end

    if f.elements.SpellShield then
        f.SpellShield:Hide()
    end

    addon:DispatchMessage('CastbarHide', f)

    f.CastbarUpdateFrame:Hide()
    f.CastbarUpdateFrame:SetScript('OnUpdate',nil)
end
-- messages ####################################################################
function ele.Create(f)
    f.CastbarUpdateFrame = CreateFrame('Frame')
    f.CastbarUpdateFrame:Hide()
    f.CastbarUpdateFrame.parent = f
    f.cast_state = {}
end
function ele.Hide(f)
    f.handler:CastbarHide()
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

    f.handler:CastbarShow()
end
function ele:CastStop(event,f,unit)
    f.handler:CastbarHide()
end
function ele:CastUpdate(event,f,unit)
    local startTime,endTime
    if f.cast_state.channel then
        _,_,_,_,startTime,endTime = UnitChannelInfo(unit)
    else
        _,_,_,_,startTime,endTime = UnitCastingInfo(unit)
    end

    if not startTime or not endTime then
        f.handler:CastbarHide()
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    f.cast_state.duration = GetTime() - startTime
    f.cast_state.max = endTime - startTime
end
-- register ####################################################################
ele:RegisterMessage('Create')
ele:RegisterMessage('Hide')

ele:RegisterEvent('UNIT_SPELLCAST_START','CastStart')
ele:RegisterEvent('UNIT_SPELLCAST_FAILED')
ele:RegisterEvent('UNIT_SPELLCAST_STOP','CastStop')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START','CastStart')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP','CastStop')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE','CastUpdate')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED','CastStop')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_DELAYED','CastUpdate')
