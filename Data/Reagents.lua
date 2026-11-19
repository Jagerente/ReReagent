local _, ns = ...

ns.REAGENT_SPELLS = {
    PALADIN = {
        {
            { spells = { 19752 }, level = 30, reagents = { { item = 17033, count = 1 } } },
        },
        {
            { spells = { 25898 }, level = 60, reagents = { { item = 21177, count = 1 } } },
        },
        {
            { spells = { 25782 }, level = 52, reagents = { { item = 21177, count = 1 } } },
            { spells = { 25916 }, level = 60, reagents = { { item = 21177, count = 1 } } },
        },
        {
            { spells = { 25894 }, level = 54, reagents = { { item = 21177, count = 1 } } },
            { spells = { 25918 }, level = 60, reagents = { { item = 21177, count = 1 } } },
        },
    },
    ROGUE = {
        {
            { spells = { 2094 }, level = 34, reagents = { { item = 5530, count = 1 } } },
        },
        {
            { spells = { 6510 }, level = 1, reagents = { { item = 3818, count = 1 } } },
        },
        {
            { spells = { 3420 }, level = 20, reagents = { { item = 2930, count = 1 }, { item = 3371, count = 1 } } },
            { spells = { 3421 }, level = 50, reagents = { { item = 8923, count = 3 }, { item = 8925, count = 1 } } },
        },
        {
            { spells = { 2835 }, level = 30, reagents = { { item = 5173, count = 1 }, { item = 3372, count = 1 } } },
            { spells = { 2837 }, level = 38, reagents = { { item = 5173, count = 2 }, { item = 3372, count = 1 } } },
            { spells = { 11357 }, level = 46, reagents = { { item = 5173, count = 3 }, { item = 8925, count = 1 } } },
            { spells = { 11358 }, level = 54, reagents = { { item = 5173, count = 5 }, { item = 8925, count = 1 } } },
            { spells = { 25347 }, level = 60, reagents = { { item = 5173, count = 7 }, { item = 8925, count = 1 } } },
        },
        {
            { spells = { 8681 }, level = 20, reagents = { { item = 2928, count = 1 }, { item = 3371, count = 1 } } },
            { spells = { 8687 }, level = 28, reagents = { { item = 2928, count = 3 }, { item = 3372, count = 1 } } },
            { spells = { 8691 }, level = 36, reagents = { { item = 8924, count = 1 }, { item = 3372, count = 1 } } },
            { spells = { 11341 }, level = 44, reagents = { { item = 8924, count = 2 }, { item = 8925, count = 1 } } },
            { spells = { 11342 }, level = 52, reagents = { { item = 8924, count = 3 }, { item = 8925, count = 1 } } },
            { spells = { 11343 }, level = 60, reagents = { { item = 8924, count = 4 }, { item = 8925, count = 1 } } },
        },
        {
            { spells = { 5763 }, level = 24, reagents = { { item = 2928, count = 1 }, { item = 2930, count = 1 }, { item = 3371, count = 1 } } },
            { spells = { 8694 }, level = 38, reagents = { { item = 2928, count = 4 }, { item = 2930, count = 4 }, { item = 3372, count = 1 } } },
            { spells = { 11400 }, level = 52, reagents = { { item = 8924, count = 2 }, { item = 8923, count = 2 }, { item = 8925, count = 1 } } },
        },
        {
            { spells = { 1856 }, level = 22, reagents = { { item = 5140, count = 1 } } },
            { spells = { 1857 }, level = 42, reagents = { { item = 5140, count = 1 } } },
        },
        {
            { spells = { 13220 }, level = 32, reagents = { { item = 2930, count = 1 }, { item = 5173, count = 1 }, { item = 3372, count = 1 } } },
            { spells = { 13228 }, level = 40, reagents = { { item = 2930, count = 1 }, { item = 5173, count = 2 }, { item = 3372, count = 1 } } },
            { spells = { 13229 }, level = 48, reagents = { { item = 8923, count = 1 }, { item = 5173, count = 2 }, { item = 8925, count = 1 } } },
            { spells = { 13230 }, level = 56, reagents = { { item = 8923, count = 2 }, { item = 5173, count = 2 }, { item = 8925, count = 1 } } },
        },
    },
    PRIEST = {
        {
            { spells = { 1706 }, level = 34, reagents = { { item = 17056, count = 1 } } },
        },
        {
            { spells = { 21562 }, level = 48, reagents = { { item = 17028, count = 1 } } },
            { spells = { 21564 }, level = 60, reagents = { { item = 17029, count = 1 } } },
        },
        {
            { spells = { 27683 }, level = 56, reagents = { { item = 17029, count = 1 } } },
        },
        {
            { spells = { 27681 }, level = 60, reagents = { { item = 17029, count = 1 } } },
        },
    },
    SHAMAN = {
        {
            { spells = { 20608, 21169 }, level = 30, reagents = { { item = 17030, count = 1 } } },
        },
        {
            { spells = { 131 }, level = 1, reagents = { { item = 17057, count = 1 } } },
        },
        {
            { spells = { 546 }, level = 1, reagents = { { item = 17058, count = 1 } } },
        },
    },
    MAGE = {
        {
            { spells = { 23028 }, level = 56, reagents = { { item = 17020, count = 1 } } },
        },
        {
            { spells = { 11419 }, level = 50, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 11416 }, level = 40, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 11417 }, level = 40, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 10059 }, level = 40, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 11420 }, level = 50, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 11418 }, level = 40, reagents = { { item = 17032, count = 1 } } },
        },
        {
            { spells = { 130 }, level = 12, reagents = { { item = 17056, count = 1 } } },
        },
        {
            { spells = { 1302508 }, level = 1, reagents = { { item = 17056, count = 1 } } },
        },
        {
            { spells = { 1297659 }, level = 50, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3565 }, level = 30, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3562 }, level = 20, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3567 }, level = 20, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3561 }, level = 20, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3566 }, level = 30, reagents = { { item = 17031, count = 1 } } },
        },
        {
            { spells = { 3563 }, level = 20, reagents = { { item = 17031, count = 1 } } },
        },
    },
    WARLOCK = {
        {
            { spells = { 6366 }, level = 28, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17951 }, level = 36, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17952 }, level = 46, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17953 }, level = 56, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 6201 }, level = 10, reagents = { { item = 6265, count = 1 } } },
            { spells = { 6202 }, level = 22, reagents = { { item = 6265, count = 1 } } },
            { spells = { 5699 }, level = 34, reagents = { { item = 6265, count = 1 } } },
            { spells = { 11729 }, level = 46, reagents = { { item = 6265, count = 1 } } },
            { spells = { 11730 }, level = 58, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 693 }, level = 18, reagents = { { item = 6265, count = 1 } } },
            { spells = { 20752 }, level = 30, reagents = { { item = 6265, count = 1 } } },
            { spells = { 20755 }, level = 40, reagents = { { item = 6265, count = 1 } } },
            { spells = { 20756 }, level = 50, reagents = { { item = 6265, count = 1 } } },
            { spells = { 20757 }, level = 60, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 2362 }, level = 36, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17727 }, level = 48, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17728 }, level = 60, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 1122 }, level = 50, reagents = { { item = 5565, count = 1 } } },
        },
        {
            { spells = { 18540 }, level = 60, reagents = { { item = 16583, count = 1 } } },
        },
        {
            { spells = { 698 }, level = 20, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 17877 }, level = 20, reagents = { { item = 6265, count = 1 } } },
            { spells = { 18867 }, level = 24, reagents = { { item = 6265, count = 1 } } },
            { spells = { 18868 }, level = 32, reagents = { { item = 6265, count = 1 } } },
            { spells = { 18869 }, level = 40, reagents = { { item = 6265, count = 1 } } },
            { spells = { 18870 }, level = 48, reagents = { { item = 6265, count = 1 } } },
            { spells = { 18871 }, level = 56, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 6353 }, level = 48, reagents = { { item = 6265, count = 1 } } },
            { spells = { 17924 }, level = 56, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 1098 }, level = 30, reagents = { { item = 6265, count = 1 } } },
            { spells = { 11725 }, level = 44, reagents = { { item = 6265, count = 1 } } },
            { spells = { 11726 }, level = 58, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 691 }, level = 30, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 713 }, level = 20, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 712 }, level = 20, reagents = { { item = 6265, count = 1 } } },
        },
        {
            { spells = { 697 }, level = 10, reagents = { { item = 6265, count = 1 } } },
        },
    },
    DRUID = {
        {
            { spells = { 21849 }, level = 50, reagents = { { item = 17021, count = 1 } } },
            { spells = { 21850 }, level = 60, reagents = { { item = 17026, count = 1 } } },
        },
        {
            { spells = { 20484 }, level = 20, reagents = { { item = 17034, count = 1 } } },
            { spells = { 20739 }, level = 30, reagents = { { item = 17035, count = 1 } } },
            { spells = { 20742 }, level = 40, reagents = { { item = 17036, count = 1 } } },
            { spells = { 20747 }, level = 50, reagents = { { item = 17037, count = 1 } } },
            { spells = { 20748 }, level = 60, reagents = { { item = 17038, count = 1 } } },
        },
    },
}

ns.REAGENT_ITEMS = {
    [2928] = { stock = 20 },
    [2930] = { stock = 20 },
    [3371] = { stock = 20 },
    [3372] = { stock = 20 },
    [3818] = { stock = 20 },
    [5140] = { stock = 20 },
    [5173] = { stock = 20 },
    [5530] = { stock = 20 },
    [5565] = { stock = 5 },
    [6265] = { stock = 1 },
    [8923] = { stock = 20 },
    [8924] = { stock = 20 },
    [8925] = { stock = 20 },
    [16583] = { stock = 5 },
    [17020] = { stock = 20 },
    [17021] = { stock = 20 },
    [17026] = { stock = 20 },
    [17028] = { stock = 20 },
    [17029] = { stock = 20 },
    [17030] = { stock = 5 },
    [17031] = { stock = 10 },
    [17032] = { stock = 10 },
    [17033] = { stock = 5 },
    [17034] = { stock = 20 },
    [17035] = { stock = 20 },
    [17036] = { stock = 20 },
    [17037] = { stock = 20 },
    [17038] = { stock = 20 },
    [17056] = { stock = 20 },
    [17057] = { stock = 20 },
    [17058] = { stock = 20 },
    [21177] = { stock = 100 },
}
