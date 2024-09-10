local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Data = Mod:find({"Data", "Data"})
local OrderedBackupsConfig = Data.DataStore.DsbConfig.OrderedBackups

local DataStoreService = require(ServerStorage.DataStoreService )
local Promise = Mod:find({"Promise", "Promise"})

local OrderedBackups = {}
OrderedBackups.__index = OrderedBackups

local ONE_TRY = 1

local function retry(maxTries, obj, func, ...)
	local tries = 0
	local ok, result
	repeat
		tries = tries + 1
		ok, result = pcall(func, ...)
		if not ok then wait(OrderedBackupsConfig.RetryCooldown) end
	until tries == maxTries or ok
	obj.dataStore2:Debug("Tryied ", tries, " times")
	if not ok then
		error(result)
	else
		return result
	end
end


local function getNewestPlayerData(obj, datastore, key)
	local ERROR_GET_MESSAGE = "Failed while trying to get updated data"
	local currentKey = key
	local success, currentResult = pcall(retry, ONE_TRY, obj, datastore.GetAsync, datastore, currentKey)
	if not success then error(ERROR_GET_MESSAGE) end
	local isDataTheNewest = false
	while not isDataTheNewest do
		local nextKey = currentKey + 1
		local ok, result = pcall(retry, ONE_TRY, obj, datastore.GetAsync, datastore, nextKey)
		if not ok then error(ERROR_GET_MESSAGE) end
		if ok and result == nil then isDataTheNewest = true
		else
			currentKey = nextKey
			currentResult = result
		end
	end
	return currentKey, currentResult
end

function OrderedBackups:Get()
	return Promise.new(function(resolve)
		resolve(self.orderedDataStore:GetSortedAsync(false, 1):GetCurrentPage()[1])
	end):andThen(function(mostRecentKeyPage)
		if not mostRecentKeyPage then
			self.dataStore2:Debug("No recent key")
			return nil
		end
		local recentKey = mostRecentKeyPage.value
		self.dataStore2:Debug("Most recent key", mostRecentKeyPage)

		return Promise.new(function(resolve)
			local realNewestKey, newestPlayerData = getNewestPlayerData(self, self.dataStore, recentKey)
			self.mostRecentKey = realNewestKey
			resolve(newestPlayerData)
		end)

	end)
end


function OrderedBackups:Set(value)
	local key = (self.mostRecentKey or 0) + 1

	return Promise.new(function(resolve)
		self.dataStore2.Debug('Retry DS')
		retry(OrderedBackupsConfig.MaxTries, self, self.dataStore.SetAsync, self.dataStore, key, value)
		resolve()
	end):andThen(function()
		return Promise.try(function()
			self.dataStore2.Debug('Retry ODS')
			retry(OrderedBackupsConfig.MaxTries, self, self.orderedDataStore.SetAsync, self.orderedDataStore, key, key)
		end)
	end):andThen(function()
		self.mostRecentKey = key
	end)
end

function OrderedBackups.new(dataStore2)
	local dataStoreKey = dataStore2.Name .. "/" .. dataStore2.UserId

	local info = {
		dataStore2 = dataStore2,
		dataStore = DataStoreService:GetDataStore(dataStoreKey),
		orderedDataStore = DataStoreService:GetOrderedDataStore(dataStoreKey),
	}

	return setmetatable(info, OrderedBackups)
end

return OrderedBackups
