
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local SetCore = require(ReplicatedFirst:WaitForChild("SetCore"))

local function setCoreInit()
    repeat
        local ok = pcall(SetCore.setCoreInitGame)
        task.wait(1)
    until ok
end
task.spawn(setCoreInit)