local MAJOR, MINOR = 'Kui-1.0', 42
local kui = LibStub:NewLibrary(MAJOR, MINOR)

if not kui then
    -- already registered
    return
end

local CLASSIC = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
kui.CLASSIC = CLASSIC

-- media # XXX LEGACY #########################################################
local media = "Interface\\AddOns\\Kui_Media\\"
kui.m = {
    t = {
        -- borders
        shadow  = media .. 't\\shadowBorder',
        rounded = media .. 't\\solidRoundedBorder',
        -- textures
        solid       = media .. 't\\solid',
        innerShade  = media .. 't\\innerShade',
        empty       = media .. 't\\empty',
        -- progress bars
        bar       = media .. 't\\bar',
        oldbar    = media .. 't\\bar-old',
        sbar      = media .. 't\\bar-small',
        brightbar = media .. 't\\bar-bright',
        stripebar = media .. 't\\stippled-bar',
    },
    f = {
        francois = media..'f\\francois.ttf',
        roboto   = media..'f\\roboto.ttf',
    },
}
-- other locals ################################################################
local TRILLION=1000000000000
local BILLION=1000000000
local MILLION=1000000
local THOUSAND=1000

local ct = { -- classification table
    elite     = { '+',  'elite'      },
    rare      = { 'r',  'rare'       },
    rareelite = { 'r+', 'rare elite' },
    worldboss = { 'b',  'boss'       }
}
-- functions ###################################################################
local function SortedTableIndex(tbl)
    local index = {}
    for k in pairs(tbl) do
        tinsert(index,k)
    end
    table.sort(index,function(a,b)
        local str_a,str_b=tostring(a),tostring(b)
        if str_a and not str_b then
            return true
        elseif str_b and not str_a then
            return false
        else
            return strlower(str_a) < strlower(str_b)
        end
    end)
    return index
end
kui.table_to_string = function(in_tbl,max_depth)
    -- convert simple table to string (with restrictions)
    if not max_depth then
        max_depth = 3
    end
    local function loop(tbl,depth)
        if depth and depth >= max_depth then
            return '{..}'
        else
            local str
            local tbl_index = SortedTableIndex(tbl)

            for _,k in ipairs(tbl_index) do
                local v = tbl[k]

                if type(k) == 'string' or tostring(k) then
                    k = tostring(k)
                else
                    k = '('..type(k)..')'
                end

                if type(v) == 'table' then
                    v = loop(v,depth and depth+1 or 1)
                elseif type(v) == 'number' then
                    v = tonumber(string.format('%.3f',v))
                elseif type(v) == 'string' or tostring(v) then
                    v = tostring(v)
                else
                    v = '('..type(v)..')'
                end

                str = (str and str..',' or '')..k..'='..v
            end

            return str and '{'..str..'}' or '{}'
        end
    end
    return loop(in_tbl)
end
function kui.string_to_table(in_str)
    -- convert string from above function back to table
    -- (with restrictions)
    local out_table = {}
    local out_length = 0
    local function loop(str,nested_table)
        if str == '{}' or str == '{..}' then
            return {}
        end
        if strfind(str,'{') == 1 then
            -- remove surrounding brackets
            str = strsub(str,2,strlen(str)-1)
        end

        local next_comma,next_equals = strfind(str,','),strfind(str,'=')
        if nested_table or next_equals and not next_comma then
            -- parse "key=value" into final array
            local k = strsub(str,1,next_equals-1)
            local v = strsub(str,next_equals+1)

            -- convert key
            if tonumber(k) then
                k = tonumber(k)
            end

            -- convert value
            if strlower(v) == 'true' then
                v = true
            elseif strlower(v) == 'false' then
                v = false
            elseif strlower(v) == 'nil' then
                v = nil
            elseif tonumber(v) then
                v = tonumber(v)
            elseif strfind(v,'{') == 1 then
                -- convert nested tables
                v = kui.string_to_table(v)
            end

            out_table[k] = v
            out_length = out_length + 1
            return
        end

        local next_open = strfind(str,'{')
        if next_open and next_equals and next_open == next_equals + 1 then
            -- this value is a nested table,
            -- find the comma after the end (or the end of the string)
            -- XXX doesn't handle double-nested tables
            next_comma = strfind(str,',',strfind(str,'}'))
            if next_comma then
                loop(strsub(str,1,next_comma-1),true)
                -- and continue...
                loop(strsub(str,next_comma+1))
            else
                -- this is the final value
                loop(str,true)
            end
            return
        end

        if next_comma and next_equals and next_equals < next_comma then
            -- parse each delimited section
            loop(strsub(str,1,next_comma-1))
            -- and continue with the remaining text
            loop(strsub(str,next_comma+1))
            return
        end
    end
    loop(in_str)

    if out_length == 0 then
        return
    else
        return out_table,out_length
    end
end
kui.print = function(...)
    local msg
    for _,v in ipairs({...}) do
        if type(v) == 'table' then
            v = kui.table_to_string(v)
        end
        msg = (msg and msg..', ' or '')..tostring(v)
    end
    print(GetTime()..': '..(msg or 'nil'))
end
-- unit helpers ################################################################
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
kui.UnitLevel = function(unit, long, real)
    local level
    if CLASSIC then
        level = UnitLevel(unit) or 0
    else
        level = real and UnitLevel(unit) or UnitEffectiveLevel(unit)
    end

    local classification = UnitClassification(unit)
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
-- frame helpers ###############################################################
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
-- generic helpers #############################################################
kui.num = function(num) -- TODO needs locale
    if not num then return end
    if num < THOUSAND then
        return floor(num)
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
kui.Pluralise = function(word, value, with)
    if value == 1 then
        return word
    else
        return word .. (with and with or 's')
    end
end
do
    local function _b(m,c)
        return c + (1 - c) * m
    end
    kui.Brighten = function(m,r,g,b,a)
        -- brighten (or darken) given colour
        return _b(m,r),_b(m,g),_b(m,b),a
    end
end
-- substr for utf8 characters ##################################################
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
-- editbox debug popup #########################################################
do
    local debugpopup
    local function Popup_Show(self)
        self.ScrollFrame:Show()
        self.Background:Show()
        self:orig_Show()
    end
    local function Popup_Hide(self)
        self:ClearFocus()
        self:orig_Hide()
        self.ScrollFrame:Hide()
        self.Background:Hide()

        if type(self.callback) == 'function' then
            -- run input callback
            self.callback(self:GetText())
        end
        self:SetText("")
    end
    local function Popup_AddText(self,v)
        if not v then return end
        local m = self:GetText()
        if m ~= '' then
            m = m..'|n'
        end
        if type(v) == 'table' then
            v = kui.table_to_string(v)
        end
        self:SetText(m..v)
    end
    local function Popup_OnEscapePressed(self)
        self:Hide()
    end
    local function ScrollFrame_OnMouseDown(self,button)
        if button == 'RightButton' and not self.is_moving then
            self:StartMoving()
            self.is_moving = true
        elseif button == 'LeftButton' then
            self:GetScrollChild():SetFocus()
        end
    end
    local function ScrollFrame_OnMouseUp(self,button)
        if button == 'RightButton' and self.is_moving then
            self:StopMovingOrSizing()
            self.is_moving = nil
        end
    end

    local function CreateDebugPopup()
        if debugpopup then return end

        local p = CreateFrame('EditBox','KuiDebugEditBox',UIParent)
        p:SetFrameStrata('DIALOG')
        p:SetMultiLine(true)
        p:SetAutoFocus(true)
        p:SetFontObject(ChatFontNormal)
        p:SetSize(450,300)
        p:Hide()

        p.orig_Hide = p.Hide
        p.orig_Show = p.Show
        p.Hide = Popup_Hide
        p.Show = Popup_Show
        p.AddText = Popup_AddText
        p:SetScript('OnEscapePressed',Popup_OnEscapePressed)

        local s = CreateFrame('ScrollFrame','KuiDebugEditBoxScrollFrame',UIParent,'UIPanelScrollFrameTemplate')
        s:SetMovable(true)
        s:SetFrameStrata('DIALOG')
        s:SetSize(450,300)
        s:SetHitRectInsets(-10,-30,-10,-10)
        s:SetPoint('CENTER')
        s:SetScrollChild(p)
        s:Hide()

        s:SetScript('OnMouseDown',ScrollFrame_OnMouseDown)
        s:SetScript('OnMouseUp',ScrollFrame_OnMouseUp)

        local bg = CreateFrame('Frame',nil,UIParent)
        bg:SetFrameStrata('DIALOG')
        bg:SetBackdrop({
            bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-border',
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        bg:SetBackdropColor(.05,.05,.05,.8)
        bg:SetBackdropBorderColor(.5,.5,.5)
        bg:SetPoint('TOPLEFT',s,-10,10)
        bg:SetPoint('BOTTOMRIGHT',s,30,-10)
        bg:Hide()

        p.ScrollFrame = s
        p.Background = bg

        debugpopup = p
    end
    function kui:DebugPopup(callback)
        -- create/get and return reference to debug EditBox
        CreateDebugPopup()

        -- disable and hide popup if already visible
        debugpopup.callback = nil
        debugpopup:Hide()

        if type(callback) == 'function' then
            debugpopup.callback = callback
        end
        return debugpopup
    end
end
-- Frame fading functions ######################################################
kui.frameFadeFrame = CreateFrame('Frame')
kui.FADEFRAMES = {}

kui.frameIsFading = function(frame)
    for _,value in pairs(kui.FADEFRAMES) do
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
    for _,value in pairs(kui.FADEFRAMES) do
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
