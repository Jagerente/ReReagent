local _, ns = ...

local Catalog = ns.Catalog
local GetItemCount = C_Item.GetItemCount

local Inventory = { bags = {}, total = {} }
ns.Inventory = Inventory

local bags, total = Inventory.bags, Inventory.total

local function Recount()
    local changed = false
    for item in pairs(Catalog.byItem) do
        local inBags = GetItemCount(item, false) or 0
        local everywhere = GetItemCount(item, true, false, false, true) or inBags
        if bags[item] ~= inBags or total[item] ~= everywhere then
            bags[item], total[item] = inBags, everywhere
            changed = true
        end
    end
    if changed then ns.Fire("INVENTORY_CHANGED") end
end
Inventory.Recount = Recount

function Inventory.Count(item)
    return bags[item] or 0
end

function Inventory.BankCount(item)
    return math.max(0, (total[item] or 0) - (bags[item] or 0))
end

function Inventory.Stock(entry)
    local have, bank = Inventory.Count(entry.item), Inventory.BankCount(entry.item)
    local counted = ns.db.countBank and bank or 0
    local target = Catalog.StockTarget(entry)
    return { have = have, bank = bank, target = target, need = target - have - counted }
end

function Inventory.IsShort(entry)
    return Inventory.Count(entry.item) < Catalog.StockTarget(entry)
end

ns.Listen("LOGIN", function()
    ns.RegisterEvent("BAG_UPDATE_DELAYED", Recount)
    ns.RegisterEvent("PLAYER_ENTERING_WORLD", Recount)
    ns.RegisterEvent("BANKFRAME_CLOSED", Recount)
    Recount()
end)
