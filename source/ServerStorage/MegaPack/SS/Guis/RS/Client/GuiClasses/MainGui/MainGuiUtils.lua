local Players = game:GetService("Players")

local MainGui
do
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    MainGui = PlayerGui:WaitForChild("MainGui").MainGui.MainGui
end

local module = {}

function module.getMainGuiObj()
    return MainGui
end

return module