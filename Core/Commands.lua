local _, ns = ...

SLASH_REREAGENT1 = "/reagents"
SLASH_REREAGENT2 = "/rereagent"
SlashCmdList.REREAGENT = function()
    ns.Options.Toggle()
end

function ReReagent_OnAddonCompartmentClick()
    ns.Options.Toggle()
end
