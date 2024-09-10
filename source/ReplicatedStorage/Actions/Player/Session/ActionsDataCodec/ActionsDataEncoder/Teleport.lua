local RunService = game:GetService("RunService")

if RunService:IsClient() then error("Action data decoder must run on Server.") end

local module = {}

function module.teleport(action)
    action.kwargs.cf = {action.kwargs.cf:components()}
    return action
end

return module