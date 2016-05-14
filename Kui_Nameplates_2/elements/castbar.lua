-- listen for castbar events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('castbar')
-- local functions #############################################################
local function OnCastbarUpdate(f,elapsed)
    f = f.parent
    if not f.state.casting then return end

    f.cast_state.duration = f.cast_state.duration + elapsed

    if f.cast_state.channelling then
        f.Castbar:SetValue(f.cast_state.max - f.cast_state.duration)
    else
        f.Castbar:SetValue(f.cast_state.duration)
    end

    if f.cast_state.duration >= f.cast_state.max then
        f.handler:CastbarHide()
    end
end
-- prototype additions #########################################################
function addon.Nameplate.CastbarShow(f)
    f = f.parent

    if f.elements.Castbar then
        f.Castbar:SetMinMaxValues(0,f.cast_state.max)

        if f.cast_state.channelling then
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
    f.state.casting = false

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
-- events ######################################################################
local function CastStart(event,f,unit)
    local name,_,text,texture,startTime,endTime,_,_,notInterruptible = UnitCastingInfo(unit)

    startTime = startTime / 1000
    endTime   = endTime / 1000

    f.state.casting            = true
    f.cast_state.name          = text
    f.cast_state.icon          = texture
    f.cast_state.max           = endTime - startTime
    f.cast_state.interruptible = not notInterruptible

    if event == 'UNIT_SPELLCAST_CHANNEL_START' then
        f.cast_state.duration = endTime - GetTime()
        f.cast_state.channelling = true
    else
        f.cast_state.duration = GetTime() - startTime
    end

    f.handler:CastbarShow()
end
function ele:UNIT_SPELLCAST_STOP(event,f,unit)
    wipe(f.cast_state)
    f.state.casting = nil
    f.handler:CastbarHide()
end
-- register ####################################################################
ele:RegisterMessage('Create')

ele:RegisterEvent('UNIT_SPELLCAST_START','CastStart')
ele:RegisterEvent('UNIT_SPELLCAST_FAILED')
ele:RegisterEvent('UNIT_SPELLCAST_STOP')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START','CastStart')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_DELAYED')
