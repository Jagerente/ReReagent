local _, ns = ...

local IsSpellKnown = C_SpellBook.IsSpellKnown

local Catalog = { families = {}, byItem = {}, listed = {}, tracked = {}, level = 1 }
ns.Catalog = Catalog

local NAME_DELAY = 0.2
local SPELLS_DELAY = 0.5

local families, byItem = Catalog.families, Catalog.byItem
local reagents = {}
local listed, tracked = Catalog.listed, Catalog.tracked
local nextListed, nextTracked = {}, {}

local function AddReagent(item, rank)
    local entry = byItem[item]
    if not entry then
        entry = { item = item, stock = ns.REAGENT_ITEMS[item].stock, ranks = {}, wanted = {} }
        byItem[item] = entry
        reagents[#reagents + 1] = entry
    end
    entry.ranks[#entry.ranks + 1] = rank
end

local function Build(class)
    for index, ranks in ipairs(ns.REAGENT_SPELLS[class] or {}) do
        local family = { ranks = ranks }
        families[index] = family
        for number = #ranks, 1, -1 do
            local rank = ranks[number]
            rank.family, rank.number = family, number
            for _, reagent in ipairs(rank.reagents) do
                AddReagent(reagent.item, rank)
            end
        end
    end
end

local function IsKnown(rank)
    for _, spell in ipairs(rank.spells) do
        if IsSpellKnown(spell) then return true end
    end
    return false
end

local function IsAvailable(rank)
    if IsKnown(rank) then return true end
    return not ns.db.knownOnly and rank.level <= Catalog.level
end

local function MarkRanks(family)
    local top
    for number = #family.ranks, 1, -1 do
        local rank = family.ranks[number]
        rank.available = IsAvailable(rank)
        rank.top = false
        if rank.available and not top then
            top = rank
            rank.top = true
        end
    end
end

function Catalog.IsWanted(rank)
    return rank.available and (rank.top or ns.db.lowerRanks)
end

local function CollectWanted(entry)
    wipe(entry.wanted)
    entry.forTop = false
    for _, rank in ipairs(entry.ranks) do
        if Catalog.IsWanted(rank) then
            entry.wanted[#entry.wanted + 1] = rank
            if rank.top then entry.forTop = true end
        end
    end
    return #entry.wanted > 0
end

function Catalog.IsTracked(entry)
    return entry.listed and not ns.charDB.untracked[entry.item]
end

local function SameList(a, b)
    if #a ~= #b then return false end
    for index = 1, #a do
        if a[index] ~= b[index] then return false end
    end
    return true
end

local function Replace(target, source)
    wipe(target)
    for index = 1, #source do
        target[index] = source[index]
    end
end

local function Rebuild()
    if not ns.db then return end
    for _, family in ipairs(families) do
        MarkRanks(family)
    end
    wipe(nextListed)
    wipe(nextTracked)
    for _, entry in ipairs(reagents) do
        entry.listed = CollectWanted(entry)
        if entry.listed then nextListed[#nextListed + 1] = entry end
        if Catalog.IsTracked(entry) then nextTracked[#nextTracked + 1] = entry end
    end
    local changed = not SameList(listed, nextListed) or not SameList(tracked, nextTracked)
    Replace(listed, nextListed)
    Replace(tracked, nextTracked)
    if changed then ns.Fire("REAGENTS_CHANGED") end
    ns.Fire("RANKS_CHANGED")
end
Catalog.Rebuild = Rebuild

function Catalog.HasReagents()
    return #reagents > 0
end

function Catalog.SetTracked(entry, on)
    ns.charDB.untracked[entry.item] = not on or nil
    Rebuild()
end

function Catalog.StockTarget(entry)
    return ns.charDB.stocks[entry.item] or entry.stock
end

function Catalog.SetStockTarget(entry, value)
    if value == Catalog.StockTarget(entry) then return end
    ns.charDB.stocks[entry.item] = value ~= entry.stock and value or nil
    ns.Fire("STOCK_CHANGED")
end

function Catalog.Name(entry)
    return C_Item.GetItemNameByID(entry.item) or string.format(ns.L.ITEM_LOADING, entry.item)
end

function Catalog.Icon(entry)
    return C_Item.GetItemIconByID(entry.item)
end

function Catalog.RankName(rank)
    local name = C_Spell.GetSpellName(rank.spells[1]) or tostring(rank.spells[1])
    if #rank.family.ranks < 2 then return name end
    return string.format(ns.L.SPELL_RANK, name, rank.number)
end

function Catalog.UsedBy(entry, ranks)
    local names = {}
    for index, rank in ipairs(ranks or entry.wanted) do
        names[index] = Catalog.RankName(rank)
    end
    return table.concat(names, ", ")
end

local function OnItemLoaded(item)
    if not byItem[item] then return end
    ns.Schedule("names", NAME_DELAY, function() ns.Fire("NAMES_CHANGED") end)
end

local function OnSpellsChanged()
    ns.Schedule("spells", SPELLS_DELAY, Rebuild)
end

local function OnLevelUp(level)
    Catalog.level = level
    Rebuild()
end

ns.Listen("SETTING_CHANGED", function(key)
    if key == nil or key == "knownOnly" or key == "lowerRanks" then Rebuild() end
end)

ns.Listen("LOGIN", function()
    local _, class = UnitClass("player")
    Build(class)
    Catalog.level = UnitLevel("player")
    ns.RegisterEvent("SPELLS_CHANGED", OnSpellsChanged)
    ns.RegisterEvent("PLAYER_LEVEL_UP", OnLevelUp)
    ns.RegisterEvent("ITEM_DATA_LOAD_RESULT", OnItemLoaded)
    for item in pairs(byItem) do
        C_Item.RequestLoadItemDataByID(item)
    end
    Rebuild()
end)
