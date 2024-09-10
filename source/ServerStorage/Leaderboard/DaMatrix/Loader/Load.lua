local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local sysName = "Leaderboard"

local RootF = script:FindFirstAncestor(sysName)

do
    local binders = RootF.SS.Binders
    for _, b in ipairs(binders:GetChildren()) do
        b.Parent = ServerStorage.Binders.SS
    end
end

CollectionService:AddTag(game, "LocalLeaderboard")

local module = {}

return module