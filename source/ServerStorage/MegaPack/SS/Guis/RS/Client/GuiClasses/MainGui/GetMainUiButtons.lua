local player = script:FindFirstAncestorOfClass("Player")
local PlayerGui = player:WaitForChild("PlayerGui")

local module = {}

function module.getButtonsReferences()
    return PlayerGui:WaitForChild("MainUiButtons").References
end

return module