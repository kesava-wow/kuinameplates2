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
-- fire events to listeners
local function event_frame_OnEvent(self,event,...)
    if not event_index[event] then
        self:UnregisterEvent(event)
        return
    end

    local unit,unit_frame,unit_not_found
    for i,table_tbl in ipairs(event_index[event]) do
        local table,func,unit_only = unpack(table_tbl)

        if unit_only and not unit and not unit_not_found then
            -- first unit_only listener; find nameplate
            unit = ...
            if unit then
                unit_frame = C_NamePlate.GetNamePlateForUnit(unit)
                unit_frame = unit_frame and unit_frame.kui
            else
                unit_not_found = true
            end
        end

        if not unit_only or unit_frame then
            if type(func) == 'string' and type(table[func]) == 'function' then
                func = table[func]
            elseif type(table[event]) == 'function' then
                func = table[event]
            end

            if type(func) == 'function' then
                if unit_only then
                    func(table, event, unit_frame, ...)
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
end

event_frame:SetScript('OnEvent',event_frame_OnEvent)
----------------------------------------------------------- message registrar --
local message = {}
message.__index = message
function message.RegisterMessage(table, message)
    if not table or not message then return end
    if table.layout then return end
    if not type(table[message]) == 'function' then return end
    if not listeners[message] then
        listeners[message] = {}
    end

    -- TODO make this consistent with events

    -- higher priority plugins are called later
    if #listeners[message] > 0 then
        local inserted
        for k,plugin in ipairs(listeners[message]) do
            if plugin.priority > table.priority then
                -- insert before a higher priority plugin
                tinsert(listeners[message], k, table)
                inserted = true
                break
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
function message.UnregisterMessage(table,message)
    if not table or not message then return end
    if table.layout then return end
    if not listeners[message] then return end

    for k,listener in ipairs(listeners[message]) do
        if listener == table then
            tremove(listeners[message],k)
            break
        end
    end
end
function message.UnregisterAllMessages(table)
    if not table then return end
    if table.layout then return end

    for message,_ in pairs(listeners) do
        table:UnregisterMessage(message)
    end
end
------------------------------------------------------------- event registrar --
local function pluginHasEvent(table,event)
    -- true if plugin is registered for given event
    return (type(table.__EVENTS) == 'table' and table.__EVENTS[event])
end
function message.RegisterEvent(table,event,func,unit_only)
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

    if not event_index[event] then
        event_index[event] = {}
    end

    -- TODO maybe allow overwrites possibly
    if pluginHasEvent(table,event) then return end

    local insert_tbl = { table, func, unit_only }

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

    event_frame:RegisterEvent(event)
end
function message.RegisterUnitEvent(table,event,func)
    table:RegisterEvent(event,func,true)
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
    if type(table.__EVENTS) ~= 'table' then return end
    for event,_ in pairs(table.__EVENTS) do
        table:UnregisterEvent(event)
    end
    table.__EVENTS = nil
end
--------------------------------------------------------------------------------
function message.Enable(table)
    if type(table.OnEnable) == 'function' then
        table:OnEnable()
    end
    -- TODO
    -- OnInitialise should always be called first
    -- then call OnEnable if the element is enabled
    -- OnEnable is where plugins register their messages/events/etc

    if table.element then
        for i,frame in addon:Frames() do
            frame.handler:EnableElement(table.name)
        end
    end
end
function message.Disable(table)
    if type(table.OnDisable) == 'function' then
        table:OnDisable()
    end

    table:UnregisterAllMessages()
    table:UnregisterAllEvents()

    if table.element then
        for i,frame in addon:Frames() do
            frame.handler:DisableElement(table.name)
        end
    end
end
------------------------------------------------------------ plugin registrar --
-- priority = any number. Defines the load order. Default of 5.
-- plugins with a higher priority are executed later (i.e. they override the
-- settings of any previous plugin)
function addon:NewPlugin(name,priority)
    if not name then
        addon:print('|cffff0000plugin with no name ignored')
        return
    end

    local pluginTable = {
        name = name,
        plugin = true,
        priority = type(priority)=='number' and priority or 5
    }

    setmetatable(pluginTable, message)
    tinsert(addon.plugins, pluginTable)

    return pluginTable
end
-------------------------------------------------- external element registrar --
-- elements are just plugins with a lower priority
function addon:NewElement(name)
    local ele = self:NewPlugin(name,0)
    ele.plugin = nil
    ele.element = true
    return ele
end
------------------------------------------------------------ layout registrar --
-- the layout is always executed last
function addon:Layout()
    -- TODO multiple layouts
    if addon.layout then return end
    addon.layout = {}
    setmetatable(addon.layout, message)
    addon.layout.layout = true
    return addon.layout
end
