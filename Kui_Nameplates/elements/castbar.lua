--[[
    Provides cast state and dispatches cast bar messages.

    Elements
    ========

    [StatusBar] CastBar
        Value and min/max values updated while a cast is ongoing.

    [FontString] SpellName
        Set to name of spell being cast.

    [Texture] SpellIcon
        Set to icon of spell being cast.

    Messages
    ========

    CastBarShow(frame)
        Informs the layout that cast information is available in the frames'
        `cast_state` table, as such:
            name = The spell's name.
            icon = The spell's icon texture.
            start_time = Time of cast start (in seconds)
            end_time = Time of cast end.
            guid = Cast event GUID.
            interruptible = True if the cast can be interrupted.

    CastBarHide(frame,hide_cause,force)
        Informs the layout that the cast bar should be hidden.
        `hide_cause`
            ele.HIDE_FRAME (0): The frame was hidden.
            ele.HIDE_INTERRUPT (1): The cast was interrupted.
            ele.HIDE_STOP (2): The cast or channel was stopped.
            ele.HIDE_SUCCESS (3): The cast was successful.
        `force`
            True upon frame hiding or element being disabled.
]]
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')
local ele = addon:NewElement('CastBar')
local _,LibCC,UnitCastingInfo,UnitChannelInfo

-- castbar hide causes (first argument of CastBarHide)
ele.HIDE_FRAME=0
ele.HIDE_INTERRUPT=1
ele.HIDE_STOP=2
ele.HIDE_SUCCESS=3

-- cast bar update scripts #####################################################
local function CastBarUpdate_Cast(self,elap)
    self.parent.CastBar:SetValue(self.parent.CastBar:GetValue()+elap)
end
local function CastBarUpdate_Channel(self,elap)
    self.parent.CastBar:SetValue(self.parent.CastBar:GetValue()-elap)
end
-- prototype additions #########################################################
function addon.Nameplate.CastBarShow(f)
    f = f.parent

    if f.elements.CastBar then
        f.CastBar:SetMinMaxValues(0,f.cast_state.end_time-f.cast_state.start_time)

        if f.cast_state.channel then
            f.CastBar:SetValue((f.cast_state.end_time-f.cast_state.start_time)-(GetTime()-f.cast_state.start_time))
            f.CastBarUpdateFrame:SetScript('OnUpdate',CastBarUpdate_Channel)
        else
            f.CastBar:SetValue(GetTime()-f.cast_state.start_time)
            f.CastBarUpdateFrame:SetScript('OnUpdate',CastBarUpdate_Cast)
        end

        f.CastBarUpdateFrame.duration = nil
        f.CastBarUpdateFrame:Show()
    end

    if f.elements.SpellName then
        f.SpellName:SetText(f.cast_state.name)
    end

    if f.elements.SpellIcon then
        f.SpellIcon:SetTexture(f.cast_state.icon)
    end

    addon:DispatchMessage('CastBarShow', f)
end
function addon.Nameplate.CastBarHide(f,hide_cause,force)
    f = f.parent
    if not f.state.casting then return end

    f.CastBarUpdateFrame:SetScript('OnUpdate',nil)
    f.CastBarUpdateFrame:Hide()

    f.state.casting = nil
    wipe(f.cast_state)

    addon:DispatchMessage('CastBarHide',f,hide_cause,force)
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

    f.state.casting            = true
    f.cast_state.name          = text or name
    f.cast_state.icon          = texture
    f.cast_state.guid          = guid
    f.cast_state.interruptible = not notInterruptible
    f.cast_state.channel       = event == 'UNIT_SPELLCAST_CHANNEL_START'
    f.cast_state.start_time    = startTime / 1000
    f.cast_state.end_time      = endTime / 1000

    f.handler:CastBarShow()
end
function ele:CastStop(event,f,_,guid)
    if not f.state.casting or guid ~= f.cast_state.guid then return end
    f.handler:CastBarHide(
        ((event == 'UNIT_SPELLCAST_INTERRUPTED' or event == 'UNIT_SPELLCAST_FAILED') and ele.HIDE_INTERRUPT) or
        (event == 'UNIT_SPELLCAST_SUCCEEDED' and ele.HIDE_SUCCESS) or
        ele.HIDE_STOP)
end
function ele:CastInterruptible(_,f)
    if not f.state.casting then return end
    f.cast_state.interruptible = true
    f.handler:CastBarShow()
end
function ele:CastNotInterruptible(_,f)
    if not f.state.casting then return end
    f.cast_state.interruptible = false
    f.handler:CastBarShow()
end
function ele:CastUpdate(_,f,unit)
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

    f.cast_state.start_time = startTime / 1000
    f.cast_state.end_time   = endTime / 1000

    f.handler:CastBarShow()
end
function ele:UNIT_SPELLCAST_CHANNEL_STOP(_,f)
    if not f.state.casting or not f.cast_state.channel then return end
    f.handler:CastBarHide(ele.HIDE_STOP)
end
-- enable/disable per frame ####################################################
function ele:EnableOnFrame(frame)
    if not self.enabled then return end
    if frame:IsShown() then
        self:Show(frame)
    end
end
function ele:DisableOnFrame(frame)
    if frame.state.casting then
        frame.handler:CastBarHide(ele.HIDE_FRAME,true)
    end
end
-- castbar lib callbacks #######################################################
local function LibCC_Resolve(target,event,unit,...)
    if not event or not unit then return end
    local frame = addon:GetActiveNameplateForUnit(unit)
    if frame then
        ele[target](ele,event,frame,unit,...)
    end
end
local function LibCC_CastStart(...)
    LibCC_Resolve('CastStart',...)
end
local function LibCC_CastStop(...)
    LibCC_Resolve('CastStop',...)
end
local function LibCC_CastUpdate(...)
    LibCC_Resolve('CastUpdate',...)
end
local function LibCC_ChannelStop(...)
    LibCC_Resolve('UNIT_SPELLCAST_CHANNEL_STOP',...)
end
-- register ####################################################################
function ele:Initialise()
    if kui.CLASSIC then
        LibCC = LibStub('LibClassicCasterino',true)
        if not LibCC then return end

        UnitCastingInfo = function(unit)
            return LibCC:UnitCastingInfo(unit)
        end
        UnitChannelInfo = function(unit)
            return LibCC:UnitChannelInfo(unit)
        end
    else
        UnitCastingInfo = _G['UnitCastingInfo']
        UnitChannelInfo = _G['UnitChannelInfo']
    end
end
function ele:OnDisable()
    if LibCC then
        LibCC.UnregisterAllCallbacks(self)
    end
    for _,f in addon:Frames() do
        self:DisableOnFrame(f)
    end
end
function ele:OnEnable()
    if not kui.CLASSIC then
        self:RegisterUnitEvent('UNIT_SPELLCAST_START','CastStart')
        self:RegisterUnitEvent('UNIT_SPELLCAST_STOP','CastStop')
        self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED','CastUpdate')
        self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED','CastStop')
        self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','CastStop')
        self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED','CastStop')

        self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTIBLE','CastInterruptible')
        self:RegisterUnitEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE','CastNotInterruptible')

        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START','CastStart')
        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP')
        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE','CastUpdate')
    elseif LibCC then
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_START',LibCC_CastStart)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_STOP',LibCC_CastStop)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_DELAYED',LibCC_CastUpdate)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_INTERRUPTED',LibCC_CastStop)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_FAILED',LibCC_CastStop)

        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_CHANNEL_START',LibCC_CastStart)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_CHANNEL_STOP',LibCC_ChannelStop)
        LibCC.RegisterCallback(self,'UNIT_SPELLCAST_CHANNEL_UPDATE',LibCC_CastUpdate)
    else
        return false
    end

    self:RegisterMessage('Create')
    self:RegisterMessage('Show')
    self:RegisterMessage('Hide')

    for _,f in addon:Frames() do
        -- run create on missed frames
        self:Create(f)
    end
end
