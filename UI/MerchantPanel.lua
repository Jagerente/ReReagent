local _, ns = ...

local L = ns.L
local C = ns.UI.COLORS
local Merchant = ns.Merchant
local Catalog = ns.Catalog
local SidePanel = ns.SidePanel

local Money = SidePanel.Money
local HOSTS = { "MerchantFrame" }

local panel

local function RowItem(entry)
    return entry.item
end

local function Detail(entry)
    local status = entry.status
    if status == Merchant.BUYING then return L.AH_BUYING, C.accent end
    if status == Merchant.POOR then return L.AH_POOR, C.bad end
    if status == Merchant.PARTIAL then
        if entry.short then return string.format(L.VENDOR_AFFORD, entry.quantity), C.warn end
        return string.format(L.VENDOR_LIMITED, entry.quantity), C.warn
    end
    return SidePanel.Stock(entry), C.muted
end

local function CreateRow(owner)
    return SidePanel.NewRow(owner, Merchant.Buy, RowItem)
end

local function PaintRow(row)
    local entry = row.entry
    local reagent = entry.reagent
    row.icon:SetTexture(Catalog.Icon(reagent))
    row.name:SetText(Catalog.Name(reagent))
    local text, color = Detail(entry)
    row.detail:SetText(text)
    row.detail:SetTextColor(unpack(color))
    local buyable = entry.status == Merchant.READY or entry.status == Merchant.PARTIAL
    row.price:SetShown(buyable)
    if buyable then row.price:SetText(Money(entry.cost)) end
    row.button.text:SetText(string.format(L.AH_BUY, math.max(entry.quantity, 0)))
    SidePanel.SetEnabled(row.button, buyable and not Merchant.buying)
end

local function Paint()
    panel.subtitle:SetText(L.VENDOR_SUBTITLE)
    panel:PaintRows(Merchant.entries, CreateRow, PaintRow)
    panel.footerText:SetText(string.format(L.AH_TOTAL, Money(Merchant.Total())))
    panel.footerText:SetShown(#Merchant.entries > 0)
    panel:SetAction(Merchant.buying and L.AH_BUYING or L.VENDOR_BUY_ALL, Merchant.HasPurchase() and not Merchant.buying)
end

local function Create()
    panel = SidePanel.Create("ReReagentMerchantPanel", {
        title = "VENDOR_TITLE",
        empty = "VENDOR_EMPTY",
        onAction = function() Merchant.BuyAll() end,
        actionHint = "VENDOR_BUY_ALL_DESC",
        toggles = {
            { key = "merchantAuto", label = "VENDOR_AUTO", desc = "VENDOR_AUTO_DESC" },
            { key = "countBank", label = "COUNT_BANK", desc = "COUNT_BANK_DESC" },
        },
        hosts = HOSTS,
        slot = "merchant",
        offset = { x = "merchantX", y = "merchantY" },
        settingsPage = "vendor",
    })
end

ns.Listen("MERCHANT_SHOWN", function(open)
    if not open then
        if panel then panel:Hide() end
        return
    end
    if not panel then Create() end
    Paint()
    panel:Open()
end)

local function RepaintIfShown()
    if panel and panel:IsShown() then Paint() end
end

ns.Listen("MERCHANT_CHANGED", RepaintIfShown)
ns.Listen("LOCALE_CHANGED", RepaintIfShown)
ns.Listen("NAMES_CHANGED", RepaintIfShown)
