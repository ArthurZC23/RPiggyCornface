local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RFunctions = ReplicatedStorage.Remotes.Functions
local GetServerTypeRF = RFunctions:WaitForChild("GetServerType")

local module = {}

function module.getServerType()
    return GetServerTypeRF:InvokeServer()
end

return module