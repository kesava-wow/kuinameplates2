local folder,ns = ...
local opt = KuiNameplatesCoreConfig
local frame_name = 'KuiNameplatesCoreConfig'
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
    end

    function opt.CreateCheckBox(parent, name, callback)
        local check = CreateFrame('CheckButton', frame_name..name..'Check', parent, 'OptionsBaseCheckButtonTemplate')

        check.env = name
        check.callback = callback
        check:SetScript('OnClick',CheckBoxOnClick)
        check:SetScript('OnShow',CheckBoxOnShow)

        check:HookScript('OnEnter',OnEnter)
        check:HookScript('OnLeave',OnLeave)

        check.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        check.label:SetText(opt.titles[name] or 'Checkbox')
        check.label:SetPoint('LEFT', check, 'RIGHT')

        return check
    end

    function opt.CreateDropDown(parent, name)
        local dd = CreateFrame('Frame',frame_name..name..'DropDown',parent,'UIDropDownMenuTemplate')
        UIDropDownMenu_SetWidth(dd,150)

        dd:HookScript('OnEnter',OnEnter)
        dd:HookScript('OnLeave',OnLeave)

        dd.label = parent:CreateFontString(dd:GetName()..'Label','ARTWORK','GameFontHighlightSmall')
        dd.label:SetText(opt.titles[name] or 'DropDown')
        dd.label:SetPoint('BOTTOMLEFT',dd,'TOPLEFT',20,1)

        return dd
    end

    local function SliderOnChanged(self)
        self.display:SetText(self:GetValue())
    end
    function opt.CreateSlider(parent, name)
        local slider = CreateFrame('Slider',frame_name..name..'Slider',parent,'OptionsSliderTemplate')
        slider:SetWidth(150)
        slider:SetHeight(15)
        slider:SetOrientation('HORIZONTAL')
        slider:SetThumbTexture('interface/buttons/ui-sliderbar-button-horizontal')
        slider:SetMinMaxValues(0,100)
        slider:SetValue(0)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)

        slider:HookScript('OnValueChanged',SliderOnChanged)

        local label = parent:CreateFontString(slider:GetName()..'Label','ARTWORK','GameFontHighlight')
        label:SetText(opt.titles[name] or 'Slider')
        label:SetPoint('BOTTOM',slider,'TOP')

        local display = parent:CreateFontString(slider:GetName()..'Display','ARTWORK','GameFontHighlightSmall')
        display:SetPoint('TOP',slider,'BOTTOM')

        slider.label = label
        slider.display = display

        return slider
    end
end
-- page functions ##############################################################
do
    local function ShowPage(self)
        if opt.active_page then
            opt.active_page:HidePage()
            PanelTemplates_DeselectTab(opt.active_page.tab)
        end

        self.scroll:Show()
        self.bg:Show()
        self:Show()

        opt.active_page = self
        PanelTemplates_SelectTab(self.tab)
    end
    local function HidePage(self)
        self.scroll:Hide()
        self.bg:Hide()
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
        f.scroll:SetPoint('TOPLEFT',20,-95)
        f.scroll:SetPoint('BOTTOMRIGHT',-40,20)
        f.scroll:SetScrollChild(f)

        f.bg = CreateFrame('Frame',nil,self)
        f.bg:SetBackdrop({
            bgFile = 'Interface/ChatFrame/ChatFrameBackground',
            edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        f.bg:SetBackdropColor(.1, .1, .1, .3)
        f.bg:SetBackdropBorderColor(.5, .5, .5)
        f.bg:SetPoint('TOPLEFT',f.scroll,-10,10)
        f.bg:SetPoint('BOTTOMRIGHT',f.scroll,30,-10)

        f:SetWidth(1)
        f:SetHeight(1000)

        -- mixin page functions
        for k,v in pairs(page_proto) do
            f[k]=v
        end

        f:HidePage()

        tinsert(self.pages,f)
        return f
    end
end
-- tab functions ###############################################################
do
    local function OnClick(self)
        self.child:ShowPage()
    end
    function opt:CreateTabs(self)
        local pt
        for k,v in ipairs(opt.pages) do
            local tab = CreateFrame('Button',frame_name..v.name..'PageTab',opt,'TabButtonTemplate')
            tab:HookScript('OnClick',OnClick)
            tab:SetText(opt.page_names[v.name] or 'Tab')

            tab.child = v
            v.tab = tab

            if pt then
                tab:SetPoint('LEFT',pt,'RIGHT')
            else
                tab:SetPoint('TOPLEFT',10,-54)
            end

            PanelTemplates_TabResize(tab,0)
            PanelTemplates_DeselectTab(tab)

            pt = tab
        end
    end
end
