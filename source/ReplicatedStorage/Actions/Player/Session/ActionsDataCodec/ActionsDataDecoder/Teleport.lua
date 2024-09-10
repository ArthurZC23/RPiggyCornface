local RunService = game:GetService("RunService")

if RunService:IsServer() then error("Action data decoder must run on client.") end

local module = {}

function module.teleport(action)
    action.kwargs.cf = CFrame.new(unpack(action.kwargs.cf))
    return action
end

return module