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
local event_listeners = {}
local event_index = {}

local function event_frame_OnEvent(self,event,...)
    if not event_listeners[event] then
        self:UnregisterEvent(event)
        return
    end

    local unit_frame,unit
    if event:find('UNIT') == 1 then
        unit = ...
        if unit:find('nameplate') ~= 1 then return end

        unit_frame = C_NamePlate.GetNamePlateForUnit(unit)
        if not unit_frame then return end

        unit_frame = unit_frame.kui
    end

    for _,table in ipairs(event_index[event]) do
        local func = event_listeners[event][table]

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
function message.RegisterEvent(table,event,func)
    if not event_listeners[event] then
        event_listeners[event] = {}
        event_index[event] = {}
    end

    event_listeners[event][table] = func or true

    -- also insert into index by priority
    if #event_index[event] > 0 then
        local inserted
        for k,plugin in ipairs(event_index[event]) do
            if not inserted and plugin.priority > table.priority then
                tinsert(event_index[event], k, table)
                inserted = true
            end
        end

        if not inserted then
            tinsert(event_index[event], table)
        end
    end

    tinsert(event_index[event], table)

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

    -- also remove from index
    for k,v in event_index[event] do
        if v == table then
            tremove(event_index,k)
        end
    end
end
function message.UnregisterAllEvents(table)
    for event,_ in pairs(event_listeners) do
        message.UnregisterEvent(table,event)
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
