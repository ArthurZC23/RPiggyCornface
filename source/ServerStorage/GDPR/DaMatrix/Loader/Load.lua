local RunService = game:GetService("RunService")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

if RunService:IsStudio() then
    local PurgePlayerDataFromGame = RootF.SS.PurgePlayerDataFromGame
    require(PurgePlayerDataFromGame)
end

local module = {}

return module