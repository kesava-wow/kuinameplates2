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
addon.debug = false

local numFrames = 0
local PLATE_UPDATE_PERIOD = .1
local last_plate_update = PLATE_UPDATE_PERIOD

-- this is the size of the container, not the visible frame
-- changing it will cause positioning problems
local width, height = 142, 40
------------------------------------------------------------- find nameplates --
local function IsNameplate(frame)
    if not frame or not frame.GetName then return end
    local name = frame:GetName()
    if name and strfind(name, '^NamePlate%d') then
        return frame.ArtContainer and true or false
    end
end
local function FindNameplates()
    local frames = WorldFrame:GetNumChildren()

    if frames ~= numFrames then
        numFrames = frames

        local i,f
        local children = { WorldFrame:GetChildren() }

        for i = 1, frames do
            f = select(i, WorldFrame:GetChildren())

            if f and not f.kui and IsNameplate(f) then
                addon.HookNameplate(f)
                frameList[f] = true
            end
        end
    end
end
-- call plate update script every PLATE_UPDATE_PERIOD
local function IteratePlates(elap)
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
local function OnUpdate(self,elap)
    FindNameplates()
    IteratePlates(elap)
end
--------------------------------------------------------------------------------
local function OnEvent(self,event,...)
    if event ~= 'PLAYER_LOGIN' then return end
    self.uiscale = UIParent:GetEffectiveScale()

    -- get the pixel-perfect width/height of the default, non-trivial frames
    self.width, self.height = floor(width / self.uiscale), floor(height / self.uiscale)

    if self.layout then
        -- initialise the registered layout
        self.layout:Initialise()
    else
        -- throw missing layout
        print('|cff9900ffKui Namemplates|r: A compatible layout was not loaded. You probably forgot to enable Kui Nameplates: Core in your addon list.')
    end

    -- begin searching for nameplates
    self:SetScript('OnUpdate',OnUpdate)
end
------------------------------------------- initialise addon scripts & events --
addon:SetScript('OnEvent',OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
