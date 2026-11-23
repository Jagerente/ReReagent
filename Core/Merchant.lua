local _, ns = ...

local Catalog = ns.Catalog
local Inventory = ns.Inventory

local Merchant = { open = false, sells = false, entries = {}, buying = false }
ns.Merchant = Merchant

Merchant.READY = "ready"
Merchant.PARTIAL = "partial"
Merchant.POOR = "poor"
Merchant.BUYING = "buying"

local OPEN_DELAY = 0.3
local STEP_TIMEOUT = 3
local UNLIMITED = -1

local entries = Merchant.entries
local pool = {}
local goods = {}
local job
local stepTimer
local windowOpen = false
local buyOnOpen = false

local function Changed()
    ns.Fire("MERCHANT_CHANGED")
end

local function CancelTimer()
    if stepTimer then stepTimer:Cancel() end
    stepTimer = nil
end

local function ReadGoods()
    wipe(goods)
    for index = 1, GetMerchantNumItems() do
        local item = GetMerchantItemID(index)
        local info = item and Catalog.byItem[item] and C_MerchantFrame.GetItemInfo(index)
        if info and info.isPurchasable ~= false and not info.hasExtendedCost and info.numAvailable ~= 0 then
            goods[item] = {
                index = index,
                price = info.price or 0,
                step = math.max(info.stackCount or 1, 1),
                available = info.numAvailable or UNLIMITED,
            }
        end
    end
end

local function Purchase(entry, need)
    local good = entry.good
    local steps = math.ceil(need / good.step)
    if good.available ~= UNLIMITED then steps = math.min(steps, good.available) end
    local affordable = good.price > 0 and math.floor(GetMoney() / good.price) or steps
    entry.short = affordable < steps
    steps = math.min(steps, affordable)
    entry.quantity = steps * good.step
    entry.cost = steps * good.price
end

local function Settle(entry)
    if job and job.entry == entry then
        entry.status = Merchant.BUYING
    elseif entry.quantity == 0 then
        entry.status = Merchant.POOR
    elseif entry.short or entry.quantity < entry.need then
        entry.status = Merchant.PARTIAL
    else
        entry.status = Merchant.READY
    end
end

local function MakeEntry(reagent, good)
    local stock = Inventory.Stock(reagent)
    local entry = pool[reagent.item] or {}
    pool[reagent.item] = entry
    entry.reagent, entry.item, entry.good = reagent, reagent.item, good
    entry.need, entry.have, entry.bank, entry.target = stock.need, stock.have, stock.bank, stock.target
    Purchase(entry, math.max(stock.need, 0))
    Settle(entry)
    return entry
end

local function Rebuild()
    wipe(entries)
    Merchant.sells = false
    for _, reagent in ipairs(Catalog.tracked) do
        local good = goods[reagent.item]
        if good and Catalog.StockTarget(reagent) > 0 then
            Merchant.sells = true
            local entry = MakeEntry(reagent, good)
            if entry.need > 0 then entries[#entries + 1] = entry end
        end
    end
end

local function Refresh()
    ReadGoods()
    Rebuild()
    Changed()
end

local function Buyable(entry)
    return entry.status == Merchant.READY or entry.status == Merchant.PARTIAL
end

local Step

local function Finish()
    CancelTimer()
    job = nil
    Merchant.buying = false
    Inventory.Recount()
    Refresh()
end

local function NextEntry()
    local entry = table.remove(job.queue, 1)
    if not entry then return Finish() end
    local good = entry.good
    local count = C_Item.GetItemCount(entry.item)
    local maxStack = GetMerchantItemMaxStack(good.index) or good.step
    job.entry, job.item, job.index = entry, entry.item, good.index
    job.target, job.step = entry.quantity, good.step
    job.chunk = math.max(math.floor(maxStack / good.step) * good.step, good.step)
    job.base, job.last, job.issued = count, count, 0
    entry.status = Merchant.BUYING
    Changed()
    Step()
end

local function ArmTimeout()
    CancelTimer()
    stepTimer = C_Timer.NewTimer(STEP_TIMEOUT, Finish)
end

function Step()
    if not job or not Merchant.open then return Finish() end
    if not job.entry then return NextEntry() end
    local count = C_Item.GetItemCount(job.item)
    if count < job.last then return Finish() end
    job.last = count
    local got = count - job.base
    if got < job.issued then return end
    if got >= job.target then
        job.entry = nil
        return NextEntry()
    end
    local amount = math.floor(math.min(job.chunk, job.target - got) / job.step) * job.step
    if amount <= 0 or GetMerchantItemID(job.index) ~= job.item then return Finish() end
    job.issued = got + amount
    ArmTimeout()
    BuyMerchantItem(job.index, amount)
end

local function Start(list)
    if job or not Merchant.open then return end
    local queue = {}
    for _, entry in ipairs(list) do
        if Buyable(entry) then queue[#queue + 1] = entry end
    end
    if #queue == 0 then return end
    job = { queue = queue }
    Merchant.buying = true
    NextEntry()
end

function Merchant.Buy(entry)
    Start({ entry })
end

function Merchant.BuyAll()
    Start(entries)
end

function Merchant.Total()
    local cost = 0
    for _, entry in ipairs(entries) do
        if Buyable(entry) then cost = cost + entry.cost end
    end
    return cost
end

function Merchant.HasPurchase()
    for _, entry in ipairs(entries) do
        if Buyable(entry) then return true end
    end
    return false
end

local function ShowPanel(runAuto)
    Merchant.open = true
    buyOnOpen = buyOnOpen or runAuto
    ns.Schedule("merchantOpen", OPEN_DELAY, function()
        local buy = buyOnOpen
        buyOnOpen = false
        if not Merchant.open then return end
        Inventory.Recount()
        Refresh()
        if not Merchant.sells then return end
        ns.Fire("MERCHANT_SHOWN", true)
        if buy and ns.db.merchantAuto then Merchant.BuyAll() end
    end)
end

local function HidePanel()
    if not Merchant.open then return end
    Merchant.open = false
    CancelTimer()
    job = nil
    Merchant.buying = false
    wipe(entries)
    ns.Fire("MERCHANT_SHOWN", false)
end

local function OnShow()
    windowOpen = true
    if ns.db.merchant then ShowPanel(true) end
end

local function OnClosed()
    windowOpen = false
    buyOnOpen = false
    HidePanel()
end

local function SyncPanel()
    if not ns.db.merchant then
        HidePanel()
    elseif windowOpen and not Merchant.open then
        ShowPanel(false)
    end
end

local function RefreshIfIdle()
    if not Merchant.open or job then return end
    Refresh()
end

local function OnBagUpdate()
    if job then Step() end
end

ns.Listen("INVENTORY_CHANGED", RefreshIfIdle)
ns.Listen("REAGENTS_CHANGED", RefreshIfIdle)
ns.Listen("STOCK_CHANGED", RefreshIfIdle)
ns.Listen("SETTING_CHANGED", function(key)
    if key == nil or key == "merchant" then SyncPanel() end
    RefreshIfIdle()
end)

ns.Listen("LOGIN", function()
    ns.RegisterEvent("MERCHANT_SHOW", OnShow)
    ns.RegisterEvent("MERCHANT_CLOSED", OnClosed)
    ns.RegisterEvent("MERCHANT_UPDATE", RefreshIfIdle)
    ns.RegisterEvent("PLAYER_MONEY", RefreshIfIdle)
    ns.RegisterEvent("BAG_UPDATE_DELAYED", OnBagUpdate)
end)
