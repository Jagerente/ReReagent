local _, ns = ...

local L = {}
ns.L = L

local STRINGS = {}

STRINGS.enUS = {
    NAV_REAGENTS = "Reagents",
    NAV_PANEL = "Panel",
    NAV_VENDOR = "Vendor",
    NAV_BANK = "Bank",
    NAV_ABOUT = "About",

    PREVIEW = "Preview",
    PREVIEW_DESC = "Shows all the reagents you track, also the ones you have enough of.",

    ITEM_LOADING = "Item %d",
    SPELL_RANK = "%s (Rank %d)",

    TIP_STOCK = "Stock in bags",
    TIP_STOCK_VALUE = "%s of %d",
    TIP_IN_BANK = "In the bank",
    TIP_USED_BY = "Needed for %s",
    TIP_LOWER_ONLY = "Only lower ranks use it.",
    TIP_DRAG = "Drag",
    TIP_MOVE = "Move the panel",
    TIP_RIGHT_CLICK = "Right-click",
    TIP_SETTINGS = "Settings",

    KNOWN_ONLY = "Only spells you know",
    KNOWN_ONLY_DESC = "Turn it off to also list reagents for spells the trainer teaches at your level.",
    LOWER_RANKS = "Lower ranks too",
    LOWER_RANKS_DESC = "Also lists the reagents of your lower ranks: Maple Seed for Rebirth 1 next to Ironwood Seed for Rebirth 5.",
    NO_REAGENTS_CLASS = "Spells of your class don't use reagents.",
    NO_REAGENTS_KNOWN = "None of the spells you know use reagents yet. Turn off \"Only spells you know\" to see the ones the trainer teaches at your level.",
    LOWER_RANK_ONLY = "Lower ranks: %s",
    STOCK = "Keep in bags",
    STOCK_DESC = "The vendor and bank panels fill your bags up to this number. At 0 the reagent is only counted.",

    COUNT_BANK = "Count reagents in the bank",
    COUNT_BANK_DESC = "Reagents in the bank count toward the stock, so the vendor buys only what is missing.",
    COIN_GOLD = "g",
    COIN_SILVER = "s",
    COIN_COPPER = "c",

    AH_POOR = "Not enough gold",
    AH_BUYING = "Buying…",
    AH_HAVE = "%d of %d in bags",
    AH_HAVE_BANK = "%d of %d in bags, %d in the bank",
    AH_BUY = "Buy %d",
    AH_TOTAL = "Total %s",

    SECTION_VENDOR = "Vendor",
    VENDOR = "Shopping list at the vendor",
    VENDOR_DESC = "When a vendor sells your reagents, a panel next to the window lists what you are short of, with a button to buy it.",
    VENDOR_AUTO = "Buy right away",
    VENDOR_AUTO_DESC = "Buys the reagents on the list when the vendor window opens.",
    VENDOR_TITLE = "Restock reagents",
    VENDOR_SUBTITLE = "Up to the stock of each reagent",
    VENDOR_EMPTY = "You have the stock of all reagents this vendor sells. Change it on the Reagents tab in /reagents.",
    VENDOR_BUY_ALL = "Buy all",
    VENDOR_AFFORD = "You can pay for %d",
    VENDOR_LIMITED = "The vendor has %d",

    SECTION_BANK = "Bank",
    SECTION_PLACEMENT = "Panel position",
    DOCK_TARGET = "Attach the panel to",
    DOCK_AUTO = "Automatic",
    DOCK_HOST_bank = "The bank window",
    DOCK_HOST_merchant = "The vendor window",
    DOCK_OF_bank = "the bank window",
    DOCK_OF_merchant = "the vendor window",
    DOCK_SIDE = "Side",
    DOCK_SIDE_RIGHT = "Right",
    DOCK_SIDE_LEFT = "Left",
    DOCK_SIDE_BELOW = "Below",
    DOCK_SIDE_ABOVE = "Above",
    DOCK_NOW_RIGHT = "Now: right of %s",
    DOCK_NOW_LEFT = "Now: left of %s",
    DOCK_NOW_BELOW = "Now: below %s",
    DOCK_NOW_ABOVE = "Now: above %s",
    DOCK_TAKEN = "%s was set to this place later, so this panel moved next to it.",
    OFFSET_X = "Panel offset, horizontal",
    OFFSET_Y = "Panel offset, vertical",
    HEADER_DESC = "Drag to move the panel. Right-click opens or closes the settings, middle-click puts the panel back.",
    HEADER = "Reagents",
    HEADER_LOCKED_DESC = "The panel is locked. Right-click opens or closes the settings.",
    BANK = "Take reagents from the bank",
    BANK_DESC = "When you open the bank, a panel next to it lists the reagents your bags are short of, with a button to move them.",
    BANK_AUTO = "Take it right away",
    BANK_AUTO_DESC = "Moves the reagents into your bags when the bank opens.",
    BANK_TITLE = "Reagents in the bank",
    BANK_SUBTITLE = "Up to the stock in your bags",
    BANK_DETAIL = "%d in the bank, %d in bags",
    BANK_MOVING = "Moving…",
    BANK_TAKE = "Take %d",
    BANK_TAKE_ALL = "Take all",
    BANK_NO_SPACE = "No room in your bags",
    BANK_FREE = "Free bag slots: %d",
    BANK_DONE = "Your bags hold the stock of all reagents.",

    SECTION_WHEN = "When to show",
    VISIBILITY = "Show the panel",
    VISIBILITY_always = "Always",
    VISIBILITY_short = "When short",
    VISIBILITY_combat = "In combat",
    VISIBILITY_never = "Never",
    VISIBILITY_EXPLAIN = "\"When short\" shows only the reagents below the stock.",
    SHOW_EMPTY = "Show reagents you are out of",
    SHOW_EMPTY_DESC = "A reagent with nothing in your bags stays on the panel, dimmed with a red 0.",

    SECTION_LOOK = "Look",
    ICON_SIZE = "Icon size",
    SPACING = "Spacing",
    LAYOUT = "Icons go",
    LAYOUT_HORIZONTAL = "In a row",
    LAYOUT_VERTICAL = "In a column",
    SHOW_HEADER = "Title line",
    SHOW_HEADER_DESC = "A line above the icons. Drag it to move the panel.",
    SHOW_COUNTS = "Reagent count",
    SHOW_COUNTS_DESC = "How many you carry in your bags. Amber below the stock, red at 0.",
    LOCKED = "Lock the panel",
    LOCKED_DESC = "The panel can no longer be moved.",
    RECENTER = "Move the panel back",

    SECTION_BACKGROUND = "Background",
    BAR_BACKGROUND = "Panel with icons",
    PANEL_BACKGROUND = "Vendor and bank panels",

    SECTION_OTHER = "Other",
    MINIMAP_BUTTON = "Minimap button",
    MINIMAP_LEFT_CLICK = "Click: settings",
    MINIMAP_RIGHT_CLICK = "Right-click: preview",
    MINIMAP_DRAG = "Drag: move around the minimap",
    LANGUAGE = "Language",
    LANGUAGE_auto = "Game",
    LANGUAGE_enUS = "English",
    LANGUAGE_ruRU = "Русский",
    RESET = "Reset all settings",
    RESET_CONFIRM = "Click again to reset everything",

    SETTINGS_DESC = "Counts the reagents your class spells use and restocks them at the vendor and from the bank.",
    SETTINGS_OPEN = "Open settings",

    ABOUT_AUTHOR = "Author",
    ABOUT_SHAPESHIFT = "Click to shapeshift",
    ABOUT_WEBSITE = "Website",
    ABOUT_COPY = "Copy",
    ABOUT_COPY_HINT = "Press Ctrl+C",
    ABOUT_COMMAND = "Chat command",
    ABOUT_COMMAND_DESC = "Opens this window",
    ABOUT_FONT_CREDIT = "Fira Sans font, SIL Open Font License 1.1.",
}

STRINGS.ruRU = {
    NAV_REAGENTS = "Реагенты",
    NAV_PANEL = "Панель",
    NAV_VENDOR = "Торговец",
    NAV_BANK = "Банк",
    NAV_ABOUT = "Об аддоне",

    PREVIEW = "Превью",
    PREVIEW_DESC = "Показывает все отслеживаемые реагенты, в том числе те, которых хватает.",

    ITEM_LOADING = "Предмет %d",
    SPELL_RANK = "%s (ранг %d)",

    TIP_STOCK = "Запас в сумках",
    TIP_STOCK_VALUE = "%s из %d",
    TIP_IN_BANK = "В банке",
    TIP_USED_BY = "Нужен для: %s",
    TIP_LOWER_ONLY = "Нужен только младшим рангам.",
    TIP_DRAG = "Перетаскивание",
    TIP_MOVE = "Сдвинуть панель",
    TIP_RIGHT_CLICK = "ПКМ",
    TIP_SETTINGS = "Настройки",

    KNOWN_ONLY = "Только известные заклинания",
    KNOWN_ONLY_DESC = "Выключите, чтобы видеть ещё реагенты заклинаний, которые тренер учит на вашем уровне.",
    LOWER_RANKS = "И младшие ранги",
    LOWER_RANKS_DESC = "В списке будут и реагенты младших рангов: Maple Seed для Rebirth 1 рядом с Ironwood Seed для Rebirth 5.",
    NO_REAGENTS_CLASS = "Заклинаниям вашего класса реагенты не нужны.",
    NO_REAGENTS_KNOWN = "Известным вам заклинаниям реагенты пока не нужны. Выключите «Только известные заклинания», чтобы увидеть те, что тренер учит на вашем уровне.",
    LOWER_RANK_ONLY = "Младшие ранги: %s",
    STOCK = "Держать в сумках",
    STOCK_DESC = "Панели у торговца и банка пополняют сумки до этого числа. При 0 реагент только считается.",

    COUNT_BANK = "Учитывать реагенты в банке",
    COUNT_BANK_DESC = "Реагенты из банка входят в запас, и торговец докупает только недостающее.",
    COIN_GOLD = "з",
    COIN_SILVER = "с",
    COIN_COPPER = "м",

    AH_POOR = "Не хватает золота",
    AH_BUYING = "Покупаем…",
    AH_HAVE = "В сумках %d из %d",
    AH_HAVE_BANK = "В сумках %d из %d, в банке %d",
    AH_BUY = "Купить %d",
    AH_TOTAL = "Итого %s",

    SECTION_VENDOR = "Торговец",
    VENDOR = "Список покупок у торговца",
    VENDOR_DESC = "Когда торговец продаёт ваши реагенты, рядом с окном появляется панель с тем, чего меньше запаса, и кнопкой покупки.",
    VENDOR_AUTO = "Покупать сразу",
    VENDOR_AUTO_DESC = "Покупает реагенты из списка при открытии окна торговца.",
    VENDOR_TITLE = "Докупить реагенты",
    VENDOR_SUBTITLE = "До запаса каждого реагента",
    VENDOR_EMPTY = "Запас всех реагентов, что продаёт этот торговец, есть. Он меняется во вкладке «Реагенты» в /reagents.",
    VENDOR_BUY_ALL = "Купить всё",
    VENDOR_AFFORD = "Хватает денег на %d",
    VENDOR_LIMITED = "У торговца есть %d",

    SECTION_BANK = "Банк",
    SECTION_PLACEMENT = "Положение панели",
    DOCK_TARGET = "К чему прикрепить панель",
    DOCK_AUTO = "Автоматически",
    DOCK_HOST_bank = "Окно банка",
    DOCK_HOST_merchant = "Окно торговца",
    DOCK_OF_bank = "окна банка",
    DOCK_OF_merchant = "окна торговца",
    DOCK_SIDE = "С какой стороны",
    DOCK_SIDE_RIGHT = "Справа",
    DOCK_SIDE_LEFT = "Слева",
    DOCK_SIDE_BELOW = "Ниже",
    DOCK_SIDE_ABOVE = "Выше",
    DOCK_NOW_RIGHT = "Сейчас: справа от %s",
    DOCK_NOW_LEFT = "Сейчас: слева от %s",
    DOCK_NOW_BELOW = "Сейчас: ниже %s",
    DOCK_NOW_ABOVE = "Сейчас: выше %s",
    DOCK_TAKEN = "Это место позже занял %s, поэтому панель встала рядом с ним.",
    OFFSET_X = "Сдвиг панели по горизонтали",
    OFFSET_Y = "Сдвиг панели по вертикали",
    HEADER_DESC = "Перетащите, чтобы передвинуть панель. ПКМ открывает и закрывает настройки, клик колёсиком возвращает панель на место.",
    HEADER = "Реагенты",
    HEADER_LOCKED_DESC = "Панель закреплена. ПКМ открывает и закрывает настройки.",
    BANK = "Брать реагенты из банка",
    BANK_DESC = "Когда вы открываете банк, рядом появляется панель с реагентами, которых не хватает в сумках, и кнопкой переноса.",
    BANK_AUTO = "Забирать сразу",
    BANK_AUTO_DESC = "Переносит реагенты в сумки при открытии банка.",
    BANK_TITLE = "Реагенты в банке",
    BANK_SUBTITLE = "До запаса в сумках",
    BANK_DETAIL = "В банке %d, в сумках %d",
    BANK_MOVING = "Переносим…",
    BANK_TAKE = "Взять %d",
    BANK_TAKE_ALL = "Забрать всё",
    BANK_NO_SPACE = "Нет места в сумках",
    BANK_FREE = "Свободно в сумках: %d",
    BANK_DONE = "В сумках есть запас всех реагентов.",

    SECTION_WHEN = "Когда показывать",
    VISIBILITY = "Показывать панель",
    VISIBILITY_always = "Всегда",
    VISIBILITY_short = "Когда мало",
    VISIBILITY_combat = "В бою",
    VISIBILITY_never = "Никогда",
    VISIBILITY_EXPLAIN = "«Когда мало» показывает только реагенты ниже запаса.",
    SHOW_EMPTY = "Показывать закончившееся",
    SHOW_EMPTY_DESC = "Реагент, которого в сумках нет, остаётся на панели приглушённым с красным 0.",

    SECTION_LOOK = "Вид",
    ICON_SIZE = "Размер иконок",
    SPACING = "Отступ",
    LAYOUT = "Иконки идут",
    LAYOUT_HORIZONTAL = "В ряд",
    LAYOUT_VERTICAL = "В столбик",
    SHOW_HEADER = "Строка заголовка",
    SHOW_HEADER_DESC = "Строка над иконками. За неё панель перетаскивается.",
    SHOW_COUNTS = "Количество реагентов",
    SHOW_COUNTS_DESC = "Сколько реагента в сумках. Янтарным, если меньше запаса, красным при 0.",
    LOCKED = "Закрепить панель",
    LOCKED_DESC = "Панель больше нельзя передвинуть.",
    RECENTER = "Вернуть панель на место",

    SECTION_BACKGROUND = "Фон",
    BAR_BACKGROUND = "Панель с иконками",
    PANEL_BACKGROUND = "Панели у торговца и банка",

    SECTION_OTHER = "Прочее",
    MINIMAP_BUTTON = "Кнопка у миникарты",
    MINIMAP_LEFT_CLICK = "ЛКМ: настройки",
    MINIMAP_RIGHT_CLICK = "ПКМ: превью",
    MINIMAP_DRAG = "Перетащите, чтобы передвинуть",
    LANGUAGE = "Язык",
    LANGUAGE_auto = "Как в игре",
    LANGUAGE_enUS = "English",
    LANGUAGE_ruRU = "Русский",
    RESET = "Сбросить все настройки",
    RESET_CONFIRM = "Нажмите ещё раз, чтобы сбросить всё",

    SETTINGS_DESC = "Считает реагенты для заклинаний вашего класса и пополняет запас у торговца и из банка.",
    SETTINGS_OPEN = "Открыть настройки",

    ABOUT_AUTHOR = "Автор",
    ABOUT_SHAPESHIFT = "Нажмите, чтобы сменить облик",
    ABOUT_WEBSITE = "Сайт",
    ABOUT_COPY = "Копировать",
    ABOUT_COPY_HINT = "Нажмите Ctrl+C",
    ABOUT_COMMAND = "Команда в чате",
    ABOUT_COMMAND_DESC = "Открывает это окно",
    ABOUT_FONT_CREDIT = "Шрифт Fira Sans, лицензия SIL Open Font License 1.1.",
}

ns.LANGUAGES = { "auto", "enUS", "ruRU" }

local function Resolve(choice)
    if choice and STRINGS[choice] then return choice end
    local gameLocale = GetLocale()
    return STRINGS[gameLocale] and gameLocale or "enUS"
end

function ns.ApplyLanguage(choice)
    local code = Resolve(choice)
    wipe(L)
    for key, text in pairs(STRINGS.enUS) do
        L[key] = text
    end
    if code ~= "enUS" then
        for key, text in pairs(STRINGS[code]) do
            L[key] = text
        end
    end
    ns.Fire("LOCALE_CHANGED")
end

ns.ApplyLanguage("auto")

ns.Listen("DB_READY", function()
    ns.ApplyLanguage(ns.db.locale)
end)

ns.Listen("SETTING_CHANGED", function(key)
    if key == nil or key == "locale" then
        ns.ApplyLanguage(ns.db.locale)
    end
end)
