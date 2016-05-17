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
    if addon.debug_messages then
        addon:print('dispatch message: '..message)
    end

    if listeners[message] then
        -- call plugin listeners...
        for _,listener in ipairs(listeners[message]) do
            listener[message](...)
        end
    end

    if addon.layout and addon.layout[message] then
        -- ... and the layout's listener
        addon.layout[message](...)
    end
end
----------------------------------------------------------------- event frame --
local event_frame = CreateFrame('Frame')
local event_index = {}

local function event_frame_OnEvent(self,event,...)
    if not event_index[event] then
        self:UnregisterEvent(event)
        return
    end

    local unit_frame,unit
    if event:find('UNIT') == 1 then
        unit = ...
        unit_frame = C_NamePlate.GetNamePlateForUnit(unit)
        if unit_frame then
            unit_frame = unit_frame.kui
        else
            unit_frame = nil
        end
    end

    for i,table_tbl in ipairs(event_index[event]) do
        local table,func = unpack(table_tbl)

        if type(func) == 'string' and type(table[func]) == 'function' then
            func = table[func]
        elseif type(table[event]) == 'function' then
            func = table[event]
        end

        if type(func) == 'function' then
            if unit and unit_frame then
                func(table, event, unit_frame, unit, select(2,...))
            elseif unit then
                func(table, event, nil, unit, select(2,...))
            else
                func(table, event, ...)
            end

            if addon.debug_messages then
                addon:print('event '..event..(unit and ' ['..unit..']' or '')..' > '..(table.name or 'nil'))
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
    if not type(table[message]) == 'function' then return end
    if not listeners[message] then
        listeners[message] = {}
    end

    -- higher priority plugins are called later
    if #listeners[message] > 0 then
        local inserted
        for k,plugin in ipairs(listeners[message]) do
            if not inserted and plugin.priority > table.priority then
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
local function pluginHasEvent(table,event)
    -- true if plugin is registered for given event
    return (type(table.__EVENTS) == 'table' and table.__EVENTS[event])
end
function message.RegisterEvent(table,event,func)
    if not event_index[event] then
        event_index[event] = {}
    end

    if pluginHasEvent(table,event) then return end

    -- insert by priority
    if #event_index[event] > 0 then
        local inserted
        for k,plugin in ipairs(event_index[event]) do
            if not inserted and (plugin.priority or 0) > (table.priority or 0) then
                tinsert(event_index[event], k, { table, func })
                inserted = true
            end
        end

        if not inserted then
            tinsert(event_index[event], { table, func })
        end
    else
        tinsert(event_index[event], { table, func })
    end

    if not table.__EVENTS then
        table.__EVENTS = {}
    end
    table.__EVENTS[event] = true

    event_frame:RegisterEvent(event)
end
function message.UnregisterEvent(table,event)
    if not pluginHasEvent(table,event) then return end
    if type(event_index[event]) == 'table' then
        for i,r_table in pairs(event_index[event]) do
            if r_table[1] == table then
                tremove(event_index[event],i)
                table.__EVENTS[event] = nil
                return
            end
        end
    end
end
function message.UnregisterAllEvents(table)
    if type(table.__EVENTS) ~= 'table' or #table.__EVENTS == 0 then return end
    for event,_ in pairs(table.__EVENTS) do
        table:UnregisterEvent(event)
    end
end
------------------------------------------------------------ plugin registrar --
-- priority = any number. Defines the load order. Default of 5.
-- plugins with a higher priority are executed later (i.e. they override the
-- settings of any previous plugin)
function addon:NewPlugin(priority,name)
    local pluginTable = {
        name = name,
        plugin = true,
        priority = priority or 5
    }

    setmetatable(pluginTable, message)
    tinsert(addon.plugins, pluginTable)

    return pluginTable
end
-------------------------------------------------- external element registrar --
-- elements are just plugins with a lower priority
function addon:NewElement(name)
    return self:NewPlugin(0,name)
end
------------------------------------------------------------ layout registrar --
-- the layout is always executed last
function addon:Layout()
    if addon.layout then return end
    addon.layout = {}
    setmetatable(addon.layout, message)
    return addon.layout
end
