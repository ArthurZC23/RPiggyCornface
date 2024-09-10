local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local PurgedPlayers = Data.Players.GDPR.PurgedPlayers
local Purge = Mod:find({"DataStore", "Purge"})
local Scores = Data.Scores.Scores
local S = Data.Strings.Strings
local FastSpawn = Mod:find({"FastSpawn"})
local PromiseUtils = Mod:find({"Promise", "Utils"})

local promiseGenerator = PromiseUtils.retryGenerator(100, 30)

local DataStoreService = require(ServerStorage.DataStoreService)

if RunService:IsStudio() then
    FastSpawn(function()
        local function getDataStores()
            local DataStores = {}
            DataStores["DATA"] = DataStoreService:GetDataStore("DATA")
            DataStores["Leaderboards"] = {}
            for scoreType in pairs(Scores.scoreTypes) do
                for timeType in pairs(Scores.timeTypes) do
                    do
                        local key = ("Leaderboard/%s"):format(scoreType)
                        DataStores["Leaderboards"][("%s/%s"):format(key, timeType)] = DataStoreService:GetOrderedDataStore(key, timeType)
                    end
                    do
                        local key = ("LeaderboardV2/%s"):format(scoreType)
                        DataStores["Leaderboards"][("%s/%s"):format(key, timeType)] = DataStoreService:GetOrderedDataStore(key, timeType)
                    end
                end
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
            local ok, data = promiseGenerator(function()
                local data = DataStores["DATA"]:GetAsync(userId)
                return data
            end)
            :await()
            if not ok then warn(tostring(data)) end

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
    end)
end

local module = {}


return module