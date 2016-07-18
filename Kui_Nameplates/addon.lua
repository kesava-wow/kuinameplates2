--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Initialise addon events & begin to find nameplates
--------------------------------------------------------------------------------
-- initalise addon global
KuiNameplates = CreateFrame('Frame')
local addon = KuiNameplates
addon.MAJOR,addon.MINOR=2,1

addon.debug = true
--addon.debug_units = true
--addon.debug_messages = true
--addon.draw_frames = true

-- kui nameplate container frame size
addon.uiscale = .71 -- updated upon reload
addon.width,addon.height = 140,40

local framelist = {}

-- plugin & element vars
local sort, tinsert = table.sort, tinsert
local function PluginSort(a,b)
    return a.priority < b.priority
end
addon.plugins = {}
--------------------------------------------------------------------------------
function addon:print(msg)
    if not addon.debug then return end
    print('|cff666666KNP2 '..GetTime()..':|r '..(msg and msg or nil))
end
function addon:Frames()
    return ipairs(framelist)
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

    f.kui.handler:OnUnitAdded(unit)
end
function addon:NAME_PLATE_UNIT_REMOVED(unit)
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if not f then return end

    if f.kui:IsShown() then
        if addon.debug_units then
            self:print('unit |cffff8888removed|r: '..unit..' ('..f.kui.state.name..')')
        end

        f.kui.handler:OnHide()
    end
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
    self.uiscale = UIParent:GetEffectiveScale()

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

    if not IsAddOnLoaded('Blizzard_Nameplates') then
        print('|cff9966ffKui Namemplates|r: You have disabled the built-in Blizzard_Nameplates addon which KNP requires. There will be errors. You can re-enable it with:')
        print('    /run EnableAddOn(\'Blizzard_Nameplates\')')
    end

    if not self.layout then
        -- throw missing layout
        print('|cff9966ffKui Namemplates|r: A compatible layout was not loaded. You probably forgot to enable Kui Nameplates: Core in your addon list.')
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

            plugin:Enable()
        end
    end

    if type(self.layout.Initialise) == 'function' then
        self.layout:Initialise()
    end

    addon:DispatchMessage('Initialised')
end
------------------------------------------- initialise addon scripts & events --
addon:SetScript('OnEvent',OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent('PLAYER_LEAVING_WORLD')
addon:RegisterEvent('NAME_PLATE_CREATED')
addon:RegisterEvent('NAME_PLATE_UNIT_ADDED')
addon:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
addon:RegisterEvent('UI_SCALE_CHANGED')
