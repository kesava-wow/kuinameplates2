--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Handle frame event listeners, dispatch messages, init plugins/elements/layout
--------------------------------------------------------------------------------
local addon = KuiNameplates

local k,listener,plugin,_
local listeners = {}

function addon:DispatchMessage(message, ...)
    if listeners[message] then
        -- call plugin listeners...
        for k,listener in ipairs(listeners[message]) do
            listener[message](...)
        end
    end

    if addon.layout and addon.layout[message] then
        -- ... and the layout's listener
        addon.layout[message](...)
    end

    if addon.debug_messages then
        addon:print('dispatched message: '..message)
    end
end
----------------------------------------------------------------- event frame --
local event_frame = CreateFrame('Frame')
local event_listeners = {}

local function event_frame_OnEvent(self,event,...)
    if not event_listeners[event] then
        self:UnregisterEvent(event)
        return
    end

    local unit_frame,unit
    if event:sub(1,4) == 'UNIT' then
        unit = ...
        unit_frame = addon:GetNameplateByUnit(unit)
        if not unit_frame then return end
    end

    for table,func in pairs(event_listeners[event]) do
        if type(func) == 'string' and type(table[func]) == 'function' then
            func = table[func]
        elseif type(table[event]) == 'function' then
            func = table[event]
        end

        if type(func) == 'function' then
            if unit_frame then
                func(table, event, unit_frame, unit, ...)
            else
                func(table, event, ...)
            end
        else
            addon:print('|cffff0000no event listener for '..event..' in '..(table.name or 'nil'))
        end
    end
end

event_frame:SetScript('OnEvent',event_frame_OnEvent)
----------------------------------------------------------- message registrar --
local message = {}
message.__index = message
function message.RegisterMessage(table, message)
    if not table or not message then return end
    if not table.plugin then return end
    if not listeners[message] then
        listeners[message] = {}
    end

    -- higher priority plugins are called later
    if #listeners[message] > 0 then
        local inserted
        for k,plugin in ipairs(listeners[message]) do
            if plugin.priority > table.priority then
                -- insert before a higher priority plugin
                tinsert(listeners[message], k, table)
                inserted = true
            end
        end

        if not inserted then
            -- no higher priority plugin was found; insert at the end
            tinsert(listeners[message], table)
        end
    else
        tinsert(listeners[message], table)
    end
end
------------------------------------------------------------- event registrar --
function message.RegisterEvent(table,event,func)
    if not event_listeners[event] then
        event_listeners[event] = {}
    end

    event_listeners[event][table] = func or true

    event_frame:RegisterEvent(event)
end
function message.UnregisterEvent(table,event)
    if not event_listeners[event] then return end

    if event_listeners[event][table] then
        event_listeners[event][table] = nil
    end

    if #event_listeners[event] == 0 then
        event_listeners[event] = nil
    end
end
function message.UnregisterAllEvents(table)
    for event,t in pairs(event_listeners) do
        if t[table] then
            t[table] = nil
        end

        if #t == 0 then
            event_listeners[event] = nil
        end
    end
end
------------------------------------------------------------ plugin registrar --
-- priority = any number. Defines the load order. Default of 5.
-- plugins with a higher priority are executed later (i.e. they override the
-- settings of any previous plugin)
function addon:NewPlugin(priority)
    local pluginTable = {
        plugin = true,
        priority = priority or 5
    }
    setmetatable(pluginTable, message)
    tinsert(addon.plugins, pluginTable)
    return pluginTable
end
-------------------------------------------------- external element registrar --
function addon:NewElement(name)
    local ele = {
        name = name,
        plugin = true,
        priority = 0
    }

    setmetatable(ele, message)
    addon.elements[name] = ele

    return ele
end
------------------------------------------------------------ layout registrar --
-- the layout is always executed last
function addon:Layout()
    if addon.layout then return end
    addon.layout = {}
    setmetatable(addon.layout, message)
    return addon.layout
end
