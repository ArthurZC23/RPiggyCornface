-- Saving Method that always error. Intended for testing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataStoreService = require(ServerStorage.DataStoreService)
local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Promise = Mod:find({"Promise", "Promise"})

local Error = {}
Error.__index = Error

function Error:Get()
    return Promise.new(function(resolve, reject)
        reject("Error getting player data.")
    end)
end

function Error:Set(value)
    return Promise.new(function(resolve)
        self.dataStore:UpdateAsync(self.userId, function()
            return value
        end)

        resolve()
    end)
end

function Error.new(dataStore2)
    return setmetatable({
        dataStore = DataStoreService:GetDataStore(dataStore2.Name),
        userId = dataStore2.UserId,
    }, Error)
end

return Error