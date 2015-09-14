--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Handle frame event listeners
--------------------------------------------------------------------------------
local addon = KuiNameplates

local k,listener,plugin
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
end
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
------------------------------------------------------------ layout registrar --
-- the layout is always executed last
function addon:Layout()
    if addon.layout then return end
    addon.layout = {}
    setmetatable(addon.layout, message)
    return addon.layout
end
