local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Promise = Mod:find({"Promise", "Promise"})

local DataStoreService = require(ServerStorage.DataStoreService)

local LimitedBackups = {}
LimitedBackups.__index = LimitedBackups

local NEW_KEY = "New"

function LimitedBackups.new(dataStore2)
	local dataStoreKey = dataStore2.Name .. "/" .. dataStore2.UserId

	local info = {
		dataStore2 = dataStore2,
		dataStore = DataStoreService:GetDataStore(dataStoreKey),
	}

	return setmetatable(info, LimitedBackups)
end

function LimitedBackups:Get()
	return Promise.new(function(resolve)
		resolve(self.dataStore:GetAsync(NEW_KEY))
	end)
	:andThen(function(data)
		if not data then
			self.dataStore2:Debug("No data")
			return nil
		end
		self.dataStore2:Debug("Most recent key", data.key)
		return data
	end)
end

function LimitedBackups:Set(value)
	value.timestamp = os.time()
    return Promise.new(
        function (resolve, reject)
            self.dataStore2.Debug('Retry DS Set.')
            local ok, err = pcall(self.dataStore.SetAsync, self.dataStore, NEW_KEY, value)
            if ok then
                resolve()
            else
                reject(tostring(err))
            end
        end)
end

return LimitedBackups
