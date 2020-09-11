-- scan tooltip to provide quest state
local addon = KuiNameplates
local mod = addon:NewPlugin('Quest')
local kui = LibStub('Kui-1.0')
if not mod then return end

Mixin(mod,kui.FrameLockMixin)

local tooltip = CreateFrame('GameTooltip','KNPQuestTooltip',UIParent,'GameTooltipTemplate')

-- local functions ############################################################
local function TooltipScanLines(func)
    local line,text,r
    for i=3,tooltip:NumLines() do
        line = _G['KNPQuestTooltipTextLeft'..i]
        text = line and line:GetText()
        if not text then break end
        -- quest progress text is indented, so...
        if floor((select(4,line:GetPoint(2)) or 0)+.5) == 28 then
            r = func(text)
            if r then return r end
        end
    end
end
local function TooltipWrapper(unit,func)
    tooltip:SetOwner(UIParent,ANCHOR_NONE)
    tooltip:SetUnit(unit)
    local r = TooltipScanLines(func)
    tooltip:Hide()
    return r
end
local function TooltipScan_ProgressText(text)
    -- look for lines matching A/B
    local a,b=text:match('(%d+)/(%d+)')
    a,b=tonumber(a),tonumber(b)
    if a and b then
        if a ~= b then
            return a..'/'..b
        end
    else
        -- look for lines matching (A%)
        a=text:match('%((%d+)%%%)')
        a=tonumber(a)
        if a and a < 100 then
            return a..'%'
        end
    end
end
local function GetQuestTextForUnit(unit)
    return TooltipWrapper(unit,TooltipScan_ProgressText)
end
local function UpdateQuestState(frame,dispatch)
    if UnitIsPlayer(frame.unit) then
        -- this could maybe lock state.quest as true since
        -- we're assuming it would never be set on a player..
        return
    end

    -- set state and dispatch message if different
    local str = GetQuestTextForUnit(frame.unit)
    if str ~= frame.state.quest then
        frame.state.quest = str
        if dispatch then
            addon:DispatchMessage('QuestUpdate',frame)
        end
    end
end
local function UpdateAllVisible()
    for _,f in addon:Frames() do
        if f.unit and f:IsShown() then
            UpdateQuestState(f,true)
        end
    end
end
-- events #####################################################################
function mod:QuestLogUpdate()
    self:FrameLockFunc(UpdateAllVisible)
end
-- messages ###################################################################
function mod:Show(f)
    UpdateQuestState(f)
end
function mod:OnEnable()
    self:RegisterMessage('Show')
    self:RegisterEvent('QUEST_LOG_UPDATE','QuestLogUpdate')
end
