--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Initialise addon events & begin to find nameplates
--------------------------------------------------------------------------------
KuiNameplates = CreateFrame('Frame')
local addon = KuiNameplates
addon.MAJOR,addon.MINOR = 2,4

--@debug@
addon.debug = true
--addon.debug_config = true
--addon.debug_units = true
--addon.debug_messages = true
--addon.debug_events = true
--addon.debug_callbacks = true
--addon.draw_frames = true
--@end-debug@
addon.DEBUG_IGNORE = {
    ['m:Create'] = true,
    ['m:Show'] = true,
    ['m:Hide'] = true,
    ['m:HealthUpdate'] = true,
    ['m:HealthColourChange'] = true,
    ['e:UNIT_POWER_UPDATE'] = true,
    ['e:UNIT_POWER_FREQUENT'] = true,
    ['e:UNIT_HEALTH_FREQUENT'] = true,
    ['e:UNIT_AURA'] = true,
    ['e:UNIT_ABSORB_AMOUNT_CHANGED'] = true,
    ['c:Auras:DisplayAura'] = true,
    ['c:Auras:PostDisplayAuraButton'] = true,
    ['c:Auras:PostUpdateAuraFrame'] = true,
}

-- can be changed during run time:
addon.IGNORE_UISCALE = nil
-- should be set in layout initialise, if desired:
addon.USE_BLIZZARD_PERSONAL = nil

local framelist = {}

-- plugin & element vars
local sort, tinsert = table.sort, tinsert
local UnitIsUnit = UnitIsUnit
local function PluginSort(a,b)
    return a.priority < b.priority
end
addon.plugins = {}
--------------------------------------------------------------------------------
function addon:print(...)
    if not addon.debug then return end
    print('KNP2','|cff666666'..GetTime()..'|r',...)
end
function addon:ui_print(...)
    print('|cffbb99ffKui Nameplates|r',...)
end
function addon:Frames()
    return ipairs(framelist)
end
function addon:GetActiveNameplateForUnit(unit)
    -- return nameplate.kui for unit, if extant, visible and maybe functional
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if f and f.kui and f.kui.unit and f.kui:IsShown() then
        return f.kui
    end
end
--------------------------------------------------------------------------------
function addon:NAME_PLATE_CREATED(frame)
    self:HookNameplate(frame)

    if frame.kui then
        tinsert(framelist,frame.kui)
    end
end
function addon:NAME_PLATE_UNIT_ADDED(unit)
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if not f then return end

    if addon.debug_units then
        self:print('unit |cff88ff88added|r: '..unit..' ('..UnitName(unit)..')')
    end

    if not self.USE_BLIZZARD_PERSONAL or not UnitIsUnit(unit,'player') then
        -- don't process anything for the personal nameplate if disabled
        f.kui.handler:OnUnitAdded(unit)
    end
end
function addon:NAME_PLATE_UNIT_REMOVED(unit)
    local f = self:GetActiveNameplateForUnit(unit)
    if not f then return end

    if addon.debug_units then
        self:print('unit |cffff8888removed|r: '..unit..' ('..f.state.name..')')
    end
    f.handler:OnHide()
end
function addon:PLAYER_LEAVING_WORLD()
    if #framelist > 0 then
        for i,f in self:Frames() do
            if f:IsShown() then
                f.handler:OnHide()
            end
        end
    end
end
function addon:UI_SCALE_CHANGED()
    if self.IGNORE_UISCALE then
        -- set 1:1 scale from screen width
        local screen_size = {GetPhysicalScreenSize()}
        if screen_size and screen_size[2] then
            self.uiscale = 768 / screen_size[2]
        end
    else
        -- inherit from uiparent
        self.uiscale = UIParent:GetScale()
    end

    if #framelist > 0 then
        for i,f in self:Frames() do
            f:SetScale(self.uiscale)
        end
    end
end
--------------------------------------------------------------------------------
local function OnEvent(self,event,...)
    if event ~= 'PLAYER_LOGIN' then
        if self[event] then
            self[event](self,...)
        end
        return
    end

    self:UI_SCALE_CHANGED()

    if not self.layout then
        -- throw missing layout
        self:ui_print('A compatible layout was not loaded.')
        print(' Make sure Kui Nameplates: Core is enabled, or reinstall the addon from Curse if it isn\'t present.')
        return
    end

    -- initialise plugins & elements
    if #self.plugins > 0 then
        -- sort to be initialised by order of priority
        sort(self.plugins, PluginSort)

        for k,plugin in ipairs(self.plugins) do
            if type(plugin.Initialise) == 'function' then
                plugin:Initialise()
            end

            if plugin.enable_on_load then
                -- enable on load if requested
                plugin:Enable()
            end
        end
    end

    -- initialise the layout
    if type(self.layout.Initialise) == 'function' then
        self.layout:Initialise()
    end

    -- fire layout initialised to plugins
    -- for plugins to fetch values from the layout, etc
    for k,plugin in ipairs(self.plugins) do
        if type(plugin.Initialised) == 'function' then
            plugin:Initialised()
        end
    end
end
------------------------------------------- initialise addon scripts & events --
addon:SetScript('OnEvent',OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent('PLAYER_LEAVING_WORLD')
addon:RegisterEvent('NAME_PLATE_CREATED')
addon:RegisterEvent('NAME_PLATE_UNIT_ADDED')
addon:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
addon:RegisterEvent('UI_SCALE_CHANGED')
