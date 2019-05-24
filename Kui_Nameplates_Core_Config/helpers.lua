local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local frame_name = 'KuiNameplatesCoreConfig'
local pcdd = LibStub('SomeoneElsesConfig-Dropdown')
local L = opt:GetLocale()

local S_CHECKBOX_ON = 856
local S_CHECKBOX_OFF = 857
local S_MENU_OPEN = 850
local S_MENU_CLOSE = 851

local function GetLocaleString(common_key,name,fallback)
    if common_key and L.common[common_key] then 
        return L.common[common_key]
    end
    if name then
        if L.titles[name] then return L.titles[name] end
        return name
    end
    return fallback
end

-- generic scripts #############################################################
local function EditBoxOnEscapePressed(self)
    self:ClearFocus()
end
local function OnEnter(self)
    GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
    GameTooltip:SetWidth(200)

    if self.common_name or self.env then
        GameTooltip:AddLine(GetLocaleString(self.common_name,self.env,'Tooltip'))
    elseif self.label then
        GameTooltip:AddLine(self.label:GetText())
    end

    if self.env and L.tooltips[self.env] then
        GameTooltip:AddLine(L.tooltips[self.env],1,1,1,true)
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
-- button ######################################################################
local function CreateButton(parent)
    local f = CreateFrame('Button',nil,parent,'UIPanelButtonTemplate')
    if f.Text and f.Left and f.Right then
        f.Text:SetPoint('LEFT',f.Left)
        f.Text:SetPoint('RIGHT',f.Right)
    end
    return f
end
-- checkbox ####################################################################
do
    local function Get(self)
        if self.env then
            self:SetChecked(opt.profile[self.env])
        end
    end
    local function Set(self)
        if self.env and opt.config then
            opt.config:SetKey(self.env,self:GetChecked())
        end
    end

    local function CheckBoxOnClick(self)
        if self:GetChecked() then
            PlaySound(S_CHECKBOX_ON)
        else
            PlaySound(S_CHECKBOX_OFF)
        end

        self:Set()
    end
    local function CheckBoxOnShow(self)
        if not opt.profile then return end
        self:Get()
        GenericOnShow(self)
    end

    function opt.CreateCheckBox(parent, name, small, common_name)
        local check = CreateFrame('CheckButton', frame_name..name..'Check', parent, 'OptionsBaseCheckButtonTemplate')

        check.env = name
        check.common_name = common_name

        check:SetScript('OnClick',CheckBoxOnClick)
        check:SetScript('OnShow',CheckBoxOnShow)

        check:HookScript('OnEnter',OnEnter)
        check:HookScript('OnLeave',OnLeave)
        check:HookScript('OnEnable',OnEnable)
        check:HookScript('OnDisable',OnDisable)

        if small then
            check.label = parent:CreateFontString(nil,'ARTWORK','GameFontHighlightSmall')
        else
            check.label = parent:CreateFontString(nil,'ARTWORK','GameFontHighlight')
        end

        check.label:SetJustifyH('LEFT')
        check.label:SetText(GetLocaleString(common_name,name,'Checkbox'))
        check.label:SetPoint('LEFT', check, 'RIGHT')

        check.Get = Get
        check.Set = Set

        if name and type(parent.elements) == 'table' then
            parent.elements[name] = check
        end
        return check
    end
end
-- dropdown ####################################################################
do
    local function Get(self)
        if type(self.initialize) ~= 'function' then return end
        self:initialize()
    end
    local function Set(self,v)
        if self.env and opt.config then
            opt.config:SetKey(self.env,v)
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

    function opt.CreateDropDown(parent, name, common_name)
        local dd = pcdd:New(parent,GetLocaleString(common_name,name,'Dropdown'))
        dd.labelText:SetFontObject('GameFontNormalSmall')
        dd:SetWidth(200)
        dd:SetHeight(40)
        dd:HookScript('OnShow',DropDownOnShow)

        dd.env = name
        dd.common_name = common_name

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
-- slider ######################################################################
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
            opt.config:SetKey(self.env,v or self:GetValue())
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
        if self:IsEnabled() and IsAltKeyDown() then
            self:SetValue(self:GetValue()+(self:GetValueStep()*delta))
            self:Set()
        else
            -- "passthrough" scroll to scrollframe
            opt.ScrollFrame:GetScript('OnMouseWheel')(opt.ScrollFrame,delta)
        end
    end
    local function SliderSetMinMaxValues(self,min,max)
        self:orig_SetMinMaxValues(min,max)
        self.Low:SetText(min)
        self.High:SetText(max)
    end
    local function SliderOnDisable(self)
        self.display:Disable()
        self.display:SetFontObject('GameFontDisableSmall')
        self.label:SetFontObject(self.small and 'GameFontDisableSmall' or 'GameFontDisable')
    end
    local function SliderOnEnable(self)
        self.display:Enable()
        self.display:SetFontObject('GameFontHighlightSmall')
        self.label:SetFontObject(self.small and 'GameFontNormalSmall' or 'GameFontNormal')
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

    function opt.CreateSlider(parent, name, min, max, small, common_name)
        local slider = CreateFrame('Slider',frame_name..name..'Slider',parent,'OptionsSliderTemplate')
        slider:SetWidth(190)
        slider:SetHeight(15)
        slider:SetOrientation('HORIZONTAL')
        slider:SetThumbTexture('interface/buttons/ui-sliderbar-button-horizontal')
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)

        local label = slider:CreateFontString(
            slider:GetName()..'Label','ARTWORK',
            (small and 'GameFontNormalSmall' or 'GameFontNormal'))
        label:SetText(GetLocaleString(common_name,name,'Slider'))
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
        slider.common_name = common_name
        slider.label = label
        slider.display = display
        slider.small = small

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
-- colour picker ###############################################################
do
    local function Get(self)
        if self.env and opt.profile[self.env] then
            self.block:SetBackdropColor(unpack(opt.profile[self.env]))
        end
    end
    local function Set(self,col)
        opt.config:SetKey(self.env,col)
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

    function opt.CreateColourPicker(parent,name,small,common_name)
        local container = CreateFrame('Button',frame_name..name..'ColourPicker',parent)
        container:SetWidth(150)
        container:SetHeight(27)
        container:EnableMouse(true)
        container.env = name
        container.common_name = common_name

        local block = CreateFrame('Frame',nil,container)
        block:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            edgeFile='interface/buttons/white8x8',
            edgeSize=1,
            insets={top=2,right=2,bottom=2,left=2}
        })
        block:SetBackdropBorderColor(.5,.5,.5)
        block:SetPoint('LEFT')

        if small then
            block:SetSize(14,14)
        else
            block:SetSize(18,18)
        end

        local label
        if small then
            label = container:CreateFontString(nil,'ARTWORK','GameFontHighlightSmall')
        else
            label = container:CreateFontString(nil,'ARTWORK','GameFontHighlight')
        end
        label:SetText(GetLocaleString(common_name,name,'Colour picker'))
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
-- separator ###################################################################
function opt.CreateSeparator(parent,name,common_name)
    local line = parent:CreateTexture(nil,'ARTWORK')
    line:SetTexture('interface/buttons/white8x8')
    line:SetVertexColor(1,1,1,.3)
    line:SetSize(400,1)

    local shadow = parent:CreateTexture(nil,'ARTWORK')
    shadow:SetTexture('interface/buttons/white8x8')
    shadow:SetVertexColor(0,0,0,.8)
    shadow:SetHeight(1)
    shadow:SetPoint('BOTTOMLEFT',line,'TOPLEFT')
    shadow:SetPoint('BOTTOMRIGHT',line,'TOPRIGHT')

    local label = parent:CreateFontString(nil,'ARTWORK','GameFontNormal')
    label:SetText(GetLocaleString(common_name,name,'Separator'))
    label:SetPoint('CENTER',line,0,10)

    line.label = label
    line.shadow = shadow
    return line
end
-- page functions ##############################################################
do
    local function PageOnShow(self)
        if type(self.Initialise) == 'function' then
            self:Initialise()
            self.Initialise = nil

            -- trigger initial OnShow of created elements
            self:Hide()
            self:Show()
        end
    end

    local page_proto = {
        CreateCheckBox = opt.CreateCheckBox,
        CreateDropDown = opt.CreateDropDown,
        CreateSlider = opt.CreateSlider,
        CreateColourPicker = opt.CreateColourPicker,
        CreateSeparator = opt.CreateSeparator,
    }
    local function BindPage(pg)
        for k,v in pairs(page_proto) do
            pg[k]=v
        end
        pg:SetScript('OnShow',PageOnShow)
    end
    function opt:CreateConfigPage(name)
        assert(name)

        local f = CreateFrame('Frame',frame_name..name..'Page',self)
        f:SetWidth(420)
        f:SetHeight(1)
        f:Hide()
        f.name = name
        f.id = #self.pages + 1
        f.elements = {}

        BindPage(f)
        self:CreatePageTab(f)
        self.pages[f.id] = f

        return f
    end
    function opt:CreatePopupPage(name,w,h)
        assert(name)

        local p = CreateFrame('Frame',nil,self.Popup)
        p:SetAllPoints(self.Popup)
        p:Hide()

        if type(w) == 'number' and type(h) == 'number' then
            -- used by Popup.ShowPage
            p.size = { w,h }
        end

        BindPage(p)

        self.Popup.pages[name] = p
        return p
    end
end
-- tab functions ###############################################################
do
    local function OnClick(self)
        PlaySound(S_CHECKBOX_ON)
        opt:ShowPage(self.child_id)
    end
    function opt:CreatePageTab(page)
        local tab = CreateFrame('Button',frame_name..page.name..'PageTab',self.TabList,'OptionsListButtonTemplate')
        tab:SetScript('OnClick',OnClick)
        tab:SetText(L.page_names[page.name] or page.name or 'Tab')
        tab:SetWidth(130)

        tab.child_id = page.id
        page.tab = tab

        local pt = tab.child_id > 1 and self.pages[(tab.child_id - 1)].tab
        if pt then
            tab:SetPoint('TOPLEFT',pt,'BOTTOMLEFT',0,-1)
        else
            tab:SetPoint('TOPLEFT',self.TabList,6,-6)
        end
    end
end
-- profile drop down functions #################################################
local CreateProfileDropDown
do
    local function OnValueChanged(self,value,text)
        if value and value == 'new_profile' then
            opt.Popup:ShowPage(
                'text_entry',
                L.titles['new_profile_label'],
                nil,
                self.new_profile_callback
            )
        else
            opt.config:SetProfile(text)
        end
    end
    local function initialize(self)
        -- sort profiles alphabetically
        local profiles_indexed = {}
        for name in pairs(opt.config.gsv.profiles) do
            tinsert(profiles_indexed,name)
        end
        table.sort(profiles_indexed,function(a,b)
            return strlower(a) < strlower(b)
        end)

        -- create new profile button at top
        local list = {}
        tinsert(list,{
            text = L.titles['new_profile'],
            value = 'new_profile'
        })

        -- create profile buttons
        for _,name in ipairs(profiles_indexed) do
            tinsert(list,{
                text = name,
                selected = name == opt.config.csv.profile
            })
        end

        self:SetList(list)
        self:SetValue(opt.config.csv.profile)
    end
    function CreateProfileDropDown(parent)
        local p_dd = pcdd:New(parent)
        p_dd.list_width = 175
        p_dd.labelText:SetFontObject('GameFontNormalSmall')
        p_dd:SetFrameStrata('TOOLTIP')

        p_dd.initialize = initialize
        p_dd.OnValueChanged = OnValueChanged

        p_dd.new_profile_callback = function(page,accept)
            if accept then
                opt.config:SetProfile(page.editbox:GetText())
            end
        end

        p_dd:HookScript('OnShow',function(self)
            self:initialize()
        end)

        return p_dd
    end
end
-- local popup functions #######################################################
local CreatePopup
do
    local function PopupOnShow(self)
        PlaySound(S_MENU_OPEN)
    end
    local function PopupOnHide(self)
        PlaySound(S_MENU_CLOSE)
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
                self:SetSize(400,150)
            end

            if type(self.active_page.PostShow) == 'function' then
                self.active_page:PostShow(...)
            end
        end

        self:Show()
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
        local colour_picker = opt:CreatePopupPage('colour_picker',400,300)

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
        local pg = opt:CreatePopupPage('confirm_dialog')

        local label = pg:CreateFontString(nil,'ARTWORK','GameFontNormal')
        label:SetPoint('BOTTOMLEFT',pg,'LEFT',40,10)
        label:SetPoint('RIGHT',-40,0)

        pg.label = label
        pg.PostShow = ConfirmDialog_PostShow
    end

    -- text-entry dialog (rename, copy, new) ###################################
    local function TextEntry_OnShow(self)
        self.editbox:SetFocus()
    end
    local function TextEntry_PostShow(self,desc,default,callback)
        self.callback = nil
        self.label:SetText('')
        self.editbox:SetText('')

        if callback then self.callback = callback end
        if desc     then self.label:SetText(desc) end
        if default  then self.editbox:SetText(default) end
    end
    local function TextEntry_OnEnterPressed(self)
        opt.Popup.Okay:Click()
    end
    local function TextEntry_OnEscapePressed(self)
        opt.Popup.Cancel:Click()
    end
    local function CreatePopupPage_TextEntry()
        local pg = opt:CreatePopupPage('text_entry')

        local label = pg:CreateFontString(nil,'ARTWORK','GameFontNormal')
        label:SetPoint('BOTTOMLEFT',pg,'LEFT',40,20)
        label:SetPoint('RIGHT',-40,0)

        local text = CreateFrame('EditBox',nil,pg,'InputBoxTemplate')
        text:SetAutoFocus(false)
        text:EnableMouse(true)
        text:SetMaxLetters(50)
        text:SetPoint('CENTER')
        text:SetSize(150,30)

        pg.label = label
        pg.editbox = text
        pg.PostShow = TextEntry_PostShow

        pg:SetScript('OnShow',TextEntry_OnShow)
        text:SetScript('OnEnterPressed',TextEntry_OnEnterPressed)
        text:SetScript('OnEscapePressed',TextEntry_OnEscapePressed)
    end

    -- create popup ############################################################
    function CreatePopup()
        local popup = CreateFrame('Frame',nil,opt)
        popup:SetBackdrop({
            bgFile='interface/buttons/white8x8',
            edgeFile='interface/dialogframe/ui-dialogbox-border',
            edgeSize=32,
            tile=true,
            tileSize=32,
            insets = {
                top=12,right=12,bottom=11,left=11
            }
        })
        popup:SetBackdropColor(0,0,0,.85)
        popup:SetPoint('CENTER')
        popup:SetFrameStrata('DIALOG')
        popup:EnableMouse(true)
        popup:Hide()
        popup.pages = {}

        popup.ShowPage = PopupShowPage

        popup:SetScript('OnKeyUp',PopupOnKeyUp)
        popup:SetScript('OnShow',PopupOnShow)
        popup:SetScript('OnHide',PopupOnHide)

        local okay = CreateButton(popup)
        okay:SetText('OK')
        okay:SetSize(90,22)
        okay:SetPoint('BOTTOM',-45,20)

        local cancel = CreateButton(popup)
        cancel:SetText('Cancel')
        cancel:SetSize(90,22)
        cancel:SetPoint('BOTTOM',45,20)

        okay:SetScript('OnClick',OkayButtonOnClick)
        cancel:SetScript('OnClick',CancelButtonOnClick)

        popup.Okay = okay
        popup.Cancel = cancel

        opt.Popup = popup

        -- create required pages
        CreatePopupPage_ColourPicker()
        CreatePopupPage_ConfirmDialog()
        CreatePopupPage_TextEntry()

        opt:HookScript('OnHide',function(opt)
            opt.Popup:Hide()
        end)
    end
end
-- page helper #################################################################
do
    local function HidePage(page)
        page.tab.highlight:SetVertexColor(.196,.388,.8)
        page.tab:UnlockHighlight()
        page:Hide()
    end
    function opt:ShowPage(page_id)
        if self.active_page then
            HidePage(self.active_page)
            self.active_page = nil
        end

        local target = self.pages[page_id]
        assert(target)
        self.active_page = target

        target.tab.highlight:SetVertexColor(1,1,0)
        target.tab:LockHighlight()
        target:Show()

        self.ScrollFrame:SetScrollChild(target)
        self.ScrollFrame.ScrollBar:SetValue(0)

        self:CurrentPage_UpdateClipboardButton()
    end
end
-- current page script helpers #################################################
do
    local clipboard,clipboard_page,clipboard_profile
    local function KuiConfig_ForceUpdate()
        -- XXX expose something in kuiconfig for this
        -- post updated profile to the saved variable
        _G[opt.config.gsv_name].profiles[opt.config.csv.profile] = opt.config.profile
        -- and force kuiconfig to update...
        opt.config:SetProfile(opt.config.csv.profile)
    end
    local function callback(page,accept)
        if accept then
            opt:CurrentPage_Paste()
        end
    end

    function opt:CurrentPage_Name()
        -- return localised name of current page
        if not self.active_page or not self.active_page.name then return end
        return L.page_names[self.active_page.name] or self.active_page.name
    end
    function opt:CurrentPage_Copy()
        -- copy settings from current page into clipboard
        assert(self.active_page.name)

        clipboard = {}
        clipboard_page = self.active_page.name
        clipboard_profile = self.config.csv.profile

        for e_name,e_frame in pairs(self.active_page.elements) do
            -- get envs from elements...
            env = e_frame.env
            if env then
                -- and their settings from the full profile
                clipboard[env] = self.profile[env]
            end
        end
    end
    function opt:CurrentPage_Paste()
        -- paste setttings from clipboard into current profile
        if not self:CurrentPage_CanPaste() then return end

        for env,value in pairs(clipboard) do
            self.config.profile[env] = value
        end
        KuiConfig_ForceUpdate()

        clipboard,clipboard_page,clipboard_profile = nil,nil,nil
        self:CurrentPage_UpdateClipboardButton()
    end
    function opt:CurrentPage_CanPaste()
        -- true if the page settings in our clipboard match the current page
        return (self.active_page and
                clipboard and
                clipboard_page and
                clipboard_profile and
                clipboard_page == self.active_page.name)
    end
    function opt:CurrentPage_Reset()
        -- reset settings on current page
        for e_name,e_frame in pairs(self.active_page.elements) do
            env = e_frame.env
            if env then
                self.config.profile[env] = nil
            end
        end
        KuiConfig_ForceUpdate()
    end
    function opt:CurrentPage_ClipboardButtonClick(button)
        if button == 'RightButton' or not self:CurrentPage_CanPaste() then
            self:CurrentPage_Copy()
            self:CurrentPage_UpdateClipboardButton()
        else
            -- confirm paste
            self.Popup:ShowPage(
                'confirm_dialog',
                format(L.titles['paste_page_label'],
                    opt:CurrentPage_Name(),
                    clipboard_profile,
                    self.config.csv.profile),
                callback
            )
        end
    end
    function opt:CurrentPage_UpdateClipboardButton()
        -- update managed button text
        if self:CurrentPage_CanPaste() then
            self.ClipboardButton:SetText(L.common['paste'])
        else
            self.ClipboardButton:SetText(L.common['copy'])
        end
    end
end
-- init category display #######################################################
local function CreateBackground(invisible)
    local new = CreateFrame('Frame',nil,opt)
    if not invisible then
        new:SetBackdrop({
            bgFile = 'interface/buttons/white8x8',
            edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
            edgeSize = 14,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        new:SetBackdropColor(.1,.1,.1,.6)
        new:SetBackdropBorderColor(.5,.5,.5)
    end
    return new
end
local function ProfileButtonOnShow(self)
    if opt.config.csv.profile == 'default' then
        self:Disable()
    else
        self:Enable()
    end
end
local function page_reset_callback(page,accept)
    if accept then opt:CurrentPage_Reset() end
end
local function page_reset_OnClick(self)
    opt.Popup:ShowPage(
        'confirm_dialog',
        format(L.titles['reset_page_label'],opt:CurrentPage_Name()),
        self.callback
    )
end
local function page_copy_OnClick(self,button)
    opt:CurrentPage_ClipboardButtonClick(button)
end
local function profile_copy_callback(page,accept)
    if accept then
        opt.config:CopyProfile(opt.config.csv.profile,page.editbox:GetText())
    end
end
local function profile_copy_OnClick(self)
    opt.Popup:ShowPage(
        'text_entry',
        L.titles['copy_profile_label'],
        nil,
        self.callback
    )
end
local function profile_rename_callback(page,accept)
    if accept then
        opt.config:RenameProfile(opt.config.csv.profile,page.editbox:GetText())
    end
end
local function profile_rename_OnClick(self)
    opt.Popup:ShowPage(
        'text_entry',
        string.format(
            L.titles['rename_profile_label'],
            opt.config.csv.profile
        ),
        opt.config.csv.profile,
        self.callback
    )
end
local function profile_reset_callback(page,accept)
    if accept then
        opt.config:ResetProfile(opt.config.csv.profile)
    end
end
local function profile_reset_OnClick(self)
    opt.Popup:ShowPage(
        'confirm_dialog',
        string.format(L.titles.reset_profile_label,opt.config.csv.profile),
        self.callback
    )
end
local function profile_delete_callback(page,accept)
    if accept then
        opt.config:DeleteProfile(opt.config.csv.profile)
    end
end
local function profile_delete_OnClick(self)
    opt.Popup:ShowPage(
        'confirm_dialog',
        string.format(L.titles.delete_profile_label,opt.config.csv.profile),
        self.callback
    )
end
function opt:Initialise()
    CreatePopup()

    -- backgrounds
    local profile_buttons_bg = CreateBackground()
    profile_buttons_bg:SetPoint('TOPLEFT',10,-10)
    profile_buttons_bg:SetWidth(150)
    profile_buttons_bg:SetHeight(100)

    local page_buttons_bg = CreateBackground()
    page_buttons_bg:SetPoint('BOTTOMLEFT',10,10)
    page_buttons_bg:SetWidth(150)
    page_buttons_bg:SetHeight(45)

    local tl_bg = CreateBackground()
    tl_bg:SetPoint('TOPLEFT',profile_buttons_bg,'BOTTOMLEFT',0,-5)
    tl_bg:SetPoint('BOTTOM',page_buttons_bg,'TOP',0,5)
    tl_bg:SetWidth(150)

    local p_bg = CreateBackground()
    p_bg:SetPoint('TOP',0,-10)
    p_bg:SetPoint('BOTTOMRIGHT',-10,10)
    p_bg:SetPoint('LEFT',tl_bg,'RIGHT',3,0)

    -- tab container
    local tablist = CreateFrame('Frame',frame_name..'TabList',self)
    tablist:SetPoint('TOPLEFT',tl_bg,4,-4)
    tablist:SetPoint('BOTTOMRIGHT',tl_bg,-4,4)

    do
        -- page scroll frame
        local scrollframe = CreateFrame('ScrollFrame',frame_name..'PageScrollFrame',p_bg,'UIPanelScrollFrameTemplate')
        scrollframe:SetPoint('TOPLEFT',p_bg,4,-4)
        scrollframe:SetPoint('BOTTOMRIGHT',p_bg,-26,4)

        scrollframe.ScrollBar.scrollStep = 50
        scrollframe.ScrollBar:SetBackdrop({bgFile='interface/buttons/white8x8'})
        scrollframe.ScrollBar:SetBackdropColor(0,0,0,.2)

        self.ScrollFrame = scrollframe
    end
    do
        -- page action buttons
        local page_actions_text = page_buttons_bg:CreateFontString(nil,'ARTWORK')
        page_actions_text:SetFont(STANDARD_TEXT_FONT,12,'OUTLINE')
        page_actions_text:SetTextColor(.7,.7,.7)
        page_actions_text:SetText(L.common['page'])
        page_actions_text:SetPoint('TOP',page_buttons_bg,0,5)

        local page_copy = CreateButton(page_buttons_bg)
        page_copy:RegisterForClicks('AnyUp')
        page_copy:SetPoint('LEFT',page_buttons_bg,10,0)
        page_copy:SetWidth(64)
        page_copy:SetHeight(22)
        page_copy:SetScript('OnClick',page_copy_OnClick)

        local page_reset = CreateButton(page_buttons_bg)
        page_reset:SetPoint('RIGHT',page_buttons_bg,-10,0)
        page_reset:SetWidth(64)
        page_reset:SetHeight(22)
        page_reset:SetText(L.common['reset'])
        page_reset.callback = page_reset_callback
        page_reset:SetScript('OnClick',page_reset_OnClick)

        self.ClipboardButton = page_copy
        self:CurrentPage_UpdateClipboardButton()
    end

    -- profile buttons
    local profile_actions_text = profile_buttons_bg:CreateFontString(nil,'ARTWORK')
    profile_actions_text:SetFont(STANDARD_TEXT_FONT,12,'OUTLINE')
    profile_actions_text:SetTextColor(.7,.7,.7)
    profile_actions_text:SetText(L.common['profile'])
    profile_actions_text:SetPoint('TOP',profile_buttons_bg,0,5)

    local p_dd = CreateProfileDropDown(profile_buttons_bg)
    p_dd:SetWidth(130)
    p_dd:SetHeight(40)
    p_dd:SetPoint('TOPLEFT',profile_buttons_bg,10,0)

    local p_copy = CreateButton(profile_buttons_bg)
    p_copy:SetPoint('TOP',p_dd,'BOTTOM',0,-2)
    p_copy:SetPoint('LEFT',10,0)
    p_copy:SetText(L.common['copy'])
    p_copy:SetSize(64,22)
    p_copy.callback = profile_copy_callback
    p_copy:SetScript('OnClick',profile_copy_OnClick)

    local p_reset = CreateButton(profile_buttons_bg)
    p_reset:SetPoint('LEFT',p_copy,'RIGHT',3,0)
    p_reset:SetText(L.common['reset'])
    p_reset:SetSize(64,22)
    p_reset.callback = profile_reset_callback
    p_reset:SetScript('OnClick',profile_reset_OnClick)

    local p_rename = CreateButton(profile_buttons_bg)
    p_rename:SetPoint('TOPLEFT',p_copy,'BOTTOMLEFT',0,-3)
    p_rename:SetText(L.common['rename'])
    p_rename:SetSize(64,22)
    p_rename.callback = profile_rename_callback
    p_rename:SetScript('OnShow',ProfileButtonOnShow)
    p_rename:SetScript('OnClick',profile_rename_OnClick)

    local p_delete = CreateButton(profile_buttons_bg)
    p_delete:SetPoint('LEFT',p_rename,'RIGHT',3,0)
    p_delete:SetText(L.common['delete'])
    p_delete:SetSize(64,22)
    p_delete.callback = profile_delete_callback
    p_delete:SetScript('OnShow',ProfileButtonOnShow)
    p_delete:SetScript('OnClick',profile_delete_OnClick)

    -- version string
    local version = self:CreateFontString(nil,'ARTWORK')
    version:SetFont(STANDARD_TEXT_FONT,10)
    version:SetJustifyH('RIGHT')
    version:SetTextColor(.7,.7,.7)
    version:SetPoint('BOTTOMRIGHT',self,'TOPRIGHT',-10,4)
    version:SetText(format(
        L.titles.version,
        'Kui Nameplates','Kesava','@project-version@'
    ))

    self.TabList = tablist
    self.TabListBG = tl_bg
    self.PageBG = p_bg
end
