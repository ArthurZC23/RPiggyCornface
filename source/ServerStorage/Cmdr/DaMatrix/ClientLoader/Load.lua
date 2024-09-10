local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

task.spawn(function()
    Cmdr:SetActivationKeys({Enum.KeyCode.F2})
end)

local module = {}

return module