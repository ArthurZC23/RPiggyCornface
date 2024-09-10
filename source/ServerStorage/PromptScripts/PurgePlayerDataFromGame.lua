local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local DataStoreService = require(ServerStorage.DataStoreService)
local Purge = require(ServerStorage.DataStore.Purge.Purge)

local Data = require(ServerStorage.Data.Data)
local LeaderboardData = Data.Leaderboards.Leaderboards
local PurgedPlayers = Data.Players.GDPR.PurgedPlayers
local Scores = Data.Scores.Scores
local S = Data.Strings.Strings

if RunService:IsStudio() then

    local function getDataStores()
        local DataStores = {}
        DataStores["DATA"] = DataStoreService:GetDataStore("DATA")
        DataStores["Leaderboards"] = {}
        for id, data in pairs(LeaderboardData) do
            DataStores["Leaderboards"][("Leaderboard/%s/%s"):format(data.scoreType, data.timeType)] = data.ODataStore
        end

        DataStores[S.PurchaseHistory] = {
            --["All"] = DataStoreService:GetDataStore(S.PurchaseHistory, "All"),
            ["Newest"] = DataStoreService:GetDataStore(S.PurchaseHistory, "Newest"),
        }
        DataStores["Backup"] = DataStoreService:GetDataStore("Backup")
        DataStores["Trades"] = DataStoreService:GetDataStore("Trades")
        return DataStores
    end

    local DataStores = getDataStores()

    for _, userId in ipairs(PurgedPlayers.purge) do
        userId = tostring(userId)
        print(("Starting data purge for player %s."):format(userId))

        -- DATA need to be purged for last because it has valuable data for other stores.
        local data = DataStores["DATA"]:GetAsync(userId)
        local orderOfDeletion = {
            S.PurchaseHistory, --Ok
            "Backup", -- Ok
            "Trades", --Ok
            "Leaderboards", --Ok
            "DATA", -- Ok
        }

        for _, dsType in ipairs(orderOfDeletion) do
            Purge[dsType](DataStores[dsType], userId, data)
        end


        print(("Finished data purge for player %s."):format(userId))
    end
end

local module = {}


return module