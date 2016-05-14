-- listen for castbar events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('castbar')
-- local functions #############################################################
local function OnCastbarUpdate(f)
    f = f.parent
    if not f.state.casting then return end

    f.state.cast_duration = f.state.cast_duration + elapsed
    f.Castbar:SetValue(f.state.cast_duration)

    if f.state.cast_duration >= f.state.cast_max then
        f.handler:CastbarHide()
    end
end
-- prototype additions #########################################################
function addon.Nameplate.CastbarShow(f)
    f = f.parent

    if f.elements.Castbar then
        f.Castbar:SetMinMaxValues(0,f.state.cast_max)
        f.Castbar:SetValue(0)
        f.Castbar:Show()
    end

    if f.elements.SpellName then
        f.SpellName:SetText(f.state.cast_name)
    end

    if f.elements.SpellIcon then
        f.SpellIcon:SetTexture(f.state.cast_icon)
    end

    if f.elements.SpellShield and not f.state.cast_interruptible then
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
end
-- events ######################################################################
function ele:UNIT_SPELLCAST_START(event,f,unit)
    local name,_,text,texture,startTime,endTime,_,_,notInterruptible = UnitCastingInfo(unit)
    startTime = startTime / 1000
    endTime = endTime / 1000

    f.state.casting            = true
    f.state.cast_name          = text
    f.state.cast_icon          = texture
    f.state.cast_duration      = GetTime() - startTime
    f.state.cast_max           = endTime - startTime
    f.state.cast_interruptible = not notInterruptible

    f.handler:CastbarShow()
end
function ele:UNIT_SPELLCAST_STOP(event,f,unit)
    f.state.casting = nil
    f.handler:CastbarHide()
end
-- register ####################################################################
ele:RegisterMessage('Create')

ele:RegisterEvent('UNIT_SPELLCAST_START')
ele:RegisterEvent('UNIT_SPELLCAST_FAILED')
ele:RegisterEvent('UNIT_SPELLCAST_STOP')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
ele:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
ele:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE')
ele:RegisterEvent('UNIT_SPELLCAST_DELAYED')
