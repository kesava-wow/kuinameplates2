local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local frame_name = 'KuiNameplatesCoreConfig'
local pcdd = LibStub('PhanxConfig-Dropdown')
-- generic scripts #############################################################
local function EditBoxOnEscapePressed(self)
    self:ClearFocus()
end
local function OnEnter(self)
    GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
    GameTooltip:SetWidth(200)
    GameTooltip:AddLine(
        self.env and (opt.titles[self.env] or self.env) or
        self.label and self.label:GetText()
    )

    if self.env and opt.tooltips[self.env] then
        GameTooltip:AddLine(opt.tooltips[self.env], 1,1,1,true)
    end

    GameTooltip:Show()
end
local function OnLeave(self)
    GameTooltip:Hide()
end
local function OnEnable(self)
    if self.label then
        self.label:SetAlpha(1)
    end
end
local function OnDisable(self)
    if self.label then
        self.label:SetAlpha(.5)
    end
end
local function GenericOnShow(self)
    if self.enabled then
        if self.enabled(opt.profile) then
            self:Enable()
        else
            self:Disable()
        end
    end
end
-- element creation helpers ####################################################
do
    local function Get(self)
        if self.env then
            self:SetChecked(opt.profile[self.env])
        end
    end
    local function Set(self)
        if self.env and opt.config then
            opt.config:SetConfig(self.env,self:GetChecked())
        end
    end

    local function CheckBoxOnClick(self)
        if self:GetChecked() then
            PlaySound("igMainMenuOptionCheckBoxOn")
        else
            PlaySound("igMainMenuOptionCheckBoxOff")
        end

        self:Set()
    end
    local function CheckBoxOnShow(self)
        if not opt.profile then return end
        self:Get()
        GenericOnShow(self)
    end

    function opt.CreateCheckBox(parent, name)
        local check = CreateFrame('CheckButton', frame_name..name..'Check', parent, 'OptionsBaseCheckButtonTemplate')

        check.env = name
        check:SetScript('OnClick',CheckBoxOnClick)
        check:SetScript('OnShow',CheckBoxOnShow)

        check:HookScript('OnEnter',OnEnter)
        check:HookScript('OnLeave',OnLeave)
        check:HookScript('OnEnable',OnEnable)
        check:HookScript('OnDisable',OnDisable)

        check.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        check.label:SetText(opt.titles[name] or name or 'Checkbox')
        check.label:SetPoint('LEFT', check, 'RIGHT')

        check.Get = Get
        check.Set = Set

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = check
        end
        return check
    end
end
do
    local function Get(self)
        if type(self.initialize) ~= 'function' then return end
        self:initialize()
    end
    local function Set(self,v)
        if self.env and opt.config then
            opt.config:SetConfig(self.env,v)
        end
    end

    local function DropDownOnChanged(self,v)
        self:Set(v)
    end
    local function DropDownGenericInit(self)
        local list = {}
        for k,f in ipairs(self.SelectTable) do
            tinsert(list,{
                text = f,
                value = k,
                selected = k == opt.profile[self.env]
            })
        end

        self:SetList(list)
        self:SetValue(opt.profile[self.env])
    end
    local function DropDownOnShow(self)
        if self.SelectTable and not self.initialize then
            -- give this menu the generic initialise function
            self.initialize = DropDownGenericInit
        end

        self:Get()
        GenericOnShow(self)
    end

    local function DropDownEnable(self)
        self.labelText:SetFontObject('GameFontNormalSmall')
        self.valueText:SetFontObject('GameFontHighlightSmall')
        self.button:Enable()
    end
    local function DropDownDisable(self)
        self.labelText:SetFontObject('GameFontDisableSmall')
        self.valueText:SetFontObject('GameFontDisableSmall')
        self.button:Disable()
    end

    function opt.CreateDropDown(parent, name, width)
        local dd = pcdd:New(
            parent,
            opt.titles[name] or name or 'DropDown'
        )
        dd.labelText:SetFontObject('GameFontNormalSmall')
        dd:SetWidth(width or 200)
        dd:SetHeight(40)
        dd:SetFrameStrata('TOOLTIP')
        dd.env = name

        dd:HookScript('OnShow',DropDownOnShow)

        dd.OnEnter = OnEnter
        dd.OnLeave = OnLeave
        dd.OnValueChanged = DropDownOnChanged

        -- replace phanx helpers to override the font
        dd.Enable = DropDownEnable
        dd.Disable = DropDownDisable

        dd.Get = Get
        dd.Set = Set

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = dd
        end
        return dd
    end
end
do
    local function SliderOnChanged(self,v)
        -- copy value to display text
        if not v then
            v = self:GetValue()
        end

        -- round value for display to hide floating point errors
        local r_v = string.format('%.4f',v)
        r_v = string.gsub(r_v,'0+$','')
        r_v = string.gsub(r_v,'%.$','')
        self.display:SetText(r_v)
    end

    local function Get(self)
        if self.env and opt.profile[self.env] then
            self:SetValue(opt.profile[self.env])
            -- set text to correct value if outside min/max
            SliderOnChanged(self,opt.profile[self.env])
        end
    end
    local function Set(self,v)
        if not self:IsEnabled() then return end
        if self.env and opt.config then
            opt.config:SetConfig(self.env,v or self:GetValue())
        end
    end

    local function SliderOnShow(self)
        if not opt.profile then return end
        self:Get()
        GenericOnShow(self)
    end
    local function SliderOnMouseUp(self)
        self:Set()
    end
    local function SliderOnMouseWheel(self,delta)
        if not self:IsEnabled() then return end
        if delta > 0 then
            delta = self:GetValueStep()
        else
            delta = -self:GetValueStep()
        end
        self:SetValue(self:GetValue()+delta)
        self:Set()
    end
    local function SliderSetMinMaxValues(self,min,max)
        self:orig_SetMinMaxValues(min,max)
        self.Low:SetText(min)
        self.High:SetText(max)
    end
    local function SliderOnDisable(self)
        self.display:Disable()
        self.display:SetFontObject('GameFontDisableSmall')
        self.label:SetFontObject('GameFontDisable')
    end
    local function SliderOnEnable(self)
        self.display:Enable()
        self.display:SetFontObject('GameFontHighlightSmall')
        self.label:SetFontObject('GameFontNormal')
    end

    local function EditBox_OnFocusGained(self)
        self:HighlightText()
    end
    local function EditBox_OnEscapePressed(self)
        self:ClearFocus()
        self:HighlightText(0,0)

        -- revert to current value
        SliderOnShow(self:GetParent())
    end
    local function EditBox_OnEnterPressed(self)
        -- dumb-verify input
        local v = tonumber(self:GetText())

        if v then
            -- display change
            self:GetParent():SetValue(v)
            -- push to config
            self:GetParent():Set(v)
        else
            EditBox_OnEscapePressed(self)
        end

        -- re-grab focus
        self:SetFocus()
    end

    function opt.CreateSlider(parent, name, min, max)
        local slider = CreateFrame('Slider',frame_name..name..'Slider',parent,'OptionsSliderTemplate')
        slider:SetWidth(190)
        slider:SetHeight(15)
        slider:SetOrientation('HORIZONTAL')
        slider:SetThumbTexture('interface/buttons/ui-sliderbar-button-horizontal')
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)

        -- TODO inc/dec buttons

        local label = slider:CreateFontString(slider:GetName()..'Label','ARTWORK','GameFontNormal')
        label:SetText(opt.titles[name] or name or 'Slider')
        label:SetPoint('BOTTOM',slider,'TOP')

        local display = CreateFrame('EditBox',nil,slider)
        display:SetFontObject('GameFontHighlightSmall')
        display:SetSize(50,15)
        display:SetPoint('TOP',slider,'BOTTOM',0,1)
        display:SetJustifyH('CENTER')
        display:SetAutoFocus(false)
        display:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            edgeFile='interface/buttons/white8x8',
            edgeSize=1
        })
        display:SetBackdropBorderColor(1,1,1,.2)
        display:SetBackdropColor(0,0,0,.5)

        display:SetScript('OnEditFocusGained',EditBox_OnFocusGained)
        display:SetScript('OnEditFocusLost',EditBox_OnEscapePressed)
        display:SetScript('OnEnterPressed',EditBox_OnEnterPressed)
        display:SetScript('OnEscapePressed',EditBox_OnEscapePressed)

        slider.orig_SetMinMaxValues = slider.SetMinMaxValues
        slider.SetMinMaxValues = SliderSetMinMaxValues

        slider.env = name
        slider.label = label
        slider.display = display

        slider:HookScript('OnEnter',OnEnter)
        slider:HookScript('OnLeave',OnLeave)
        slider:HookScript('OnEnable',SliderOnEnable)
        slider:HookScript('OnDisable',SliderOnDisable)
        slider:HookScript('OnShow',SliderOnShow)
        slider:HookScript('OnValueChanged',SliderOnChanged)
        slider:HookScript('OnMouseUp',SliderOnMouseUp)
        slider:HookScript('OnMouseWheel',SliderOnMouseWheel)

        slider.Get = Get
        slider.Set = Set

        slider:SetValueStep(1)
        slider:SetMinMaxValues(min or 0, max or 100)

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = slider
        end
        return slider
    end
end
do
    local function Get(self)
        if self.env and opt.profile[self.env] then
            self.block:SetBackdropColor(unpack(opt.profile[self.env]))
        end
    end
    local function Set(self,col)
        opt.config:SetConfig(self.env,col)
    end

    local function ColourPickerOnShow(self)
        if not opt.profile then return end
        self:Get()
        GenericOnShow(self)
    end
    local function ColourPickerOnClick(self)
        opt.Popup.pages['colour_picker'].colour_picker = self
        opt.Popup:ShowPage('colour_picker')
    end

    function opt.CreateColourPicker(parent,name)
        local container = CreateFrame('Button',frame_name..name..'ColourPicker',parent)
        container:SetWidth(150)
        container:SetHeight(27)
        container:EnableMouse(true)
        container.env = name

        local block = CreateFrame('Frame',nil,container)
        block:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            edgeFile='interface/buttons/white8x8',
            edgeSize=1,
            insets={top=2,right=2,bottom=2,left=2}
        })
        block:SetBackdropBorderColor(.5,.5,.5)
        block:SetSize(18,18)
        block:SetPoint('LEFT')

        local label = container:CreateFontString(nil,'ARTWORK','GameFontHighlight')
        label:SetText(opt.titles[name] or name or 'Colour picker')
        label:SetPoint('LEFT',block,'RIGHT',5,0)

        container.block = block
        container.label = label

        container:SetScript('OnShow',ColourPickerOnShow)
        container:SetScript('OnEnable',OnEnable)
        container:SetScript('OnDisable',OnDisable)
        container:SetScript('OnClick',ColourPickerOnClick)
        container:SetScript('OnEnter',OnEnter)
        container:SetScript('OnLeave',OnLeave)

        container.Get = Get
        container.Set = Set -- called by popup

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = container
        end
        return container
    end
end
do
    function opt.CreateEditBox(parent,name,multiline,width,height)
        local e_name = name and frame_name..name..'EditBox' or nil
        width,height = width or 150,height or 20

        local box = CreateFrame('EditBox',e_name,parent)
        box:SetMultiLine(multiline==true)
        box:SetAutoFocus(false)
        box:SetFontObject('ChatFontNormal')
        box:SetSize(width,height)
        box.env = name

        local bg = CreateFrame('Frame',nil,parent)
        bg:SetBackdrop({
            bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-border',
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        bg:SetBackdropColor(.1, .1 , .1, .3)
        bg:SetBackdropBorderColor(.5, .5, .5)
        box.bg = bg

        if multiline then
            local scroll = CreateFrame('ScrollFrame',nil,parent,'UIPanelScrollFrameTemplate')
            scroll:SetSize(width,height)
            scroll:SetScrollChild(box)
            box.scroll = scroll

            scroll:SetScript('OnMouseDown', function(self)
                self:GetScrollChild():SetFocus()
            end)

            bg:SetPoint('TOPLEFT', scroll, -10, 10)
            bg:SetPoint('BOTTOMRIGHT', scroll, 30, -10)
        else
            bg:SetPoint('TOPLEFT', box, -10, 10)
            bg:SetPoint('BOTTOMRIGHT', box, 30, -10)
        end

        box:SetScript('OnShow',GenericOnShow)
        box:SetScript('OnEnable',OnEnable)
        box:SetScript('OnDisable',OnDisable)
        box:SetScript('OnEscapePressed',EditBoxOnEscapePressed)

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = container
        end
        return box
    end
end
function opt.CreateSeperator(parent,name)
    local line = parent:CreateTexture(nil,'ARTWORK')
    line:SetTexture('interface/buttons/white8x8')
    line:SetVertexColor(1,1,1,.3)
    line:SetSize(400,1)

    local shadow = parent:CreateTexture(nil,'ARTWORK')
    shadow:SetTexture('interface/buttons/white8x8')
    shadow:SetVertexColor(0,0,0,.8)
    shadow:SetSize(400,1)
    shadow:SetPoint('BOTTOM',line,'TOP')

    local label = parent:CreateFontString(nil,'ARTWORK','GameFontNormal')
    label:SetText(opt.titles[name] or name or 'Seperator')
    label:SetPoint('CENTER',line,0,10)

    line.label = label
    line.shadow = shadow
    return line
end
-- page functions ##############################################################
do
    local function ShowPage(self)
        if opt.active_page then
            opt.active_page:HidePage()
        end

        self.tab.highlight:SetVertexColor(1,1,0)
        self.tab:LockHighlight()

        self.scroll:Show()
        self:Show()

        opt.active_page = self
    end
    local function HidePage(self)
        self.tab.highlight:SetVertexColor(.196,.388,.8)
        self.tab:UnlockHighlight()

        self.scroll:Hide()
        self:Hide()
    end

    local page_proto = {
        CreateCheckBox = opt.CreateCheckBox,
        CreateDropDown = opt.CreateDropDown,
        CreateSlider = opt.CreateSlider,
        CreateColourPicker = opt.CreateColourPicker,
        CreateSeperator = opt.CreateSeperator,
        CreateEditBox = opt.CreateEditBox,

        HidePage = HidePage,
        ShowPage = ShowPage
    }
    function opt:CreateConfigPage(name)
        local f = CreateFrame('Frame',frame_name..name..'Page',self)
        f.name = name
        f.elements = {}

        f.scroll = CreateFrame('ScrollFrame',frame_name..name..'PageScrollFrame',self,'UIPanelScrollFrameTemplate')
        f.scroll:SetPoint('TOPLEFT',self.PageBG,4,-4)
        f.scroll:SetPoint('BOTTOMRIGHT',self.PageBG,-26,4)
        f.scroll:SetScrollChild(f)

        f:SetWidth(420)
        f:SetHeight(1)

        -- mixin page functions
        for k,v in pairs(page_proto) do
            f[k]=v
        end

        self:CreatePageTab(f)
        f:HidePage()

        tinsert(self.pages,f)
        return f
    end
end
-- tab functions ###############################################################
do
    local function OnClick(self)
        PlaySound("igMainMenuOptionCheckBoxOn");
        self.child:ShowPage()
    end
    function opt:CreatePageTab(page)
        local tab = CreateFrame('Button',frame_name..page.name..'PageTab',self.TabList,'OptionsListButtonTemplate')
        tab:SetScript('OnClick',OnClick)
        tab:SetText(self.page_names[page.name] or page.name or 'Tab')
        tab:SetWidth(120)

        tab.child = page
        page.tab = tab

        local pt = #self.pages > 0 and self.pages[#self.pages].tab

        if pt then
            tab:SetPoint('TOPLEFT',pt,'BOTTOMLEFT')
        else
            tab:SetPoint('TOPLEFT',self.TabList,3,-3)
        end
    end
end
-- popup functions #############################################################
do
    local function PopupOnShow(self)
        PlaySound("igMainMenuOpen")
    end
    local function PopupOnHide(self)
        PlaySound("igMainMenuClose")
    end
    local function PopupOnKeyUp(self,kc)
        if kc == 'ENTER' then
            self.Okay:Click()
        elseif kc == 'ESCAPE' then
            self.Cancel:Click()
        end
    end
    local function OkayButtonOnClick(self)
        if opt.Popup.active_page.callback then
            opt.Popup.active_page:callback(true)
        end
        opt.Popup:Hide()
    end
    local function CancelButtonOnClick(self)
        if opt.Popup.active_page.callback then
            opt.Popup.active_page:callback(false)
        end
        opt.Popup:Hide()
    end

    local function PopupShowPage(self,page_name,...)
        if self.active_page then
            self.active_page:Hide()
        end

        if self.pages[page_name] then
            self.pages[page_name]:Show()
            self.active_page = self.pages[page_name]

            if self.active_page.size then
                self:SetSize(unpack(self.active_page.size))
            else
                self:SetSize(400,300)
            end

            if type(self.active_page.PostShow) == 'function' then
                self.active_page:PostShow(...)
            end
        end

        self:Show()
    end

    -- new profile #############################################################
    local function NewProfile_OnShow(self)
        self.editbox:SetText('')
        self.editbox:SetFocus()
    end
    local function NewProfile_OnEnterPressed(self)
        opt.Popup.Okay:Click()
    end
    local function NewProfile_OnEscapePressed(self)
        opt.Popup.Cancel:Click()
    end
    local function CreatePopupPage_NewProfile()
        local new_profile = CreateFrame('Frame',nil,opt.Popup)
        new_profile:SetAllPoints(opt.Popup)
        new_profile:Hide()
        new_profile.size = { 400,150 }

        function new_profile:callback(accept)
            if accept then
                -- create and activate the new profile
                opt.config:SetProfile(self.editbox:GetText())
            end
        end

        local label = new_profile:CreateFontString(nil,'ARTWORK','GameFontNormal')
        label:SetText(opt.titles['new_profile_label'])
        label:SetPoint('CENTER',0,20)

        local profile_name = CreateFrame('EditBox',nil,new_profile,'InputBoxTemplate')
        profile_name:SetAutoFocus(false)
        profile_name:EnableMouse(true)
        profile_name:SetMaxLetters(50)
        profile_name:SetPoint('CENTER')
        profile_name:SetSize(150,30)

        new_profile.editbox = profile_name

        new_profile:SetScript('OnShow',NewProfile_OnShow)
        profile_name:SetScript('OnEnterPressed',NewProfile_OnEnterPressed)
        profile_name:SetScript('OnEscapePressed',NewProfile_OnEscapePressed)

        opt.Popup.pages.new_profile = new_profile
    end

    -- rename profile ##########################################################
    local function RenameProfile_OnShow(self)
        self.editbox:SetText(opt.config.csv.profile)
        self.editbox:SetFocus()
        self.label:SetText(string.format(
            opt.titles['rename_profile_label'],
            opt.config.csv.profile
        ))
    end
    local function CreatePopupPage_RenameProfile()
        local pg = CreateFrame('Frame',nil,opt.Popup)
        pg:SetAllPoints(opt.Popup)
        pg:Hide()
        pg.size = { 400,150 }

        function pg:callback(accept)
            if accept then
                opt.config:RenameProfile(opt.config.csv.profile,pg.editbox:GetText())
            end
        end

        local label = pg:CreateFontString(nil,'ARTWORK','GameFontNormal')
        label:SetPoint('CENTER',0,20)

        local profile_name = CreateFrame('EditBox',nil,pg,'InputBoxTemplate')
        profile_name:SetAutoFocus(false)
        profile_name:EnableMouse(true)
        profile_name:SetMaxLetters(50)
        profile_name:SetPoint('CENTER')
        profile_name:SetSize(150,30)

        pg.label = label
        pg.editbox = profile_name

        pg:SetScript('OnShow',RenameProfile_OnShow)
        profile_name:SetScript('OnEnterPressed',NewProfile_OnEnterPressed)
        profile_name:SetScript('OnEscapePressed',NewProfile_OnEscapePressed)

        opt.Popup.pages.rename_profile = pg
    end

    -- confirm dialog ##########################################################
    local function ConfirmDialog_PostShow(self,desc,callback)
        self.label:SetText('')
        self.callback = nil

        if desc then
            self.label:SetText(desc)
        end
        if callback then
            self.callback = callback
        end
    end
    local function CreatePopupPage_ConfirmDialog()
        local pg = CreateFrame('Frame',nil,opt.Popup)
        pg:SetAllPoints(opt.Popup)
        pg:Hide()
        pg.size = { 400,150 }

        local label = pg:CreateFontString(nil,'ARTWORK','GameFontNormal')
        label:SetPoint('CENTER',0,10)

        pg.label = label
        pg.PostShow = ConfirmDialog_PostShow

        opt.Popup.pages.confirm_dialog = pg
    end

    -- colour picker ###########################################################
    local function ColourPicker_GetColour(self)
        local r = self.r:GetValue() or 255
        local g = self.g:GetValue() or 255
        local b = self.b:GetValue() or 255

        r = r > 0 and r/255 or 0
        g = g > 0 and g/255 or 0
        b = b > 0 and b/255 or 0

        if self.o:IsShown() then
            local o = self.o:GetValue() or 255
            o = o > 0 and o/255 or 0

            return {r,g,b,o}
        else
            return {r,g,b}
        end
    end
    local function ColourPicker_OnValueChanged(slider)
        local col = ColourPicker_GetColour(slider:GetParent())
        slider:GetParent().display:SetBackdropColor(unpack(col))

        local text =
            string.format("%.2f",col[1])..', '..
            string.format("%.2f",col[2])..', '..
            string.format("%.2f",col[3])

        if col[4] then
            text = text..', '..string.format("%.2f",col[4])
        end

        slider:GetParent().text:SetText(text)
    end
    local function ColourPicker_OnShow(self)
        if not self.colour_picker or
           not self.colour_picker.env
        then
            opt.Popup:Hide()
            return
        end

        local val = opt.profile[self.colour_picker.env]

        if not val then
            opt.Popup:Hide()
            return
        end

        if #val == 4 then
            self.o:Show()
            self.o:SetValue(val[4]*255)
        else
            self.o:Hide()
        end

        self.r:SetValue(val[1]*255)
        self.g:SetValue(val[2]*255)
        self.b:SetValue(val[3]*255)
    end
    local function ColourPicker_Callback(self,accept)
        if accept then
            self.colour_picker:Set(ColourPicker_GetColour(self))
        end
        self.colour_picker = nil
    end
    local function CreatePopupPage_ColourPicker()
        local colour_picker = CreateFrame('Frame',nil,opt.Popup)
        colour_picker:SetAllPoints(opt.Popup)
        colour_picker:Hide()

        local display = CreateFrame('Frame',nil,colour_picker)
        display:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            edgeFile='interface/buttons/white8x8',
            edgeSize=1,
            insets={top=2,right=2,bottom=2,left=2}
        })
        display:SetBackdropBorderColor(.5,.5,.5)
        display:SetSize(150,150)
        display:SetPoint('TOPLEFT',35,-45)

        local text = colour_picker:CreateFontString(nil,'ARTWORK','GameFontHighlightSmall')
        text:SetPoint('TOPLEFT',display,'BOTTOMLEFT',0,-5)
        text:SetPoint('TOPRIGHT',display,'BOTTOMRIGHT')

        local r = opt.CreateSlider(colour_picker,'ColourPickerR',0,255)
        r:SetWidth(150)
        r:SetPoint('TOPRIGHT',-40,-50)
        r.label:SetText('Red')
        r.env = nil

        local g = opt.CreateSlider(colour_picker,'ColourPickerG',0,255)
        g:SetWidth(150)
        g:SetPoint('TOPLEFT',r,'BOTTOMLEFT',0,-30)
        g.label:SetText('Green')
        g.env = nil

        local b = opt.CreateSlider(colour_picker,'ColourPickerB',0,255)
        b:SetWidth(150)
        b:SetPoint('TOPLEFT',g,'BOTTOMLEFT',0,-30)
        b.label:SetText('Blue')
        b.env = nil

        local o = opt.CreateSlider(colour_picker,'ColourPickerO',0,255)
        o:SetWidth(150)
        o:SetPoint('TOPLEFT',b,'BOTTOMLEFT',0,-30)
        o.label:SetText('Opacity')
        o.env = nil

        colour_picker.display = display
        colour_picker.text = text
        colour_picker.r = r
        colour_picker.g = g
        colour_picker.b = b
        colour_picker.o = o

        colour_picker.callback = ColourPicker_Callback
        colour_picker:SetScript('OnShow',ColourPicker_OnShow)

        r:HookScript('OnValueChanged',ColourPicker_OnValueChanged)
        g:HookScript('OnValueChanged',ColourPicker_OnValueChanged)
        b:HookScript('OnValueChanged',ColourPicker_OnValueChanged)
        o:HookScript('OnValueChanged',ColourPicker_OnValueChanged)

        opt.Popup.pages.colour_picker = colour_picker
    end

    -- create popup ############################################################
    function opt:CreatePopup()
        local popup = CreateFrame('Frame',nil,self)
        popup:SetBackdrop({
            bgFile='interface/dialogframe/ui-dialogbox-background',
            edgeFile='interface/dialogframe/ui-dialogbox-border',
            edgeSize=32,
            tile=true,
            tileSize=32,
            insets = {
                top=12,right=12,bottom=11,left=11
            }
        })
        popup:SetPoint('CENTER')
        popup:SetFrameStrata('DIALOG')
        popup:EnableMouse(true)
        popup:Hide()
        popup.pages = {}

        popup.ShowPage = PopupShowPage

        popup:SetScript('OnKeyUp',PopupOnKeyUp)
        popup:SetScript('OnShow',PopupOnShow)
        popup:SetScript('OnHide',PopupOnHide)

        local okay = CreateFrame('Button',nil,popup,'UIPanelButtonTemplate')
        okay:SetText('OK')
        okay:SetSize(90,22)
        okay:SetPoint('BOTTOM',-45,20)

        local cancel = CreateFrame('Button',nil,popup,'UIPanelButtonTemplate')
        cancel:SetText('Cancel')
        cancel:SetSize(90,22)
        cancel:SetPoint('BOTTOM',45,20)

        okay:SetScript('OnClick',OkayButtonOnClick)
        cancel:SetScript('OnClick',CancelButtonOnClick)

        popup.Okay = okay
        popup.Cancel = cancel

        self.Popup = popup

        CreatePopupPage_NewProfile()
        CreatePopupPage_ColourPicker()
        CreatePopupPage_RenameProfile()
        CreatePopupPage_ConfirmDialog()

        opt:HookScript('OnHide',function(self)
            self.Popup:Hide()
        end)
    end
end
-- profile drop down functions #################################################
local CreateProfileDropDown
do
    local function OnValueChanged(self,value,text)
        if value and value == 'new_profile' then
            opt.Popup:ShowPage('new_profile')
        else
            opt.config:SetProfile(text)
        end
    end
    local function initialize(self)
        local list = {}

        -- create new profile button
        tinsert(list,{
            text = opt.titles['new_profile'],
            value = 'new_profile'
        })

        -- create profile buttons
        for k,p in pairs(opt.config.gsv.profiles) do
            tinsert(list,{
                text = k,
                selected = k == opt.config.csv.profile
            })
        end

        self:SetList(list)
        self:SetValue(opt.config.csv.profile)
    end
    function CreateProfileDropDown()
        p_dd = pcdd:New(opt,opt.titles['profile'])
        p_dd.labelText:SetFontObject('GameFontNormalSmall')
        p_dd:SetWidth(152)
        p_dd:SetHeight(40)
        p_dd:SetPoint('TOPLEFT',9,-15)
        p_dd:SetFrameStrata('TOOLTIP')

        p_dd.initialize = initialize
        p_dd.OnValueChanged = OnValueChanged

        p_dd:HookScript('OnShow',function(self)
            self:initialize()
        end)
    end
end
-- init display ################################################################
function opt:Initialise()
    self:CreatePopup()
    CreateProfileDropDown()

    -- create profile buttons
    local function ProfileButtonOnShow(self)
        if opt.config.csv.profile == 'default' then
            self:Disable()
        else
            self:Enable()
        end
    end

    local p_delete = CreateFrame('Button',nil,opt,'UIPanelButtonTemplate')
    p_delete:SetPoint('TOPRIGHT',-10,-26)
    p_delete:SetText('Delete profile')
    p_delete:SetSize(110,22)
    p_delete.callback = function(self,accept)
        if accept then
            opt.config:DeleteProfile(opt.config.csv.profile)
        end
    end
    p_delete:SetScript('OnShow',ProfileButtonOnShow)
    p_delete:SetScript('OnClick',function(self)
        opt.Popup:ShowPage(
            'confirm_dialog',
            string.format(opt.titles.delete_profile_label,opt.config.csv.profile),
            self.callback
        )
    end)

    local p_rename = CreateFrame('Button',nil,opt,'UIPanelButtonTemplate')
    p_rename:SetPoint('RIGHT',p_delete,'LEFT',-5,0)
    p_rename:SetText('Rename profile')
    p_rename:SetSize(115,22)
    p_rename:SetScript('OnShow',ProfileButtonOnShow)
    p_rename:SetScript('OnClick',function(self)
        opt.Popup:ShowPage('rename_profile')
    end)

    local p_reset = CreateFrame('Button',nil,opt,'UIPanelButtonTemplate')
    p_reset:SetPoint('RIGHT',p_rename,'LEFT',-5,0)
    p_reset:SetText('Reset profile')
    p_reset:SetSize(115,22)
    p_reset.callback = function(self,accept)
        if accept then
            opt.config:ResetProfile(opt.config.csv.profile)
        end
    end
    p_reset:SetScript('OnClick',function(self)
        opt.Popup:ShowPage(
            'confirm_dialog',
            string.format(opt.titles.reset_profile_label,opt.config.csv.profile),
            self.callback
        )
    end)

    -- create backgrounds
    local tl_bg = CreateFrame('Frame',nil,self)
    tl_bg:SetBackdrop({
        bgFile = 'Interface/ChatFrame/ChatFrameBackground',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    tl_bg:SetBackdropColor(.1,.1,.1,.3)
    tl_bg:SetBackdropBorderColor(.5,.5,.5)
    tl_bg:SetPoint('TOPLEFT',self,10,-55)
    tl_bg:SetPoint('BOTTOMLEFT',self,10,10)
    tl_bg:SetWidth(150)

    local p_bg = CreateFrame('Frame',nil,self)
    p_bg:SetBackdrop({
        bgFile = 'Interface/ChatFrame/ChatFrameBackground',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p_bg:SetBackdropColor(.1,.1,.1,.3)
    p_bg:SetBackdropBorderColor(.5,.5,.5)
    p_bg:SetPoint('TOPLEFT',tl_bg,'TOPRIGHT',3,0)
    p_bg:SetPoint('BOTTOMRIGHT',self,-10,10)

    -- create tab container
    local tablist = CreateFrame('Frame',frame_name..'TabList',self)
    tablist:SetWidth(1)
    tablist:SetHeight(1)

    local scroll = CreateFrame('ScrollFrame',frame_name..'TabListScrollFrame',self,'UIPanelScrollFrameTemplate')
    scroll:SetPoint('TOPLEFT',tl_bg,4,-4)
    scroll:SetPoint('BOTTOMRIGHT',tl_bg,-26,4)
    scroll:SetScrollChild(tablist)

    tablist.Scroll = scroll

    self.TabList = tablist
    self.TabListBG = tl_bg
    self.PageBG = p_bg
end
