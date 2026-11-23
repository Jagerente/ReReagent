local _, ns = ...

local UI = ns.UI
local L = ns.L
local C = UI.COLORS
local T = UI.TEXT
local W = ns.Widgets
local Catalog = ns.Catalog
local Inventory = ns.Inventory

local Bar = { buttons = {} }
ns.Bar = Bar

local TIP_GLYPH_HEIGHT = 14
local TIP_GLYPH = UI.InlineGlyph(TIP_GLYPH_HEIGHT)
local TIP_GAP = " "
local PAD = 4
local HEADER_HEIGHT, HEADER_GAP = 14, 5
local HEADER_GLYPH_HEIGHT, HEADER_GLYPH_GAP = 11, 5
local BORDER = 1
local ICON_CROP = 0.08
local PRESS_INSET = 1
local LABEL_INSET = 3
local SCRIM_ALPHA = 0.85
local HOVER_ALPHA, HOVER_TIME = 0.14, 0.12
local EMPTY_ALPHA = 0.45
local SHOW_TIME = 0.18
local BACKGROUND = { 0.078, 0.076, 0.072 }
local PERCENT = 100
local ICON_BACK = { 0, 0, 0, 0.7 }
local STRATA = "MEDIUM"

local holder, bar, header, glyph, title
local buttons = Bar.buttons
local visible = {}
local barFade = {}
local moving = false
local inCombat = false

local function CountColor(entry, have, fullColor)
    if have == 0 then return C.bad end
    if have < Catalog.StockTarget(entry) then return C.warn end
    return fullColor or C.text
end

local function AddLine(text, color)
    GameTooltip:AddLine(text, color[1], color[2], color[3], true)
end

local function AddRow(left, right, leftColor, rightColor)
    GameTooltip:AddDoubleLine(left, right, leftColor[1], leftColor[2], leftColor[3], rightColor[1], rightColor[2], rightColor[3])
end

local function AddGap()
    GameTooltip:AddLine(TIP_GAP)
end

local function AddStockLines(entry)
    local stock = Inventory.Stock(entry)
    local count = UI.Colored(stock.have, CountColor(entry, stock.have, C.good))
    AddRow(L.TIP_STOCK, string.format(L.TIP_STOCK_VALUE, count, stock.target), C.muted, C.muted)
    if stock.bank > 0 then AddRow(L.TIP_IN_BANK, stock.bank, C.muted, C.text) end
end

local function AddSpellLines(entry)
    AddLine(string.format(L.TIP_USED_BY, UI.Colored(Catalog.UsedBy(entry), C.text)), C.muted)
    if not entry.forTop then AddLine(L.TIP_LOWER_ONLY, C.faint) end
end

local function AddHintLines()
    AddGap()
    if not ns.db.locked then AddRow(L.TIP_DRAG, L.TIP_MOVE, C.accent, C.text) end
    AddRow(L.TIP_RIGHT_CLICK, L.TIP_SETTINGS, C.accent, C.text)
end

local function ShowTooltip(button)
    local entry = button.entry
    GameTooltip:SetOwner(button, UI.VerticalAnchor(button))
    GameTooltip:SetItemByID(entry.item)
    AddGap()
    AddLine(TIP_GLYPH .. " " .. ns.TITLE, C.accent)
    AddStockLines(entry)
    AddSpellLines(entry)
    AddHintLines()
    GameTooltip:Show()
end

local function PaintButton(button)
    local entry = button.entry
    local have = Inventory.Count(entry.item)
    button.icon:SetTexture(Catalog.Icon(entry))
    button.icon:SetDesaturated(have == 0)
    button.art:SetAlpha(have == 0 and EMPTY_ALPHA or 1)
    local shown = ns.db.showCounts
    button.count:SetShown(shown)
    button.scrim:SetShown(shown)
    if not shown then return end
    button.count:SetText(have)
    button.count:SetTextColor(unpack(CountColor(entry, have)))
end

local function Paint()
    for _, button in ipairs(visible) do
        PaintButton(button)
    end
end

local function Highlight(button, on)
    UI.Tween(button.hover, on and HOVER_ALPHA or 0, HOVER_TIME, function(_, value) button.highlight:SetAlpha(value) end)
end

local function SavePosition()
    local point, _, _, x, y = holder:GetPoint(1)
    local position = ns.db.position
    position.point, position.x, position.y = point, x, y
end

function Bar.ResetPosition()
    local current, default = ns.db.position, ns.DEFAULTS.position
    current.point, current.x, current.y = default.point, default.x, default.y
    ns.Fire("SETTING_CHANGED", "position")
end

local function StartMoving()
    if ns.db.locked then return false end
    moving = true
    holder:Raise()
    holder:StartMoving()
end

local function StopMoving()
    if not moving then return end
    moving = false
    holder:StopMovingOrSizing()
    SavePosition()
end

local function OnMouseUp(_, mouseButton)
    if mouseButton == "RightButton" then
        ns.Options.Toggle("reagents")
    elseif mouseButton == "MiddleButton" and not ns.db.locked then
        Bar.ResetPosition()
    end
end

local function CreateArt(button)
    button.art = CreateFrame("Frame", nil, button)
    button.art:SetAllPoints()
    UI.Fill(button.art, ICON_BACK)
    button.icon = button.art:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", BORDER, -BORDER)
    button.icon:SetPoint("BOTTOMRIGHT", -BORDER, BORDER)
    button.icon:SetTexCoord(ICON_CROP, 1 - ICON_CROP, ICON_CROP, 1 - ICON_CROP)

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints()
    button.highlight = UI.Fill(overlay, { 1, 1, 1, 1 }, "ARTWORK")
    button.highlight:SetPoint("TOPLEFT", BORDER, -BORDER)
    button.highlight:SetPoint("BOTTOMRIGHT", -BORDER, BORDER)
    button.highlight:SetAlpha(0)
    button.hover = {}

    button.scrim = overlay:CreateTexture(nil, "BACKGROUND")
    button.scrim:SetColorTexture(1, 1, 1, 1)
    button.scrim:SetGradient("VERTICAL", CreateColor(0, 0, 0, SCRIM_ALPHA), CreateColor(0, 0, 0, 0))
    button.scrim:SetPoint("TOPLEFT", button, "LEFT", BORDER, 0)
    button.scrim:SetPoint("BOTTOMRIGHT", -BORDER, BORDER)
    button.count = UI.BoldText(overlay, T.body, C.text)
    button.count:SetPoint("BOTTOMRIGHT", -LABEL_INSET, LABEL_INSET - 1)
end

local function SetPressed(button, pressed)
    local inset = BORDER + (pressed and PRESS_INSET or 0)
    button.art:SetPoint("TOPLEFT", inset - BORDER, BORDER - inset)
    button.art:SetPoint("BOTTOMRIGHT", BORDER - inset, inset - BORDER)
end

local function CreateButton()
    local button = CreateFrame("Button", nil, bar)
    button.UpdateTooltip = ShowTooltip
    button:RegisterForClicks("AnyUp")
    button:Hide()
    CreateArt(button)
    button:SetScript("OnMouseUp", OnMouseUp)
    W.DragHandle(button, StartMoving, StopMoving)
    button:SetScript("OnEnter", function(self)
        Highlight(self, true)
        ShowTooltip(self)
    end)
    button:SetScript("OnLeave", function(self)
        Highlight(self, false)
        if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    end)
    button:HookScript("OnMouseDown", function(self) SetPressed(self, true) end)
    button:HookScript("OnMouseUp", function(self) SetPressed(self, false) end)
    button:HookScript("OnHide", function(self) SetPressed(self, false) end)
    buttons[#buttons + 1] = button
    return button
end

local function CreateHeader()
    header = CreateFrame("Frame", nil, bar)
    header:SetHeight(HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", PAD, -PAD)
    header:SetPoint("TOPRIGHT", -PAD, -PAD)
    header:EnableMouse(true)
    glyph = UI.AddonGlyph(header, HEADER_GLYPH_HEIGHT)
    glyph:SetPoint("LEFT")
    title = UI.BoldText(header, T.label, C.text)
    title:SetPoint("LEFT", glyph, "RIGHT", HEADER_GLYPH_GAP, 0)
    header:SetScript("OnEnter", function(self)
        W.ShowHint(self, ns.db.locked and "HEADER_LOCKED_DESC" or "HEADER_DESC")
    end)
    header:SetScript("OnLeave", W.HideHint)
    header:SetScript("OnMouseUp", OnMouseUp)
    W.DragHandle(header, StartMoving, StopMoving)
end

local function HeaderWidth()
    return glyph:GetWidth() + HEADER_GLYPH_GAP + math.ceil(title:GetStringWidth())
end

local function FadeBarIn()
    barFade.tweenValue = 0
    bar:SetAlpha(0)
    UI.Tween(barFade, 1, SHOW_TIME, function(_, value) bar:SetAlpha(value) end)
end

local function PaintBackground()
    bar.background:SetAlpha(ns.db.barBackground / PERCENT)
end

local function Create()
    holder = CreateFrame("Frame", "ReReagentHolder", UIParent)
    holder:SetSize(1, 1)
    holder:SetMovable(true)
    holder:SetClampedToScreen(true)
    holder:SetFrameStrata(STRATA)
    holder:SetToplevel(true)
    holder:Hide()
    holder:HookScript("OnShow", FadeBarIn)

    bar = CreateFrame("Frame", "ReReagentBar", holder)
    bar:SetPoint("TOPLEFT", holder, "CENTER")
    bar.background = UI.Fill(bar, BACKGROUND)
    PaintBackground()
    CreateHeader()
end

local function PlaceHolder()
    local position = ns.db.position
    holder:ClearAllPoints()
    holder:SetPoint(position.point, UIParent, position.point, position.x, position.y)
end

local function WantsButton(entry)
    if ns.TestMode.active then return true end
    if ns.db.visibility == "short" and not Inventory.IsShort(entry) then return false end
    return ns.db.showEmpty or Inventory.Count(entry.item) > 0
end

local function PlaceButton(button, index, size, gap, top)
    local offset = (index - 1) * (size + gap)
    button:SetSize(size, size)
    button:ClearAllPoints()
    if ns.db.layout == "HORIZONTAL" then
        button:SetPoint("TOPLEFT", bar, "TOPLEFT", PAD + offset, -(PAD + top))
    else
        button:SetPoint("TOPLEFT", bar, "TOPLEFT", PAD, -(PAD + top + offset))
    end
    button:Show()
end

local function Layout()
    wipe(visible)
    for _, entry in ipairs(Catalog.tracked) do
        if WantsButton(entry) then
            local button = buttons[#visible + 1] or CreateButton()
            button.entry = entry
            visible[#visible + 1] = button
        end
    end
    for index = #visible + 1, #buttons do
        buttons[index].entry = nil
        buttons[index]:Hide()
    end
    local size, gap = ns.db.iconSize, ns.db.spacing
    local showHeader = ns.db.showHeader
    header:SetShown(showHeader)
    title:SetText(L.HEADER)
    local top = showHeader and HEADER_HEIGHT + HEADER_GAP or 0
    for index, button in ipairs(visible) do
        PlaceButton(button, index, size, gap, top)
    end
    local count = math.max(1, #visible)
    local along = count * size + (count - 1) * gap
    local horizontal = ns.db.layout == "HORIZONTAL"
    local width = horizontal and along or size
    local height = horizontal and size or along
    if showHeader then width = math.max(width, HeaderWidth()) end
    bar:SetSize(PAD * 2 + width, PAD * 2 + top + height)
end

local function WantsShown()
    if not ns.db.enabled or #visible == 0 then return false end
    if ns.TestMode.active or ns.Options.IsOpen() then return true end
    local visibility = ns.db.visibility
    if visibility == "never" then return false end
    if visibility == "combat" then return inCombat end
    return true
end

function Bar.Refresh()
    if not holder then return end
    Layout()
    holder:SetShown(WantsShown())
    Paint()
end

local function SetCombat(active)
    inCombat = active
    if not active then StopMoving() end
    Bar.Refresh()
end

ns.Listen("REAGENTS_CHANGED", Bar.Refresh)
ns.Listen("INVENTORY_CHANGED", Bar.Refresh)
ns.Listen("STOCK_CHANGED", Bar.Refresh)
ns.Listen("NAMES_CHANGED", Paint)
ns.Listen("TEST_MODE_CHANGED", Bar.Refresh)
ns.Listen("OPTIONS_SHOWN", Bar.Refresh)
ns.Listen("LOCALE_CHANGED", Bar.Refresh)
ns.Listen("SETTING_CHANGED", function(key)
    if not holder then return end
    if key == nil or key == "position" then PlaceHolder() end
    if key == nil or key == "barBackground" then PaintBackground() end
    Bar.Refresh()
end)

ns.Listen("LOGIN", function()
    Create()
    PlaceHolder()
    ns.RegisterEvent("PLAYER_REGEN_DISABLED", function() SetCombat(true) end)
    ns.RegisterEvent("PLAYER_REGEN_ENABLED", function() SetCombat(false) end)
    Bar.Refresh()
end)
