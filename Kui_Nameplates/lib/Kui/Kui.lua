local MAJOR, MINOR = 'Kui-1.0', 18
local kui = LibStub:NewLibrary(MAJOR, MINOR)

if not kui then
    -- already registered
    return
end

local TRILLION=1000000000000
local BILLION=1000000000
local MILLION=1000000
local THOUSAND=1000
--------------------------------------------------------------- media / files --
local media = "Interface\\AddOns\\Kui_Media\\"
kui.m = {
    t = {
        -- borders
        shadow  = media .. 't\\shadowBorder',
        rounded = media .. 't\\solidRoundedBorder',

        -- textures
        solid       = media .. 't\\solid',
        innerShade  = media .. 't\\innerShade',

        -- progress bars
        bar     = media .. 't\\bar',
        oldbar  = media .. 't\\bar-old',
        sbar    = media .. 't\\barSmall',

        empty = media..'t\\empty',
    },
    f = {
        yanone   = media..'f\\yanone.ttf',
        francois = media..'f\\francois.ttf',
    },
}
------------------------------------------------------------------ var tables --
local ct = { -- classification table
    elite     = { '+',  'elite'      },
    rare      = { 'r',  'rare'       },
    rareelite = { 'r+', 'rare elite' },
    worldboss = { 'b',  'boss'       }
}
------------------------------------------------------------------- functions --
kui.table_to_string = function(tbl,depth)
    if depth and depth >= 3 then
        return '{ ... }'
    end
    local str
    for k,v in pairs(tbl) do
        if type(v) ~= 'userdata' then
            if type(v) == 'table' then
                v = kui.table_to_string(v,(depth and depth+1 or 1))
            elseif type(v) == 'function' then
                v = 'function'
            elseif type(v) == 'string' then
                v = '"'..v..'"'
            end

            if type(k) == 'string' then
                k = '"'..k..'"'
            end

            str = (str and str..'|cff999999,|r ' or '|cff999999{|r ')..'|cffffff99['..tostring(k)..']|r |cff999999=|r |cffffffff'..tostring(v)..'|r'
        end
    end
    return (str or '{ ')..' }'
end
kui.print = function(...)
    local msg
    for k,v in ipairs({...}) do
        if type(v) == 'table' then
            v = kui.table_to_string(v)
        end
        msg = (msg and msg..', ' or '')..tostring(v)
    end
    print(GetTime()..': '..(msg or 'nil'))
end
kui.GetClassColour = function(class, str)
    if not class then
        class = select(2, UnitClass('player'))
    elseif not RAID_CLASS_COLORS[class] then
        -- assume class is a unit
        class = select(2, UnitClass(class))
    end

    if CUSTOM_CLASS_COLORS then
        class = CUSTOM_CLASS_COLORS[class]
    else
        class = RAID_CLASS_COLORS[class]
    end

    if str == 2 then
        return class.r,class.g,class.b
    elseif str then
        return string.format("%02x%02x%02x", class.r*255, class.g*255, class.b*255)
    else
        return class
    end
end
kui.UnitIsPet = function(unit)
    return (not UnitIsPlayer(unit) and UnitPlayerControlled(unit))
end
kui.GetUnitColour = function(unit, str)
    -- class colour for players or pets
    -- faction colour for NPCs
    local r,g,b

    if UnitIsTapDenied(unit) or
       UnitIsDeadOrGhost(unit) or
       not UnitIsConnected(unit)
    then
        r,g,b = .5,.5,.5
    else
        if UnitIsPlayer(unit) or kui.UnitIsPet(unit) then
            return kui.GetClassColour(unit, str)
        else
            r, g, b = UnitSelectionColor(unit)
        end
    end

    if str == 2 then
        return r,g,b
    elseif str then
        return string.format("%02x%02x%02x", r*255, g*255, b*255)
    else
        return {r=r,g=g,b=b}
    end
end
kui.UnitLevel = function(unit, long)
    local level, classification =
        UnitLevel(unit), UnitClassification(unit)
    local diff = GetQuestDifficultyColor(level <= 0 and 999 or level)

    if ct[classification] then
        classification = long and ct[classification][2] or ct[classification][1]
    else
        classification = ''
    end

    if level == -1 then
        level = '??'
    end

    return level, classification, diff
end
kui.ModifyFontFlags = function(fs, io, flag)
    local font, size, flags = fs:GetFont()
    local flagStart,flagEnd = strfind(flags, flag)

    if io and not flagStart then
        -- add flag
        flags = flags..' '..flag
    elseif not io and flagStart then
        -- remove flag
        flags = strsub(flags, 0, flagStart-1) .. strsub(flags, flagEnd+1)
    end

    fs:SetFont(font, size, flags)
end
kui.CreateFontString = function(parent, args)
    local ob, font, size, outline, alpha, shadow, mono
    args = args or {}

    if args.reset then
        -- to change an already existing fontString
        ob = parent
    else
        ob = parent:CreateFontString(nil, 'OVERLAY')
    end

    font    = args.font or 'Fonts\\FRIZQT__.TTF'
    size    = args.size or 12
    outline = args.outline or nil
    mono    = args.mono or args.monochrome or nil
    alpha   = args.alpha or 1
    shadow  = args.shadow or false

    ob:SetFont(font, size, (outline and 'OUTLINE' or '')..(mono and ' MONOCHROME' or ''))
    ob:SetAlpha(alpha)

    if shadow then
        ob:SetShadowColor(0, 0, 0, 1)
        ob:SetShadowOffset(type(shadow) == 'table' and unpack(shadow) or 1, -1)
    elseif not shadow and args.reset then
        -- remove the shadow
        ob:SetShadowColor(0, 0, 0, 0)
    end

    return ob
end
-- Format numbers
kui.num = function(num)
    if num < THOUSAND then
        return num
    elseif num >= TRILLION then
        return string.format('%.3ft', num/TRILLION)
    elseif num >= BILLION then
        return string.format('%.3fb', num/BILLION)
    elseif num >= MILLION then
        return string.format('%.2fm', num/MILLION)
    elseif num >= THOUSAND then
        return string.format('%.1fk', num/THOUSAND)
    end
end
-- Format times (given in seconds)
kui.FormatTime = function(s)
    if s > 86400 then
        -- days
        return ceil(s/86400) .. 'd', s%86400
    elseif s >= 3600 then
        -- hours
        return ceil(s/3600) .. 'h', s%3600
    elseif s >= 60 then
        -- minutes
        return ceil(s/60) .. 'm', s%60
    elseif s <= 10 then
        return ceil(s), s - format("%.1f", s)
    end

    return floor(s), s - floor(s)
end
-- Pluralise a word pertaining to a value
kui.Pluralise = function(word, value, with)
    if value == 1 then
        return word
    else
        return word .. (with and with or 's')
    end
end
-- substr for utf8 characters (which are somtimes longer than 1 byte)
do
    local function chsize(char)
        if not char then
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end
    -- substr for utf8 characters (which are somtimes longer than 1 byte)
    kui.utf8sub = function(str, startChar, numChars)
        numChars = numChars or #str

        local startIndex = 1
        while startChar > 1 do
            local char = string.byte(str, startIndex)
            startIndex = startIndex + chsize(char)
            startChar = startChar - 1
        end

        local currentIndex = startIndex

        while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            currentIndex = currentIndex + chsize(char)
            numChars = numChars - 1
        end

        return str:sub(startIndex, currentIndex - 1)
    end
end
-- Frame fading functions
-- (without the taint of UIFrameFade & the lag of AnimationGroups)
kui.frameFadeFrame = CreateFrame('Frame')
kui.FADEFRAMES = {}

kui.frameIsFading = function(frame)
    for index, value in pairs(kui.FADEFRAMES) do
        if value == frame then
            return true
        end
    end
end
kui.frameFadeRemoveFrame = function(frame)
    tDeleteItem(kui.FADEFRAMES, frame)
end
kui.frameFadeOnUpdate = function(self, elapsed)
    local frame, info
    for index, value in pairs(kui.FADEFRAMES) do
        frame, info = value, value.fadeInfo

        if info.startDelay and info.startDelay > 0 then
            info.startDelay = info.startDelay - elapsed
        else
            info.fadeTimer = (info.fadeTimer and info.fadeTimer + elapsed) or 0

            if info.fadeTimer < info.timeToFade then
                -- perform animation in either direction
                if info.mode == 'IN' then
                    frame:SetAlpha(
                        (info.fadeTimer / info.timeToFade) *
                        (info.endAlpha - info.startAlpha) +
                        info.startAlpha
                    )
                elseif info.mode == 'OUT' then
                    frame:SetAlpha(
                        ((info.timeToFade - info.fadeTimer) / info.timeToFade) *
                        (info.startAlpha - info.endAlpha) + info.endAlpha
                    )
                end
            else
                -- animation has ended
                frame:SetAlpha(info.endAlpha)

                if info.fadeHoldTime and info.fadeHoldTime > 0 then
                    info.fadeHoldTime = info.fadeHoldTime - elapsed
                else
                    kui.frameFadeRemoveFrame(frame)

                    if info.finishedFunc then
                        info.finishedFunc(frame)
                        info.finishedFunc = nil
                    end
                end
            end
        end
    end

    if #kui.FADEFRAMES == 0 then
        self:SetScript('OnUpdate', nil)
    end
end
--[[
    info = {
        mode            = "IN" (nil) or "OUT",
        startAlpha      = alpha value to start at,
        endAlpha        = alpha value to end at,
        timeToFade      = duration of animation,
        startDelay      = seconds to wait before starting animation,
        fadeHoldTime    = seconds to wait after ending animation before calling finishedFunc,
        finishedFunc    = function to call after animation has ended,
    }

    If you plan to reuse `info`, it should be passed as a single table,
    NOT a reference, as the table will be directly edited.
]]
kui.frameFade = function(frame, info)
    if not frame then return end
    if kui.frameIsFading(frame) then
        -- cancel the current operation
        -- the code calling this should make sure not to interrupt a
        -- necessary finishedFunc. This will entirely skip it.
        kui.frameFadeRemoveFrame(frame)
    end

    info        = info or {}
    info.mode   = info.mode or 'IN'

    if info.mode == 'IN' then
        info.startAlpha = info.startAlpha or 0
        info.endAlpha   = info.endAlpha or 1
    elseif info.mode == 'OUT' then
        info.startAlpha = info.startAlpha or 1
        info.endAlpha   = info.endAlpha or 0
    end

    frame:SetAlpha(info.startAlpha)
    frame.fadeInfo = info

    tinsert(kui.FADEFRAMES, frame)
    kui.frameFadeFrame:SetScript('OnUpdate', kui.frameFadeOnUpdate)
end
