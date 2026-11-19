local _, ns = ...

local TestMode = { active = false }
ns.TestMode = TestMode

local function SetActive(active)
    if TestMode.active == active then return end
    TestMode.active = active
    ns.Fire("TEST_MODE_CHANGED", active)
end

function TestMode.Start()
    SetActive(true)
end

function TestMode.Stop()
    SetActive(false)
end

function TestMode.Toggle()
    SetActive(not TestMode.active)
end
