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
local frameList = {}
local unit_to_frame = {}
addon.debug = true
--addon.draw_frames = true

-- plugin vars
addon.plugins = {}
local sort, tinsert = table.sort, tinsert
local function PluginSort(a,b)
    return a.priority > b.priority
end

local PLATE_UPDATE_PERIOD = .1
local last_plate_update = PLATE_UPDATE_PERIOD

-- this is the size of the container, not the visible frame
-- changing it will cause positioning problems
local width, height = 142, 40
--------------------------------------------------------------------------------
function addon:print(msg)
    if not addon.debug then return end
    print('|cff666666KNP2 '..GetTime()..':|r '..(msg and msg or nil))
end
function addon:UnitHasNameplate(unit)
    return unit_to_frame[unit] and true or nil
end
function addon:GetNameplateByUnit(unit)
    return unit_to_frame[unit] and unit_to_frame[unit].kui or nil
end
--------------------------------------------------------------------------------
local function OnUpdate(self,elap)
    -- call plate update script every PLATE_UPDATE_PERIOD
    last_plate_update = last_plate_update + elap

    if last_plate_update > PLATE_UPDATE_PERIOD then
        last_plate_update = 0

        local f,_
        for f,_ in pairs(frameList) do
            if f.kui:IsShown() then
                f.kui.handler:Update()
            end
        end
    end
end
--------------------------------------------------------------------------------
function addon:NAME_PLATE_CREATED(frame)
    self.HookNameplate(frame)
    frameList[frame] = true
end
function addon:NAME_PLATE_UNIT_ADDED(unit)
    for f,_ in pairs(frameList) do
        if f.namePlateUnitToken == unit then
            if unit_to_frame[unit] and unit_to_frame[unit] ~= f then
                -- TODO DEBUG
                self:print('|cffff0000unit overwritten|r: '..unit)
                f.kui.handler:OnHide()
            end

            unit_to_frame[unit] = f
            f.kui.handler:OnUnitAdded(unit)
        end
    end
end
function addon:NAME_PLATE_UNIT_REMOVED(unit)
    local f = unit_to_frame[unit]
    if not f then return end
    unit_to_frame[unit] = nil

    if f.kui:IsShown() then
        self:print('unit lost: '..unit..' ('..f.kui.state.name..')')
        f.kui.handler:OnHide()
    end
end
----------------------------------------------------------------- unit events --
-- TODO should put this stuff in another file since there will be a lot
function addon:UNIT_HEALTH(unit)
    if not self:UnitHasNameplate(unit) then return end
    self:GetNameplateByUnit(unit).handler:OnHealthUpdate()
end
addon:RegisterEvent('UNIT_HEALTH')
--------------------------------------------------------------------------------
local function OnEvent(self,event,...)
    if event ~= 'PLAYER_LOGIN' then
        if self[event] then
            self[event](self,...)
        end
        return
    end
    self.uiscale = UIParent:GetEffectiveScale()

    -- get the pixel-perfect width/height of the default, non-trivial frames
    self.width, self.height = floor(width / self.uiscale), floor(height / self.uiscale)

    -- initialise plugins
    if #self.plugins > 0 then
        sort(self.plugins, PluginSort)
        for k,plugin in ipairs(self.plugins) do
            plugin:Initialise()
        end
    end

    if not self.layout then
        -- throw missing layout
        print('|cff9966ffKui Namemplates|r: A compatible layout was not loaded. You probably forgot to enable Kui Nameplates: Core in your addon list.')
    else
        if self.layout.Initialise then
            self.layout:Initialise()
        end
    end

    -- begin searching for nameplates
    self:SetScript('OnUpdate',OnUpdate)
end
------------------------------------------- initialise addon scripts & events --
addon:SetScript('OnEvent',OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent('NAME_PLATE_CREATED')
addon:RegisterEvent('NAME_PLATE_UNIT_ADDED')
addon:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
