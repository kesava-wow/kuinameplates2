local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local frame_name = 'KuiNameplatesCoreConfig'
-- generic helpers #############################################################
local function EditBoxOnEscapePressed(self)
    self:ClearFocus()
end
-- element creation helpers ####################################################
do
    local function OnEnter(self)
        GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
        GameTooltip:SetWidth(200)
        GameTooltip:AddLine(self.label and self.label:GetText() or '')

        if opt.tooltips[self.env] then
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

    local function CheckBoxOnClick(self)
        if self:GetChecked() then
            PlaySound("igMainMenuOptionCheckBoxOn")
        else
            PlaySound("igMainMenuOptionCheckBoxOff")
        end

        if self.env and opt.config then
            opt.config:SetConfig(self.env,self:GetChecked())
        end

        if self.callback then
            self:callback()
        end
    end
    local function CheckBoxOnShow(self)
        if not opt.profile then return end
        if self.env then
            self:SetChecked(opt.profile[self.env])
        end

        GenericOnShow(self)
    end

    function opt.CreateCheckBox(parent, name, callback)
        local check = CreateFrame('CheckButton', frame_name..name..'Check', parent, 'OptionsBaseCheckButtonTemplate')

        check.env = name
        check.callback = callback
        check:SetScript('OnClick',CheckBoxOnClick)
        check:SetScript('OnShow',CheckBoxOnShow)

        check:HookScript('OnEnter',OnEnter)
        check:HookScript('OnLeave',OnLeave)
        check:HookScript('OnEnable',OnEnable)
        check:HookScript('OnDisable',OnDisable)

        check.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        check.label:SetText(opt.titles[name] or 'Checkbox')
        check.label:SetPoint('LEFT', check, 'RIGHT')

        return check
    end

    function opt.CreateDropDown(parent, name, width)
        local dd = CreateFrame('Frame',frame_name..name..'DropDown',parent,'UIDropDownMenuTemplate')
        UIDropDownMenu_SetWidth(dd,width or 150)

        dd:HookScript('OnEnter',OnEnter)
        dd:HookScript('OnLeave',OnLeave)

        dd.label = parent:CreateFontString(dd:GetName()..'Label','ARTWORK','GameFontNormalSmall')
        dd.label:SetText(opt.titles[name] or 'DropDown')
        dd.label:SetPoint('BOTTOMLEFT',dd,'TOPLEFT',20,1)

        return dd
    end

    local function SliderOnShow(self)
        if not opt.profile then return end
        if self.env then
            self:SetValue(opt.profile[self.env])
        end

        GenericOnShow(self)
    end
    local function SliderOnChanged(self)
        self.display:SetText(self:GetValue())
    end
    local function SliderOnManualChange(self)
        if self.env and opt.config then
            opt.config:SetConfig(self.env,self:GetValue())
        end
    end
    local function SliderOnMouseWheel(self,delta)
        self:SetValue(self:GetValue()+delta)
        SliderOnManualChange(self)
    end
    local function SliderSetMinMaxValues(self,min,max)
        self:orig_SetMinMaxValues(min,max)
        self.Low:SetText(min)
        self.High:SetText(max)
    end
    function opt.CreateSlider(parent, name, min, max)
        local slider = CreateFrame('Slider',frame_name..name..'Slider',parent,'OptionsSliderTemplate')
        slider:SetWidth(150)
        slider:SetHeight(15)
        slider:SetOrientation('HORIZONTAL')
        slider:SetThumbTexture('interface/buttons/ui-sliderbar-button-horizontal')
        slider:SetObeyStepOnDrag(true)
        slider:EnableMouseWheel(true)

        local label = parent:CreateFontString(slider:GetName()..'Label','ARTWORK','GameFontNormal')
        label:SetText(opt.titles[name] or 'Slider')
        label:SetPoint('BOTTOM',slider,'TOP')

        local display = parent:CreateFontString(slider:GetName()..'Display','ARTWORK','GameFontHighlightSmall')
        display:SetPoint('TOP',slider,'BOTTOM')
        -- TODO editbox

        slider.orig_SetMinMaxValues = slider.SetMinMaxValues
        slider.SetMinMaxValues = SliderSetMinMaxValues

        slider.env = name
        slider.label = label
        slider.display = display

        slider:HookScript('OnEnter',OnEnter)
        slider:HookScript('OnLeave',OnLeave)
        slider:HookScript('OnEnable',OnEnable)
        slider:HookScript('OnDisable',OnDisable)
        slider:HookScript('OnShow',SliderOnShow)
        slider:HookScript('OnValueChanged',SliderOnChanged)
        slider:HookScript('OnMouseUp',SliderOnManualChange)
        slider:HookScript('OnMouseWheel',SliderOnMouseWheel)

        slider:SetValueStep(1)
        slider:SetMinMaxValues(min or 0, max or 100)

        return slider
    end
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

        HidePage = HidePage,
        ShowPage = ShowPage
    }
    function opt:CreateConfigPage(name)
        local f = CreateFrame('Frame',frame_name..name..'Page',self)
        f.name = name

        f.scroll = CreateFrame('ScrollFrame',frame_name..name..'PageScrollFrame',self,'UIPanelScrollFrameTemplate')
        f.scroll:SetPoint('TOPLEFT',self.PageBG,10,-10)
        f.scroll:SetPoint('BOTTOMRIGHT',self.PageBG,-30,10)
        f.scroll:SetScrollChild(f)

        f:SetWidth(1)
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
        tab:SetText(self.page_names[page.name] or 'Tab')
        tab:SetWidth(110)

        tab.child = page
        page.tab = tab

        local pt = #self.pages > 0 and self.pages[#self.pages].tab

        if pt then
            tab:SetPoint('TOPLEFT',pt,'BOTTOMLEFT')
        else
            tab:SetPoint('TOPLEFT',self.TabList)
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

    local function PopupShowPage(self,page_name)
        if self.active_page then
            self.active_page:Hide()
        end

        if self.pages[page_name] then
            self.pages[page_name]:Show()
            self.active_page = self.pages[page_name]
        end

        self:Show()
    end

    local function CreatePopupPage_NewProfile()
        local new_profile = CreateFrame('Frame',nil,opt.Popup)
        new_profile:SetAllPoints(opt.Popup)
        new_profile:Hide()

        function new_profile:callback(accept)
            if accept then
                opt.config:SetProfile(self.editbox:GetText())
            end
        end

        local profile_name = CreateFrame('EditBox',nil,new_profile,'InputBoxTemplate')
        profile_name:SetAutoFocus(false)
        profile_name:EnableMouse(true)
        profile_name:SetMaxLetters(50)
        profile_name:SetPoint('CENTER')
        profile_name:SetSize(150,30)

        new_profile.editbox = profile_name

        new_profile:SetScript('OnShow',function(self)
            self.editbox:SetText('')
            self.editbox:SetFocus()
        end)

        profile_name:SetScript('OnEnterPressed',function(self)
            opt.Popup.Okay:Click()
        end)
        profile_name:SetScript('OnEscapePressed',function(self)
            opt.Popup.Cancel:Click()
        end)

        opt.Popup.pages.new_profile = new_profile
    end

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
        popup:SetSize(400,300)
        popup:SetPoint('CENTER')
        popup:SetFrameStrata('DIALOG')
        popup:EnableMouse(true)
        popup:Hide()
        popup.pages = {}

        popup.ShowPage = PopupShowPage

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

        -- create popup pages
        CreatePopupPage_NewProfile()
    end
end
-- init display ################################################################
function opt:Initialise()
    self:CreatePopup()

    -- create profile dropdown
    local profileDropDown = self:CreateDropDown('profile',130)
    profileDropDown:SetPoint('TOPLEFT',-5,-23)

    self.profileDropDown = profileDropDown

    -- create backgrounds
    local tl_bg = CreateFrame('Frame',nil,self)
    tl_bg:SetBackdrop({
        bgFile = 'Interface/ChatFrame/ChatFrameBackground',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    tl_bg:SetBackdropColor(.1,.1,.1,.3)
    tl_bg:SetBackdropBorderColor(.5,.5,.5)
    tl_bg:SetPoint('TOPLEFT',self,10,-60)
    tl_bg:SetPoint('BOTTOMLEFT',self,10,10)
    tl_bg:SetWidth(150)

    local p_bg = CreateFrame('Frame',nil,self)
    p_bg:SetBackdrop({
        bgFile = 'Interface/ChatFrame/ChatFrameBackground',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    p_bg:SetBackdropColor(.1,.1,.1,.3)
    p_bg:SetBackdropBorderColor(.5,.5,.5)
    p_bg:SetPoint('TOPLEFT',tl_bg,'TOPRIGHT',10,0)
    p_bg:SetPoint('BOTTOMRIGHT',self,-10,10)

    -- create tab container
    local tablist = CreateFrame('Frame',frame_name..'TabList',self)
    tablist:SetWidth(1)
    tablist:SetHeight(1)

    local scroll = CreateFrame('ScrollFrame',frame_name..'TabListScrollFrame',self,'UIPanelScrollFrameTemplate')
    scroll:SetPoint('TOPLEFT',tl_bg,10,-10)
    scroll:SetPoint('BOTTOMRIGHT',tl_bg,-30,10)
    scroll:SetScrollChild(tablist)

    tablist.Scroll = scroll

    self.TabList = tablist
    self.TabListBG = tl_bg
    self.PageBG = p_bg
end
