-- listen for castbar events and dispatch to nameplates
local addon = KuiNameplates
local ele = addon:NewElement('CastBar')
local _

-- castbar hide causes (first argument of CastBarHide)
ele.HIDE_FRAME=0
ele.HIDE_INTERRUPT=1
ele.HIDE_STOP=2
ele.HIDE_SUCCESS=3

-- local functions #############################################################
local function OnCastBarUpdate(f,elapsed)
    f = f.parent
    if not f.state.casting then return end

    f.cast_state.duration = f.cast_state.duration + elapsed

    if f.elements.CastBar then
        if f.cast_state.channel then
            f.CastBar:SetValue(f.cast_state.max - f.cast_state.duration)
        else
            f.CastBar:SetValue(f.cast_state.duration)
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
    end

    if f.elements.SpellName then
        f.SpellName:SetText(f.cast_state.name)
    end

    if f.elements.SpellIcon then
        f.SpellIcon:SetTexture(f.cast_state.icon)
    end

    addon:DispatchMessage('CastBarShow', f)

    f.CastBarUpdateFrame:Show()
    f.CastBarUpdateFrame:SetScript('OnUpdate', OnCastBarUpdate)
end
function addon.Nameplate.CastBarHide(f,hide_cause,force)
    f = f.parent
    if f.state.casting then
        f.state.casting = nil
        wipe(f.cast_state)
    elseif not force then
        return
    end

    f.CastBarUpdateFrame:Hide()
    f.CastBarUpdateFrame:SetScript('OnUpdate',nil)

    if hide_cause ~= ele.HIDE_FRAME then
        addon:DispatchMessage('CastBarHide',f,hide_cause,force)
    end
end
-- messages ####################################################################
function ele:Create(f)
    if not f.CastBarUpdateFrame then
        f.CastBarUpdateFrame = CreateFrame('Frame')
        f.CastBarUpdateFrame:Hide()
        f.CastBarUpdateFrame.parent = f
        f.cast_state = {}
    end
end
function ele:Show(f)
    if UnitCastingInfo(f.unit) then
        self:CastStart('UNIT_SPELLCAST_START',f,f.unit)
        return
    end

    if UnitChannelInfo(f.unit) then
        self:CastStart('UNIT_SPELLCAST_CHANNEL_START',f,f.unit)
        return
    end
end
function ele:Hide(f)
    f.handler:CastBarHide(ele.HIDE_FRAME,true)
end
-- events ######################################################################
function ele:CastStart(event,f,unit)
    local name,text,texture,startTime,endTime,guid,notInterruptible
    if event == 'UNIT_SPELLCAST_CHANNEL_START' then
        name,text,texture,startTime,endTime,_,notInterruptible = UnitChannelInfo(unit)
    else
        name,text,texture,startTime,endTime,_,guid,notInterruptible = UnitCastingInfo(unit)
    end
    if not name then return end

    startTime = startTime / 1000
    endTime   = endTime / 1000

    f.state.casting            = true
    f.cast_state.name          = text
    f.cast_state.icon          = texture
    f.cast_state.duration      = GetTime() - startTime
    f.cast_state.max           = endTime - startTime
    f.cast_state.guid          = guid
    f.cast_state.interruptible = not notInterruptible

    if event == 'UNIT_SPELLCAST_CHANNEL_START' then
        f.cast_state.channel = true
    end

    f.handler:CastBarShow()
end
function ele:CastStop(event,f,unit,guid)
    if not f.state.casting or guid ~= f.cast_state.guid then return end
    f.handler:CastBarHide(
        (event == 'UNIT_SPELLCAST_INTERRUPTED' and ele.HIDE_INTERRUPT) or
        (event == 'UNIT_SPELLCAST_SUCCEEDED' and ele.HIDE_SUCCESS) or
        ele.HIDE_STOP)
end
function ele:CastUpdate(event,f,unit)
    local startTime,endTime
    if f.cast_state.channel then
        _,_,_,startTime,endTime = UnitChannelInfo(unit)
    else
        _,_,_,startTime,endTime = UnitCastingInfo(unit)
    end

    if not startTime or not endTime then
        f.handler:CastBarHide(ele.HIDE_STOP)
        return
    end

    startTime = startTime / 1000
    endTime = endTime / 1000

    f.cast_state.duration = GetTime() - startTime
    f.cast_state.max = endTime - startTime

    f.handler:CastBarShow()
end
function ele:UNIT_SPELLCAST_CHANNEL_STOP(event,f)
    if not f.state.casting or not f.cast_state.channel then return end
    f.handler:CastBarHide(ele.HIDE_STOP)
end
-- enable/disable per frame ####################################################
function ele:EnableOnFrame(frame)
    if frame:IsShown() then
        self:Show(frame)
    end
end
function ele:DisableOnFrame(frame)
    if frame.state.casting then
        -- we need to force a hide here since the layout can only determine if
        -- it wants to disable the element after the frame is loaded (XXX)
        frame.handler:CastBarHide(ele.HIDE_FRAME,true)
        addon:DispatchMessage('CastBarHide',frame,ele.HIDE_FRAME,true)
    end
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
    self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED','CastUpdate')
    self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED','CastStop')
    self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','CastStop')

    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START','CastStart')
    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP')
    self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE','CastUpdate')

    for i,f in addon:Frames() do
        -- run create on missed frames
        self:Create(f)
    end
end
