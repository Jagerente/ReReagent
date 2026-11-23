local _, ns = ...

local UI = ns.UI
local L = ns.L
local C = UI.COLORS
local T = UI.TEXT
local W = ns.Widgets
local Catalog = ns.Catalog
local Inventory = ns.Inventory
local SidePanel = ns.SidePanel

local Options = {}
ns.Options = Options

local WIDTH, HEIGHT = 380, 560
local MARGIN = 14
local HEADER_HEIGHT, TABS_HEIGHT, BODY_GAP = 38, 26, 10
local HEADER_GLYPH_HEIGHT, HEADER_GLYPH_GAP = 16, 8
local SETTINGS_GLYPH_HEIGHT = 20
local TAB_PAD, MIN_TAB_PAD, TAB_GAP = 8, 4, 4
local PAGE_WIDTH = WIDTH - MARGIN * 2
local CONTENT_INSET = 8
local SECTION_GAP = 10
local SLIDER_GAP = 8
local PARAGRAPH_GAP = 6
local LIST_GAP, REAGENT_GAP = 14, 14
local HEAD_HEIGHT, ICON_SIZE, ICON_TEXT_GAP = 36, 30, 10
local FORM_INDENT = ICON_SIZE + ICON_TEXT_GAP
local FORM_ROW_HEIGHT, FORM_TOP_GAP, FORM_LABEL_GAP = 26, 4, 8
local FORM_SLIDER_WIDTH = 180
local ICON_BACK = { 0, 0, 0, 0.7 }
local ICON_CROP = 0.08
local STOCK_MAX_FLOOR = 40
local STOCK_MAX_STACKS = 2
local ICON_SIZE_MIN, ICON_SIZE_MAX = 24, 64
local SPACING_MAX = 16
local RESET_CONFIRM_SECONDS = 3
local PANEL_OFFSET = 500
local PERCENT_MAX = 100

local window
local pages = {}
local tabButtons = {}
local tabPad = TAB_PAD
local currentPage
local previewStartedHere = false

local function Setting(key)
    return function() return ns.db[key] end, function(value) ns.Set(key, value) end
end

local function Track(page, widget)
    page.widgets[#page.widgets + 1] = widget
    return widget
end

local function AddToggle(page, key, label, desc)
    local get, set = Setting(key)
    return page.stack:Add(Track(page, W.Toggle(page.content, PAGE_WIDTH, { label = label, desc = desc, get = get, set = set })))
end

local function AddSlider(page, key, label, min, max, format, gap)
    local get, set = Setting(key)
    return page.stack:Add(Track(page, W.Slider(page.content, PAGE_WIDTH, {
        label = label, min = min, max = max, step = 1, get = get, set = set, format = format,
    })), gap or SLIDER_GAP)
end

local function AddSegmented(page, key, label, items, gap)
    local get, set = Setting(key)
    return page.stack:Add(Track(page, W.Segmented(page.content, PAGE_WIDTH, {
        label = label, count = #items, get = get, set = set,
        items = function()
            local list = {}
            for i, item in ipairs(items) do
                list[i] = { value = item.value, text = L[item.key] }
            end
            return list
        end,
    })), gap)
end

local function AddHeading(page, key)
    return page.stack:Add(W.Heading(page.content, PAGE_WIDTH, key), #page.stack.frames > 0 and SECTION_GAP or 0)
end

local function AddParagraph(page, key)
    return page.stack:Add(W.Paragraph(page.content, PAGE_WIDTH, key), PARAGRAPH_GAP)
end

local function AddLiveText(page, build, color, gap)
    local frame = CreateFrame("Frame", nil, page.content)
    frame:SetWidth(PAGE_WIDTH)
    local text = UI.Text(frame, T.label, color)
    text:SetPoint("TOPLEFT")
    text:SetWidth(PAGE_WIDTH)
    text:SetWordWrap(true)
    text:SetJustifyH("LEFT")
    text:SetSpacing(3)
    function frame:Refresh()
        text:SetText(build())
        self:SetHeight(math.floor(text:GetStringHeight() + 4))
    end
    frame:Refresh()
    page.stack:Add(Track(page, frame), gap)
    return frame
end

local function NewPage(id)
    local scroll = W.Scroll(window.body)
    scroll:SetAllPoints(window.body)
    scroll:Hide()
    local page = { id = id, scroll = scroll, content = scroll.content, widgets = {} }
    page.stack = W.Stack(page.content, CONTENT_INSET)
    pages[id] = page
    return page
end

local function RefreshPage(page, animate)
    for _, widget in ipairs(page.widgets) do
        widget:Refresh(animate)
    end
    if page.OnShow then page:OnShow() end
end

local function IsCurrent(page)
    return window and window:IsShown() and currentPage == page
end

local function FormatPercent(value)
    return string.format("%d%%", value)
end

local function StockMax(entry)
    return math.max(STOCK_MAX_FLOOR, entry.stock * STOCK_MAX_STACKS)
end

local function DetailText(entry)
    local used = Catalog.UsedBy(entry)
    if entry.forTop then return used end
    return string.format(L.LOWER_RANK_ONLY, used)
end

local function ShowReagentTooltip(head)
    local row = head.row
    GameTooltip:SetOwner(head, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(row.entry.item)
    if row.status:IsTruncated() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(DetailText(row.entry), C.muted[1], C.muted[2], C.muted[3], true)
    end
    GameTooltip:Show()
end

local function CreateReagentHead(row)
    local head = CreateFrame("Button", nil, row)
    head:SetPoint("TOPLEFT")
    head:SetPoint("TOPRIGHT")
    head:SetHeight(HEAD_HEIGHT)
    head.row = row
    head.UpdateTooltip = ShowReagentTooltip
    W.RowHover(head)
    local back = head:CreateTexture(nil, "ARTWORK")
    back:SetColorTexture(unpack(ICON_BACK))
    back:SetSize(ICON_SIZE, ICON_SIZE)
    back:SetPoint("LEFT")
    row.icon = head:CreateTexture(nil, "OVERLAY")
    row.icon:SetPoint("TOPLEFT", back, 1, -1)
    row.icon:SetPoint("BOTTOMRIGHT", back, -1, 1)
    row.icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)
    row.switch = W.CreateSwitch(head)
    row.switch:SetPoint("RIGHT")
    row.name = UI.BoldText(head, T.body, C.text)
    row.name:SetPoint("TOPLEFT", back, "TOPRIGHT", ICON_TEXT_GAP, 0)
    row.name:SetPoint("RIGHT", row.switch, "LEFT", -ICON_TEXT_GAP, 0)
    row.name:SetJustifyH("LEFT")
    row.status = UI.Text(head, T.label, C.muted)
    row.status:SetPoint("BOTTOMLEFT", back, "BOTTOMRIGHT", ICON_TEXT_GAP, 0)
    row.status:SetPoint("RIGHT", row.switch, "LEFT", -ICON_TEXT_GAP, 0)
    row.status:SetJustifyH("LEFT")
    head:SetScript("OnClick", function()
        Catalog.SetTracked(row.entry, not Catalog.IsTracked(row.entry))
    end)
    head:HookScript("OnEnter", function(self)
        W.SetSwitchHover(row.switch, true)
        ShowReagentTooltip(self)
    end)
    head:HookScript("OnLeave", function(self)
        W.SetSwitchHover(row.switch, false)
        W.HideHint(self)
    end)
end

local function CreateStockForm(row)
    local form = CreateFrame("Frame", nil, row)
    form:SetSize(PAGE_WIDTH - FORM_INDENT, FORM_ROW_HEIGHT)
    form:SetPoint("TOPLEFT", FORM_INDENT, -(HEAD_HEIGHT + FORM_TOP_GAP))
    form:EnableMouse(true)
    form:SetScript("OnEnter", function(self) W.ShowHint(self, "STOCK_DESC") end)
    form:SetScript("OnLeave", W.HideHint)
    row.stockOptions = {
        min = 0, max = StockMax(row.entry), step = 1,
        get = function() return Catalog.StockTarget(row.entry) end,
        set = function(value) Catalog.SetStockTarget(row.entry, value) end,
    }
    row.slider = W.Slider(form, FORM_SLIDER_WIDTH, row.stockOptions)
    row.slider:SetPoint("RIGHT")
    local label = UI.Text(form, T.label, C.muted)
    label:SetPoint("LEFT")
    label:SetPoint("RIGHT", row.slider, "LEFT", -FORM_LABEL_GAP, 0)
    label:SetJustifyH("LEFT")
    W.Bind(label, "STOCK_ROW")
    row.form = form
end

local function CreateReagentRow(list, entry)
    local row = CreateFrame("Frame", nil, list)
    row:SetWidth(PAGE_WIDTH)
    row.entry = entry
    CreateReagentHead(row)
    CreateStockForm(row)
    return row
end

local function PaintReagentRow(row, animate)
    local entry = row.entry
    local tracked = Catalog.IsTracked(entry)
    row.icon:SetTexture(Catalog.Icon(entry))
    row.icon:SetDesaturated(not tracked or Inventory.Count(entry.item) == 0)
    row.name:SetText(Catalog.Name(entry))
    row.name:SetTextColor(unpack(tracked and C.text or C.muted))
    row.status:SetText(DetailText(entry))
    W.SetSwitch(row.switch, tracked, animate)
    row.stockOptions.max = StockMax(entry)
    row.form:SetShown(tracked)
    row.slider:Refresh()
    row:SetHeight(tracked and HEAD_HEIGHT + FORM_TOP_GAP + FORM_ROW_HEIGHT or HEAD_HEIGHT)
end

local function AddReagentList(page)
    local list = CreateFrame("Frame", nil, page.content)
    list:SetWidth(PAGE_WIDTH)
    list.rows = {}
    function list:Refresh(animate)
        local y = 0
        for index, entry in ipairs(Catalog.listed) do
            local row = self.rows[index]
            if not row then
                row = CreateReagentRow(self, entry)
                self.rows[index] = row
            end
            local same = row.entry == entry
            row.entry = entry
            PaintReagentRow(row, animate and same)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -y)
            row:Show()
            y = y + row:GetHeight() + REAGENT_GAP
        end
        for index = #Catalog.listed + 1, #self.rows do
            self.rows[index]:Hide()
        end
        self:SetShown(#Catalog.listed > 0)
        self:SetHeight(math.max(1, y - REAGENT_GAP))
    end
    list:Refresh(false)
    page.stack:Add(Track(page, list), LIST_GAP)
end

local function EmptyText()
    if not Catalog.HasReagents() then return L.NO_REAGENTS_CLASS end
    return L.NO_REAGENTS_KNOWN
end

local function AddEmptyText(page)
    local empty = AddLiveText(page, EmptyText, C.text, LIST_GAP)
    local paint = empty.Refresh
    function empty:Refresh()
        self:SetShown(#Catalog.listed == 0)
        paint(self)
    end
    empty:Refresh()
end

local function BuildReagents()
    local page = NewPage("reagents")
    AddToggle(page, "knownOnly", "KNOWN_ONLY", "KNOWN_ONLY_DESC")
    AddToggle(page, "lowerRanks", "LOWER_RANKS", "LOWER_RANKS_DESC")
    AddEmptyText(page)
    AddReagentList(page)

    local function RefreshIfVisible()
        if IsCurrent(page) then RefreshPage(page, true) end
    end
    ns.Listen("REAGENTS_CHANGED", RefreshIfVisible)
    ns.Listen("RANKS_CHANGED", RefreshIfVisible)
    ns.Listen("NAMES_CHANGED", RefreshIfVisible)
    ns.Listen("STOCK_CHANGED", RefreshIfVisible)
    ns.Listen("INVENTORY_CHANGED", RefreshIfVisible)
end

local AUTO = "auto"
local DOCK_SIDE_GAP, DOCK_TEXT_GAP = 10, 8
local DOCK_PAGES = { "bank", "vendor" }

local function DockTargets(slot)
    local items = {
        { value = AUTO, text = L.DOCK_AUTO },
        { value = ns.Dock.HOST, text = L["DOCK_HOST_" .. slot] },
    }
    for _, name in ipairs(ns.Dock:Family(slot)) do
        if name ~= ns.ADDON and ns.Dock:CanAttach(ns.ADDON, slot, name) then
            items[#items + 1] = { value = name, text = name }
        end
    end
    return items
end

local function DefaultSide(target)
    return target == ns.Dock.HOST and "RIGHT" or "BELOW"
end

local function SetDockTarget(slot, target)
    if target == AUTO then
        SidePanel.SetPlacement(slot, nil)
        return
    end
    local placement = SidePanel.Placement(slot)
    SidePanel.SetPlacement(slot, target, placement and placement.side or DefaultSide(target))
end

local function SetDockSide(slot, side)
    local placement = SidePanel.Placement(slot)
    if placement then SidePanel.SetPlacement(slot, placement.target, side) end
end

local function DockStatus(slot)
    local parent, side, takenBy = ns.Dock:Place(ns.ADDON, slot)
    if not parent then return "" end
    local where = parent == ns.Dock.HOST and L["DOCK_OF_" .. slot] or parent
    local text = string.format(L["DOCK_NOW_" .. side], where)
    if takenBy then text = text .. "\n" .. string.format(L.DOCK_TAKEN, takenBy) end
    return text
end

local function DockSides()
    local list = {}
    for index, side in ipairs(ns.Dock.SIDES) do
        list[index] = { value = side, text = L["DOCK_SIDE_" .. side] }
    end
    return list
end

local function AddDockControls(page, slot)
    page.stack:Add(Track(page, W.Choices(page.content, PAGE_WIDTH, {
        label = "DOCK_TARGET",
        items = function() return DockTargets(slot) end,
        get = function()
            local placement = SidePanel.Placement(slot)
            return placement and placement.target or AUTO
        end,
        set = function(target) SetDockTarget(slot, target) end,
    })))
    local sides = page.stack:Add(Track(page, W.Segmented(page.content, PAGE_WIDTH, {
        label = "DOCK_SIDE",
        count = #ns.Dock.SIDES,
        items = DockSides,
        get = function()
            local placement = SidePanel.Placement(slot)
            return placement and placement.side
        end,
        set = function(side) SetDockSide(slot, side) end,
    })), DOCK_SIDE_GAP)
    local status = AddLiveText(page, function() return DockStatus(slot) end, C.text, DOCK_TEXT_GAP)
    local paintStatus = status.Refresh
    function status:Refresh()
        sides:SetShown(SidePanel.Placement(slot) ~= nil)
        paintStatus(self)
    end
    status:Refresh()
end

ns.Dock:OnChange(function()
    for _, id in ipairs(DOCK_PAGES) do
        local page = pages[id]
        if page and IsCurrent(page) then RefreshPage(page, true) end
    end
end)

local function BuildVendor()
    local page = NewPage("vendor")
    AddHeading(page, "SECTION_VENDOR")
    AddToggle(page, "merchant", "VENDOR", "VENDOR_DESC")
    AddToggle(page, "merchantAuto", "VENDOR_AUTO")
    AddToggle(page, "countBank", "COUNT_BANK", "COUNT_BANK_DESC")

    AddHeading(page, "SECTION_PLACEMENT")
    AddDockControls(page, "merchant")
    AddSlider(page, "merchantX", "OFFSET_X", -PANEL_OFFSET, PANEL_OFFSET)
    AddSlider(page, "merchantY", "OFFSET_Y", -PANEL_OFFSET, PANEL_OFFSET)
end

local function BuildBank()
    local page = NewPage("bank")
    AddHeading(page, "SECTION_BANK")
    AddToggle(page, "bank", "BANK", "BANK_DESC")
    AddToggle(page, "bankAuto", "BANK_AUTO")

    AddHeading(page, "SECTION_PLACEMENT")
    AddDockControls(page, "bank")
    AddSlider(page, "bankX", "OFFSET_X", -PANEL_OFFSET, PANEL_OFFSET)
    AddSlider(page, "bankY", "OFFSET_Y", -PANEL_OFFSET, PANEL_OFFSET)
end

local VISIBILITY_MODES = {
    { value = "always", key = "VISIBILITY_always" },
    { value = "short", key = "VISIBILITY_short" },
    { value = "combat", key = "VISIBILITY_combat" },
    { value = "never", key = "VISIBILITY_never" },
}

local LAYOUT_MODES = {
    { value = "HORIZONTAL", key = "LAYOUT_HORIZONTAL" },
    { value = "VERTICAL", key = "LAYOUT_VERTICAL" },
}

local function AddRecenterButton(page)
    local button = W.Button(page.content, "RECENTER", function() ns.Bar.ResetPosition() end)
    page.stack:Add(button, 12)
end

local function AddResetButton(page)
    local button
    local function Disarm()
        button.armed = false
        button.text:SetText(L.RESET)
        button:Fit()
    end
    button = W.Button(page.content, "RESET", function(self)
        if self.armed then
            Disarm()
            ns.ResetSettings()
            return
        end
        self.armed = true
        self.text:SetText(L.RESET_CONFIRM)
        self:Fit()
        C_Timer.After(RESET_CONFIRM_SECONDS, function()
            if self.armed then Disarm() end
        end)
    end, "danger")
    page.stack:Add(button, 16)
end

local LANGUAGE_ITEMS = {}
for i, code in ipairs(ns.LANGUAGES) do
    LANGUAGE_ITEMS[i] = { value = code, key = "LANGUAGE_" .. code }
end

local function BuildPanel()
    local page = NewPage("panel")
    AddHeading(page, "SECTION_WHEN")
    AddSegmented(page, "visibility", "VISIBILITY", VISIBILITY_MODES)
    AddParagraph(page, "VISIBILITY_EXPLAIN")
    AddToggle(page, "showEmpty", "SHOW_EMPTY", "SHOW_EMPTY_DESC")

    AddHeading(page, "SECTION_LOOK")
    AddSlider(page, "iconSize", "ICON_SIZE", ICON_SIZE_MIN, ICON_SIZE_MAX, nil, 4)
    AddSlider(page, "spacing", "SPACING", 0, SPACING_MAX)
    AddSegmented(page, "layout", "LAYOUT", LAYOUT_MODES, SLIDER_GAP)
    AddToggle(page, "showHeader", "SHOW_HEADER", "SHOW_HEADER_DESC")
    AddToggle(page, "showCounts", "SHOW_COUNTS", "SHOW_COUNTS_DESC")
    AddToggle(page, "locked", "LOCKED")
    AddRecenterButton(page)

    AddHeading(page, "SECTION_BACKGROUND")
    AddSlider(page, "barBackground", "BAR_BACKGROUND", 0, PERCENT_MAX, FormatPercent, 4)
    AddSlider(page, "panelBackground", "PANEL_BACKGROUND", 0, PERCENT_MAX, FormatPercent)

    AddHeading(page, "SECTION_OTHER")
    page.stack:Add(Track(page, W.Toggle(page.content, PAGE_WIDTH, {
        label = "MINIMAP_BUTTON",
        get = function() return not ns.db.minimap.hide end,
        set = ns.MinimapButton.SetShown,
    })))
    AddSegmented(page, "locale", "LANGUAGE", LANGUAGE_ITEMS, SECTION_GAP)
    AddResetButton(page)
end

local function BuildAbout()
    ns.About.Build(NewPage("about"), PAGE_WIDTH)
end

local DEFAULT_PAGE = "reagents"
local TABS = {
    { id = "reagents", key = "NAV_REAGENTS", build = BuildReagents },
    { id = "panel", key = "NAV_PANEL", build = BuildPanel },
    { id = "vendor", key = "NAV_VENDOR", build = BuildVendor },
    { id = "bank", key = "NAV_BANK", build = BuildBank },
    { id = "about", key = "NAV_ABOUT", build = BuildAbout },
}

local function FindTab(id)
    for _, entry in ipairs(TABS) do
        if entry.id == id then return entry end
    end
end

local underline = { x = 0, width = 0, motion = {} }

local function SetUnderline(x, width)
    underline.x, underline.width = x, width
    window.tabUnderline:SetPoint("BOTTOMLEFT", window.tabBar, "BOTTOMLEFT", x, 0)
    window.tabUnderline:SetWidth(math.max(1, width))
end

local function MoveUnderline(button, animate)
    local toX, toWidth = button.offset + tabPad, button:GetWidth() - tabPad * 2
    if not animate then
        UI.SnapTween(underline.motion, 1, function() SetUnderline(toX, toWidth) end)
        return
    end
    local fromX, fromWidth = underline.x, underline.width
    underline.motion.tweenValue = 0
    UI.Tween(underline.motion, 1, 0.2, function(_, t)
        SetUnderline(UI.Lerp(fromX, toX, t), UI.Lerp(fromWidth, toWidth, t))
    end)
end

local function ShowPage(id, animate)
    if not FindTab(id) then id = DEFAULT_PAGE end
    local page = pages[id]
    if not page then
        FindTab(id).build()
        page = pages[id]
    end
    if currentPage and currentPage ~= page then
        currentPage.scroll:Hide()
    end
    currentPage = page
    RefreshPage(page)
    page.scroll:ScrollTo(0, false)
    if animate then
        UI.FadeIn(page.scroll, 0.14)
    else
        page.scroll:Show()
        page.scroll:SetAlpha(1)
    end
    for index, entry in ipairs(TABS) do
        local button = tabButtons[index]
        local selected = entry.id == id
        button.text:SetTextColor(unpack(selected and C.text or C.muted))
        if selected then MoveUnderline(button, animate) end
    end
    ns.db.lastPage = id
end

local function FitTabPad()
    local textWidth = 0
    for _, button in ipairs(tabButtons) do textWidth = textWidth + math.ceil(button.text:GetStringWidth()) end
    local spaces = #tabButtons - 1
    local spare = WIDTH - MARGIN * 2 - textWidth - spaces * TAB_GAP
    return math.max(MIN_TAB_PAD, math.min(TAB_PAD, math.floor(spare / (spaces * 2))))
end

local function LayoutTabs()
    tabPad = FitTabPad()
    local x = -tabPad
    for _, button in ipairs(tabButtons) do
        button:SetWidth(math.ceil(button.text:GetStringWidth()) + tabPad * 2)
        button:ClearAllPoints()
        button:SetPoint("BOTTOMLEFT", x, 0)
        button.offset = x
        x = x + button:GetWidth() + TAB_GAP
    end
    if currentPage then
        for index, entry in ipairs(TABS) do
            if entry.id == currentPage.id then MoveUnderline(tabButtons[index], false) end
        end
    end
end

local function CreateTabs()
    local bar = CreateFrame("Frame", nil, window)
    bar:SetPoint("TOPLEFT", MARGIN, -HEADER_HEIGHT)
    bar:SetPoint("TOPRIGHT", -MARGIN, -HEADER_HEIGHT)
    bar:SetHeight(TABS_HEIGHT)
    window.tabBar = bar
    local baseline = bar:CreateTexture(nil, "BACKGROUND")
    baseline:SetColorTexture(1, 1, 1, 0.05)
    baseline:SetHeight(1)
    baseline:SetPoint("BOTTOMLEFT")
    baseline:SetPoint("BOTTOMRIGHT")
    local line = bar:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(unpack(C.accent))
    line:SetHeight(2)
    window.tabUnderline = line

    for index, entry in ipairs(TABS) do
        local button = CreateFrame("Button", nil, bar)
        button:SetHeight(TABS_HEIGHT)
        button.text = UI.Text(button, T.body, C.muted)
        button.text:SetPoint("CENTER", 0, 1)
        W.Bind(button.text, entry.key)
        button:SetScript("OnClick", function() ShowPage(entry.id, true) end)
        button:SetScript("OnEnter", function(self) self.text:SetTextColor(unpack(C.text)) end)
        button:SetScript("OnLeave", function(self)
            if currentPage ~= pages[entry.id] then self.text:SetTextColor(unpack(C.muted)) end
        end)
        tabButtons[index] = button
    end
    LayoutTabs()
    W.AfterLocale(LayoutTabs)
end

local function CreatePreviewToggle(header)
    local toggle = CreateFrame("Button", nil, header)
    toggle:SetHeight(24)
    local switch = W.CreateSwitch(toggle)
    switch:SetPoint("RIGHT")
    local label = UI.Text(toggle, T.label, C.muted)
    label:SetPoint("RIGHT", switch, "LEFT", -8, 0)
    W.Bind(label, "PREVIEW")
    local function Fit() toggle:SetWidth(label:GetStringWidth() + 8 + 26) end
    Fit()
    W.OnLocale(Fit)
    toggle:SetScript("OnClick", function()
        previewStartedHere = not ns.TestMode.active
        ns.TestMode.Toggle()
    end)
    toggle:SetScript("OnEnter", function(self)
        label:SetTextColor(unpack(C.text))
        W.SetSwitchHover(switch, true)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L.PREVIEW_DESC, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    toggle:SetScript("OnLeave", function()
        label:SetTextColor(unpack(C.muted))
        W.SetSwitchHover(switch, false)
        GameTooltip:Hide()
    end)
    ns.Listen("TEST_MODE_CHANGED", function(active) W.SetSwitch(switch, active, true) end)
    W.SetSwitch(switch, ns.TestMode.active, false)
    return toggle
end

local function CreateHeader()
    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(HEADER_HEIGHT)
    header:EnableMouse(true)
    W.DragHandle(header, function() window:StartMoving() end, function() window:StopMovingOrSizing() end)

    local glyph = UI.AddonGlyph(header, HEADER_GLYPH_HEIGHT)
    glyph:SetPoint("LEFT", MARGIN, -2)
    local title = UI.BoldText(header, T.title, C.text)
    title:SetPoint("LEFT", glyph, "RIGHT", HEADER_GLYPH_GAP, 0)
    title:SetText(ns.TITLE)
    local version = UI.Text(header, T.caption, C.faint)
    version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 6, 0)
    version:SetText(ns.VERSION)

    local close = CreateFrame("Button", nil, header)
    close:SetSize(24, 24)
    close:SetPoint("RIGHT", -MARGIN + 6, -2)
    local cross = UI.Text(close, 18, C.muted)
    cross:SetPoint("CENTER", 0, 1)
    cross:SetText("×")
    close:SetScript("OnClick", Options.Close)
    close:SetScript("OnEnter", function() cross:SetTextColor(unpack(C.text)) end)
    close:SetScript("OnLeave", function() cross:SetTextColor(unpack(C.muted)) end)

    local preview = CreatePreviewToggle(header)
    preview:SetPoint("RIGHT", close, "LEFT", -12, 0)
end

local function CreateAnimations()
    local open = window:CreateAnimationGroup()
    local fadeIn = open:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.16)
    fadeIn:SetSmoothing("OUT")
    local grow = open:CreateAnimation("Scale")
    grow:SetScaleFrom(0.97, 0.97)
    grow:SetScaleTo(1, 1)
    grow:SetDuration(0.18)
    grow:SetSmoothing("OUT")
    window.openAnimation = open

    local close = window:CreateAnimationGroup()
    local fadeOut = close:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.12)
    fadeOut:SetSmoothing("IN")
    close:SetScript("OnFinished", function() window:Hide() end)
    window.closeAnimation = close
end

local function CreateWindow()
    window = CreateFrame("Frame", "ReReagentOptionsFrame", UIParent)
    window:SetSize(WIDTH, HEIGHT)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetToplevel(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:Hide()
    UI.Fill(window, C.window)
    tinsert(UISpecialFrames, window:GetName())

    CreateHeader()
    CreateTabs()

    local body = CreateFrame("Frame", nil, window)
    body:SetPoint("TOPLEFT", MARGIN - CONTENT_INSET, -HEADER_HEIGHT - TABS_HEIGHT - BODY_GAP)
    body:SetPoint("BOTTOMRIGHT", -MARGIN + CONTENT_INSET, MARGIN)
    window.body = body

    CreateAnimations()
    window:SetScript("OnHide", function()
        if previewStartedHere then
            ns.TestMode.Stop()
            previewStartedHere = false
        end
        ns.Fire("OPTIONS_SHOWN", false)
    end)
end

function Options.IsOpen()
    return window ~= nil and window:IsShown()
end

function Options.Open(pageId)
    if not window then CreateWindow() end
    window.closeAnimation:Stop()
    if not window:IsShown() then
        window:Show()
        window.openAnimation:Restart()
        ns.Fire("OPTIONS_SHOWN", true)
    end
    ShowPage(pageId or currentPage and currentPage.id or ns.db.lastPage or DEFAULT_PAGE, false)
end

function Options.Close()
    if not window or not window:IsShown() then return end
    window.openAnimation:Stop()
    window.closeAnimation:Restart()
end

function Options.Toggle(pageId)
    if window and window:IsShown() and (not pageId or currentPage == pages[pageId]) then
        Options.Close()
    else
        Options.Open(pageId)
    end
end

ns.Listen("SETTING_CHANGED", function()
    if window and window:IsShown() and currentPage then
        RefreshPage(currentPage, true)
    end
end)

local function RegisterSettingsCategory()
    if not (Settings and Settings.RegisterCanvasLayoutCategory) then return end
    local panel = CreateFrame("Frame")
    panel:Hide()
    local glyph = UI.AddonGlyph(panel, SETTINGS_GLYPH_HEIGHT)
    glyph:SetPoint("TOPLEFT", 16, -16)
    local title = UI.Text(panel, 20, C.text)
    title:SetPoint("LEFT", glyph, "RIGHT", HEADER_GLYPH_GAP, 0)
    title:SetText(ns.TITLE)
    local desc = UI.Text(panel, T.body, C.muted)
    desc:SetPoint("TOPLEFT", glyph, "BOTTOMLEFT", 0, -10)
    W.Bind(desc, "SETTINGS_DESC")
    local open = W.Button(panel, "SETTINGS_OPEN", function() Options.Open() end, "primary")
    open:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    local category = Settings.RegisterCanvasLayoutCategory(panel, ns.TITLE)
    Settings.RegisterAddOnCategory(category)
end

ns.Listen("LOGIN", RegisterSettingsCategory)
