--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Handle frame event listeners, dispatch messages, init plugins/elements/layout
--------------------------------------------------------------------------------
local addon = KuiNameplates
local kui = LibStub('Kui-1.0')

local k,listener,plugin,_
local type,strsub,pairs,ipairs,unpack,tinsert,tremove=
      type,strsub,pairs,ipairs,unpack,tinsert,tremove

local listeners = {}

local messages = {}
messages.__index = messages

-------------------------------------------------------------- debug helpers --
local function TableToString(tbl)
    if type(tbl) ~= 'table' then return end
    if type(tbl.state) == 'table' and type(tbl.state.name) == 'string' then
        -- assuming KNP frame
        return 'frame:`'..tbl.state.name..'`'
    elseif type(tbl.name) == 'string' then
        -- assuming KNP plugin
        return 'table:'..tbl.name
    end
end
local function VarArgsToString(...)
    local ac
    if #{...} > 0 then
        for k,v in pairs({...}) do
            if type(v) == 'table' then
                v = TableToString(v)
            end
            ac = (ac and ac..', '..k..':' or k..':')..tostring(v)
        end
    end
    return ac
end
local function PrintDebugForMessage(msg,listener,...)
    if addon.DEBUG_IGNORE and addon.DEBUG_IGNORE['m:'..msg] then return end

    local ac = VarArgsToString(...)
    addon:print('p:'..(listener.priority or '?')..' |cff88ff88m:'..msg..'|r > '..(listener.name or 'nil')..(ac and ' |cffaaaaaa'..ac or ''))
end
local function PrintDebugForEvent(event,table,unit,...)
    if addon.DEBUG_IGNORE and addon.DEBUG_IGNORE['e:'..event] then return end

    local ac = VarArgsToString(...)
    addon:print('p:'..(table.priority or '?')..' |cffffff88e:'..event..(unit and '|cff8888ff:'..unit or '')..'|r > '..(table.name or 'nil')..(ac and ' |cffaaaaaa'..ac or ''))
end
local function PrintDebugForCallback(plugin,callback,...)
    local fn = plugin.name..':'..callback
    if addon.DEBUG_IGNORE and addon.DEBUG_IGNORE['c:'..fn] then return end

    local ac = VarArgsToString(...)
    local cbc = type(plugin.callbacks[callback][1]) == 'function' and 1 or #plugin.callbacks[callback]
    addon:print('|cff88ffffc:'..fn..'|r:'..cbc..(ac and ' |cffaaaaaa'..ac or ''))
end

-- event/message performance tracer
local TraceStart,TraceEnd
do
    local ev_start,ev_sum,ev_count
    function TraceStart(uid)
        if not addon.profiling then return end
        UpdateAddOnCPUUsage()
        ev_start = ev_start or {}
        ev_start[uid] = GetAddOnCPUUsage('Kui_Nameplates')
    end
    function TraceEnd(uid)
        if not addon.profiling or not ev_start or not ev_start[uid] then 
            return
        end
        UpdateAddOnCPUUsage()
        local ev_end = GetAddOnCPUUsage('Kui_Nameplates')
        local ev_delta = ev_end - ev_start[uid]
        ev_start[uid] = nil

        ev_sum = ev_sum or {}
        ev_count = ev_count or {}

        ev_count[uid] = 1 + (ev_count[uid] or 0)
        ev_sum[uid] = ev_delta + (ev_sum[uid] or 0)
    end
    function addon:PrintTrace(sort_key)
        if not ev_count or not ev_sum then return end
        sort_key = (sort_key or 3)+1
        local ev_sort = {}
        for uid,count in pairs(ev_count) do
            local sum = ev_sum[uid]
            local avg = sum / count
            tinsert(ev_sort,{uid,count,sum,avg})
        end
        table.sort(ev_sort,function(a,b)
            return a[sort_key] > b[sort_key]
        end)
        local d = kui:DebugPopup()
        for i,v in ipairs(ev_sort) do
            d:AddText(format('|cffffff88%s|r #%d | sum: %.4fms | avg: %.4fms',unpack(v)))
        end
        d:Show()
    end
end
----------------------------------------------------- core message dispatcher --
function addon:DispatchMessage(msg,...)
    if listeners[msg] then
        --@debug@
        TraceStart('m:'..msg)
        --@end-debug@

        for i,listener_tbl in ipairs(listeners[msg]) do
            local listener,func = unpack(listener_tbl)

            if addon.debug_messages then
                PrintDebugForMessage(msg,listener,...)
            end

            if type(func) == 'string' and type(listener[func]) == 'function' then
                func = listener[func]
            elseif type(listener[msg]) == 'function' then
                func = listener[msg]
            end

            if type(func) == 'function' then
                func(listener,...)
            else
                addon:print(format('|cffff0000no listener for m:%s in %s',msg,listener.name or 'nil'))
            end
        end

        --@debug@
        TraceEnd('m:'..msg)
        --@end-debug@
    end
end
------------------------------------------------------------- event functions --
local unit_event_frame = CreateFrame('Frame')
local event_frame = CreateFrame('Frame')
local event_index = {}

-- iterate plugins/elements which have registered the given event
local function DispatchEventToListeners(event,unit,unit_frame,...)
    --@debug@
    TraceStart('e:'..event)
    --@end-debug@
 
    for i,listener_tbl in ipairs(event_index[event]) do
        local table,func = unpack(listener_tbl)

        -- resolve function...
        if type(func) == 'string' and type(table[func]) == 'function' then
            func = table[func]
        elseif type(table[event]) == 'function' then
            func = table[event]
        end

        -- call registered function
        if type(func) == 'function' then
            if unit_frame then
                func(table,event,unit_frame,unit,...)
            else
                func(table,event,...)
            end

            if addon.debug_events then
                PrintDebugForEvent(event,table,unit,...)
            end
        else
            addon:print('|cffff0000no listener for ue:'..event..' in '..(table.name or 'nil'))
        end
    end

    --@debug@
    TraceEnd('e:'..event)
    --@end-debug@
end
------------------------------------------------------------ unit event frame --
-- a "unit event" by this definition relies on the event returning a unit,
-- and a nameplate being available with that unit. We find the nameplate for
-- the plugin/element and pass it in an argument to its function, or do not
-- call the function if a nameplate cannot be found.
local function unit_event_frame_OnEvent(self,event,unit,...)
    if not event_index[event] then
        self:UnregisterEvent(event)
        return
    end

    -- find nameplate matching returned unit
    if not unit then
        addon:print('ue:'..event..':nil returned no unit')
        return
    end
    if type(unit) ~= 'string' or strsub(unit,1,9) ~= 'nameplate' then
        -- filter out non-nameplate units
        return
    end

    local frame = addon:GetActiveNameplateForUnit(unit)
    if not frame then
        -- this happens when restricted nameplates are visible,
        -- as events are still fired for those units
        return
    end

    DispatchEventToListeners(event,unit,frame,...)
end
unit_event_frame:SetScript('OnEvent',unit_event_frame_OnEvent)
---------------------------------------------------------- simple event frame --
local function event_frame_OnEvent(self,event,...)
    if not event_index[event] then
        self:UnregisterEvent(event)
        return
    end

    DispatchEventToListeners(event,nil,nil,...)
end
event_frame:SetScript('OnEvent',event_frame_OnEvent)
----------------------------------------------------------- message registrar --
local function pluginHasMessage(table,msg)
    return (type(table.__MESSAGES) == 'table' and table.__MESSAGES[msg])
end
function messages.RegisterMessage(table,msg,func)
    if not table then return end
    if not msg or type(msg) ~= 'string' then
        addon:print('|cffff0000invalid message passed to RegisterMessage by '..(table.name or 'nil'))
        return
    end
    if func and type(func) ~= 'string' and type(func) ~= 'function' then
        addon:print('|cffff0000invalid function passed to RegisterMessage by '..(table.name or 'nil'))
        return
    end

    if pluginHasMessage(table,msg) then return end

    if addon.debug_messages and table.name then
        addon:print(table.name..' registered m:'..msg)
    end

    if not listeners[msg] then
        listeners[msg] = {}
    end

    local insert_tbl = { table, func }

    -- insert by priority
    if #listeners[msg] > 0 then
        local inserted
        for k,listener in ipairs(listeners[msg]) do
            listener = listener[1]
            if listener.priority > table.priority then
                -- insert before a higher priority plugin
                tinsert(listeners[msg], k, insert_tbl)
                inserted = true
                break
            end
        end

        if not inserted then
            -- no higher priority plugin was found; insert at the end
            tinsert(listeners[msg], insert_tbl)
        end
    else
        -- no current listeners
        tinsert(listeners[msg], insert_tbl)
    end

    if not table.__MESSAGES then
        table.__MESSAGES = {}
    end
    table.__MESSAGES[msg] = true
end
function messages.UnregisterMessage(table,msg)
    if not pluginHasMessage(table,msg) then return end
    if type(listeners[msg]) == 'table' then
        for i,listener_tbl in ipairs(listeners[msg]) do
            if listener_tbl[1] == table then
                tremove(listeners[msg],i)
                table.__MESSAGES[msg] = nil
                return
            end
        end
    end
end
function messages.UnregisterAllMessages(table)
    if type(table.__MESSAGES) ~= 'table' then return end
    for msg,_ in pairs(table.__MESSAGES) do
        table:UnregisterMessage(msg)
    end
    table.__MESSAGES = nil
end
------------------------------------------------------------- event registrar --
local function pluginHasEvent(table,event)
    -- true if plugin is registered for given event
    return (type(table.__EVENTS) == 'table' and table.__EVENTS[event])
end
function messages.RegisterEvent(table,event,func,unit_only)
    -- unit_only: only fire callback if a valid nameplate exists for event unit
    if func and type(func) ~= 'string' and type(func) ~= 'function' then
        addon:print('|cffff0000invalid function passed to RegisterEvent by '..(table.name or 'nil'))
        return
    end
    if not event or type(event) ~= 'string' then
        addon:print('|cffff0000invalid event passed to RegisterEvent by '..(table.name or 'nil'))
        return
    end
    if unit_only and event:find('UNIT') ~= 1 then
        addon:print('|cffff0000unit_only doesn\'t make sense for '..event)
        return
    end

    -- XXX possibly allow overwrites
    -- what happens if a plugin registers an event as both types?
    -- does unregistering work correctly?
    if pluginHasEvent(table,event) then return end

    local insert_tbl = { table, func }
    event_index[event] = event_index[event] or {}

    -- insert by priority
    if #event_index[event] > 0 then
        local inserted
        for k,listener in ipairs(event_index[event]) do
            listener = listener[1]
            if listener.priority > table.priority then
                tinsert(event_index[event], k, insert_tbl)
                inserted = true
                break
            end
        end

        if not inserted then
            tinsert(event_index[event], insert_tbl)
        end
    else
        tinsert(event_index[event], insert_tbl)
    end

    if not table.__EVENTS then
        table.__EVENTS = {}
    end
    table.__EVENTS[event] = true

    if unit_only then
        unit_event_frame:RegisterEvent(event)
    else
        event_frame:RegisterEvent(event)
    end
end
function messages.RegisterUnitEvent(table,event,func)
    table:RegisterEvent(event,func,true)
end
function messages.UnregisterEvent(table,event)
    if not pluginHasEvent(table,event) then return end
    if type(event_index[event]) == 'table' then
        for i,r_table in ipairs(event_index[event]) do
            if r_table[1] == table then
                tremove(event_index[event],i)
                table.__EVENTS[event] = nil
                return
            end
        end
    end
end
function messages.UnregisterAllEvents(table)
    if type(table.__EVENTS) ~= 'table' then return end
    for event,_ in pairs(table.__EVENTS) do
        table:UnregisterEvent(event)
    end
    table.__EVENTS = nil
end
------------------------------------------------------------- callback helper --
local function VerifyCallbackArguments(table,target,name,func)
    if type(func) ~= 'function' then
        addon:print((table.name or 'nil')..': invalid call to AddCallback: no function')
        return
    end

    target = addon:GetPlugin(target)
    if not target then
        addon:print((table.name or 'nil')..': invalid call to Callback function: no plugin by given name')
        return
    end

    if type(target.__CALLBACKS) ~= 'table' or not target.__CALLBACKS[name] then
        addon:print((table.name or 'nil')..': no callback '..name..' in '..(target.name or 'nil'))
        return
    end

    return target
end
function messages.RegisterCallback(table,name,return_needed)
    -- register a callback to this plugin
    -- return_needed: only allow one callback function
    if not table.__CALLBACKS then
        table.__CALLBACKS = {}
    end
    table.__CALLBACKS[name] = return_needed and 2 or 1
end
function messages.AddCallback(table,target,name,func,priority)
    -- add a callback function
    target = VerifyCallbackArguments(table,target,name,func)
    if not target then return end

    if not priority then
        priority = table.priority or 0
    end

    local insert_tbl = { func,priority }

    if not target.callbacks then
        target.callbacks = {}
    end

    if target.__CALLBACKS[name] == 1 then
        if not target.callbacks[name] then
            target.callbacks[name] = {}
        end

        local inserted
        for i,cb in ipairs(target.callbacks[name]) do
            if cb[2] > priority then
                tinsert(target.callbacks[name],i,insert_tbl)
                inserted = true
                break
            end
        end

        if not inserted then
            tinsert(target.callbacks[name],insert_tbl)
        end
    elseif target.__CALLBACKS[name] == 2 then
        if not target.callbacks[name] or
           priority > target.callbacks[name][2]
        then
            target.callbacks[name] = insert_tbl
        end
    end
end
function messages.RemoveCallback(table,target,name,func)
    -- remove callback function matching given arguments
    target = VerifyCallbackArguments(table,target,name,func)
    if not target then return end
    if not target:HasCallback(name) then return end

    if target.__CALLBACKS[name] == 1 then
        for i,cb in ipairs(target.callbacks[name]) do
            if cb[1] == func then
                tremove(target.callbacks[name],i)
            end
        end
    else
        if target.callbacks[name][1] == func then
            target.callbacks[name] = nil
        end
    end
end
function messages.HasCallback(table,name)
    if  table.__CALLBACKS and table.__CALLBACKS[name] and table.callbacks and
        table.callbacks[name] and #table.callbacks[name] > 0
    then
        return true
    end
end
function messages.RunCallback(table,name,...)
    -- run this plugin's named callback
    if not table:HasCallback(name) then return end
    if addon.debug_callbacks then
        PrintDebugForCallback(table,name,...)
    end
    --@debug@
    TraceStart('c:'..name)
    --@end-debug@

    if table.__CALLBACKS[name] == 2 then
        -- inherit return from forced single callback
        --@debug@
        if addon.profiling then
            local r = {table.callbacks[name][1](...)}
            TraceEnd('c:'..name)
            return unpack(r)
        end
        --@end-debug@
        return table.callbacks[name][1](...)
    else
        for i,cb in ipairs(table.callbacks[name]) do
            cb[1](...)
        end
        --@debug@
        TraceEnd('c:'..name)
        --@end-debug@
        return true
    end
end
----------------------------------------------- plugin/element-only functions --
local function plugin_Enable(table)
    if not table.enabled then
        table.enabled = true

        if type(table.OnEnable) == 'function' then
            table:OnEnable()
        end
    end
end
local function plugin_Disable(table)
    if table.enabled then
        table.enabled = nil

        if type(table.OnDisable) == 'function' then
            table:OnDisable()
        end

        table:UnregisterAllMessages()
        table:UnregisterAllEvents()
    end
end
------------------------------------------------------------ plugin registrar --
-- priority         = Any number. Defines the load order. Default of 5.
--                    Plugins with a higher priority are executed later.
-- [max_minor]      = Maximum NKP minor this plugin is known to support.
--                    Ignored if nil.
-- [enable_on_load] = Enable this plugin upon initialise.
--                    True if nil.
function addon:NewPlugin(name,priority,max_minor,enable_on_load)
    if not name then
        error('Plugin with no name ignored')
        return
    end

    if (name == 'BarAuras' and not max_minor) or -- XXX legacy
       (max_minor and self.MINOR > max_minor)
    then
        error('Ignoring out of date plugin: `'..name..'`')
        return
    end

    if enable_on_load == nil then
        enable_on_load = true
    end

    local pluginTable = {
        Enable = plugin_Enable,
        Disable = plugin_Disable,
        name = name,
        enable_on_load = enable_on_load,
        plugin = true,
        priority = tonumber(priority) or 5
    }
    setmetatable(pluginTable, messages)
    tinsert(addon.plugins, pluginTable)

    return pluginTable
end
function addon:GetPlugin(name)
    for i,plugin in ipairs(addon.plugins) do
        if plugin.name == name then return plugin end
    end
end
-------------------------------------------------- external element registrar --
-- elements are just plugins with a lower default priority
function addon:NewElement(name,priority,max_minor)
    local ele = self:NewPlugin(name,tonumber(priority) or 0,max_minor,true)
    ele.plugin = nil
    ele.element = true
    return ele
end
------------------------------------------------------------ layout registrar --
function addon:Layout()
    if self.layout then
        self:ui_print('More than one layout is enabled.')
        return
    end

    self.layout = {
        layout = true,
        priority = 100
    }
    setmetatable(self.layout, messages)

    return self.layout
end
