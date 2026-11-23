local _, ns = ...

local L = ns.L
local C = ns.UI.COLORS
local Bank = ns.Bank
local Catalog = ns.Catalog
local SidePanel = ns.SidePanel

local HOSTS = { "EUI_BankFrame", "BankFrame" }

local panel

local function CreateRow(owner)
    local row = SidePanel.NewRow(owner, Bank.Take)
    row.price:Hide()
    return row
end

local function PaintRow(row)
    local entry = row.entry
    row.icon:SetTexture(Catalog.Icon(entry.reagent))
    row.name:SetText(Catalog.Name(entry.reagent))
    if Bank.moving then
        row.detail:SetText(L.BANK_MOVING)
        row.detail:SetTextColor(unpack(C.accent))
    else
        row.detail:SetText(string.format(L.BANK_DETAIL, entry.bank, entry.have))
        row.detail:SetTextColor(unpack(C.muted))
    end
    row.button.text:SetText(string.format(L.BANK_TAKE, entry.take))
    SidePanel.SetEnabled(row.button, not Bank.moving)
end

local function Paint()
    panel.subtitle:SetText(L.BANK_SUBTITLE)
    panel:PaintRows(Bank.entries, CreateRow, PaintRow)
    if Bank.noSpace then
        panel.footerText:SetText(L.BANK_NO_SPACE)
        panel.footerText:SetTextColor(unpack(C.bad))
    else
        panel.footerText:SetText(string.format(L.BANK_FREE, Bank.FreeSlots()))
        panel.footerText:SetTextColor(unpack(C.muted))
    end
    panel:SetAction(Bank.moving and L.BANK_MOVING or L.BANK_TAKE_ALL, #Bank.entries > 0 and not Bank.moving)
end

local function Create()
    panel = SidePanel.Create("ReReagentBankPanel", {
        title = "BANK_TITLE",
        empty = "BANK_DONE",
        onAction = function() Bank.Take() end,
        toggles = { { key = "bankAuto", label = "BANK_AUTO" } },
        hosts = HOSTS,
        slot = "bank",
        offset = { x = "bankX", y = "bankY" },
        settingsPage = "bank",
    })
end

ns.Listen("BANK_SHOWN", function(open)
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

ns.Listen("BANK_CHANGED", RepaintIfShown)
ns.Listen("LOCALE_CHANGED", RepaintIfShown)
ns.Listen("NAMES_CHANGED", RepaintIfShown)
