
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Data = Mod:find({"Data", "Data"})
local DataStoreBConfig = Data.DataStore.DsbConfig
local DsbStores = Data.DataStore.DsbStores
local GameData = Data.Game.Game
local Promise = Mod:find({"Promise", "Promise"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local TableUtils = Mod:find({"Table", "Utils"})

local Constants = require(script.Constants)
local SavingMethods = require(script.SavingMethods)
local Settings = require(script.Settings)
local Utils = require(script.Utils)
local Verifier = require(script.Verifier)

local SaveInStudio = DataStoreBConfig.SaveInStudio
local Debug = DataStoreBConfig.Debug

local DataStore = {}

--Internal functions
function DataStore:Debug(...)
	if Debug then
		print("[DataStore2.Debug]", ...)
	end
end

function DataStore:_GetRawPromise()

	if self.getRawPromise then return self.getRawPromise end

	self.getRawPromise = self.savingMethod:Get()
        :andThen(function(value)
            -- self:Debug("Value received")
            self.value = value
            self.haveValue = true
        end)
        :catch(function(reason)
            self.getRawPromise = nil
            return Promise.reject(reason)
	end)

	return self.getRawPromise
end

function DataStore:_Update(dontCallOnUpdate)
	if not dontCallOnUpdate then
		for _, callback in ipairs(self.callbacks) do
			callback(self.value, self)
		end
	end

	self.haveValue = true
	self.valueUpdated = true
end

function DataStore:_GetValue()
    local attempts = 0
    local maxAttempts = self.backupRetries or 1

	while not self.haveValue do
        local player = Players:GetPlayerByUserId(self.UserId)
        if not player then
            self.backup = true
            self.haveValue = true
            self.value = nil -- Will be filled with defaultValue
            break
        end

        attempts = attempts + 1
		local success, error = self:_GetRawPromise():await()
		if not success then
			self:Debug("Get returned error:", tostring(error))
            if attempts >= maxAttempts then
                self.backup = true
                self.haveValue = true
                self.value = nil -- Will be filled with default
            else
                -- exponential cooldown here
                local alpha = (2 ^ (attempts - 1))
                task.wait(alpha * self.backupCooldown)
            end
		end
        -- This will only pass for new players or players that the store didn't return their data.
        if success and self.value == nil then
            -- Check if datastore didn't return nil despite having data for the player
            local dataValidationBadge = DataStoreBConfig.dataValidationBadge
            if not dataValidationBadge then
                warn("Game doesn't has data validation badge.")
                return
            end
            local ok, hasBadge = pcall(function()
                return BadgeService:UserHasBadgeAsync(self.UserId, dataValidationBadge)
            end)
            if not ok then
                warn(hasBadge)
                self.backup = true -- Cannot confirm if player has data.
                return
            end
            if hasBadge then
                local ServerTypesData = Data.Game.ServerTypes
                local envs = {
                    [ServerTypesData.sTypes.LiveProduction] = true,
                }
                if envs[ServerTypesData.ServerType] then
                    self.backup = true -- Player already saved data in the game, but it didn't load.
                    return
                end
            end
        end
	end
end

function DataStore:_DeserializeData()
	if self.value ~= nil then
		for _, modifier in ipairs(self.beforeInitialGet) do
			self.value = modifier(self.value, self)
		end
	end
end

--Public functions

function DataStore:Get(defaultValue, dontAttemptGet)
	if dontAttemptGet then return self.value end
	self:_GetValue()
	self:_DeserializeData()

	local value
    -- No need for backup default because of this. Backup should be the initial default data
    -- Not some random stuff.
	if self.value == nil then
		value = Utils.clone(defaultValue)
		self.value = value
	else
		value = self.value
	end
	return value
end

function DataStore:GetAsync(...)
    local args = {...}
	return Promise.try(function()
		return self:Get(unpack(args))
	end)
end

function DataStore:GetTable(default, ...)
	local success, result = self:GetTableAsync(default, ...):await()
	if not success then
		error(tostring(result))
	end
	return result
end

function DataStore:GetTableAsync(default, ...)
	assert(default ~= nil, "You must provide a default value.")

	return self:GetAsync(default, ...):andThen(function(result)
        local changed = false
        assert(
            typeof(result) == "table",
            ":GetTable/:GetTableAsync was used when the value in the data store isn't a table."
        )

        -- for defaultKey, defaultValue in pairs(default) do
        -- 	if result[defaultKey] == nil then
        -- 		result[defaultKey] = defaultValue
        -- 		changed = true
        -- 	end
        -- end

        local flatDefault = TableUtils.flatNestedTable(default)
        for composedDefaultKey, defaultValue in pairs(flatDefault) do
            local resultVal = ComposedKey.get(result, composedDefaultKey)
            if resultVal == nil then
                ComposedKey.set(result, composedDefaultKey, defaultValue)
                changed = true
            end
        end

        if changed then
            self:Set(result)
        end

        return result
    end)
end

function DataStore:Set(value, _dontCallOnUpdate)
	self.value = Utils.clone(value)
	self:_Update(_dontCallOnUpdate)
end

function DataStore:Update(updateFunc)
	self.value = updateFunc(self.value)
	self:_Update()
end

function DataStore:Increment(increment, defaultValue)
	self:Set(self:Get(defaultValue) + increment)
end

function DataStore:IncrementAsync(increment, defaultValue)
	return self:GetAsync(defaultValue):andThen(function(value)
		return Promise.try(function()
			self:Set(value + increment)
		end)
	end)
end

function DataStore:OnUpdate(callback)
	table.insert(self.callbacks, callback)
end

function DataStore:BeforeInitialGet(modifier)
	table.insert(self.beforeInitialGet, modifier)
end

function DataStore:BeforeSave(modifier)
	self.beforeSave = modifier
end

function DataStore:AfterSave(callback)
	table.insert(self.afterSave, callback)
end

-- Backup methods

function DataStore:SetBackup(retries, backupCooldown)
	self.backupRetries = retries
    self.backupCooldown = backupCooldown or 1
end

function DataStore:ClearBackup()
	self.backup = nil
	self.haveValue = false
	self.value = nil
	self.getRawPromise = nil
end

function DataStore:IsBackup()
	return self.backup ~= nil
end

-- Save methods

function DataStore:Save()
	local success, result = self:SaveAsync():await()

	if success then
		-- self:Debug("Saved", self.Name)
	else
		error(tostring(result))
	end
end

function DataStore:SaveAsync()
	return Promise.defer(function(resolve, reject)
		if not self.valueUpdated then
			warn(("Data store %s was not saved as it was not updated."):format(self.Name))
			resolve(false)
			return
		end

		if RunService:IsStudio() and not SaveInStudio then
			warn(("Data store %s attempted to save in studio while SaveInStudio is false."):format(self.Name))

			resolve(false)
			return
		end

		if self.backup then
			warn("This data store is a backup store, and thus will not be saved.")
			resolve(false)
			return
		end

		if self.value ~= nil then
			local save = Utils.clone(self.value)

			if self.beforeSave then
				local success, result = pcall(self.beforeSave, save, self)

				if success then
					save = result
				else
                    local errMsg = ("%s\n%s"):format(result, Constants.SaveFailure.BeforeSaveError)
                    ErrorReport.report("Server", errMsg, "error")

					reject(result, Constants.SaveFailure.BeforeSaveError)
					return
				end
			end

			local problem = Verifier.testValidity(save)
			if problem then
                local errMsg = ("%s\n%s"):format(problem, Constants.SaveFailure.InvalidData)
                ErrorReport.report("Server", errMsg, "error")

				reject(problem, Constants.SaveFailure.InvalidData)
				return
			end

			return self.savingMethod:Set(save)
                :andThen(function()
				    resolve(true, save)
			    end)
                :catch(function(err)
                    reject(tostring(err))
                end)
		end
	end):andThen(function(saved, save)
		if saved then
			for _, afterSave in ipairs(self.afterSave) do
				local success, err = pcall(afterSave, save, self)

				if not success then
					warn("Error on AfterSave:", err)
				end
			end

			self.valueUpdated = false
		end
	end)
end

function DataStore:BindToClose(callback)
	table.insert(self.bindToClose, callback)
end

function DataStore:GetKeyValue(key)
	return (self.value or {})[key]
end

function DataStore:SetKeyValue(key, newValue)
	if not self.value then
		self.value = self:Get({})
	end

	self.value[key] = newValue
end

-- Combined DataStore
local CombinedDataStore = {}

do
	function CombinedDataStore:BeforeInitialGet(modifier)
		self.combinedBeforeInitialGet = modifier
	end

	function CombinedDataStore:BeforeSave(modifier)
		self.combinedBeforeSave = modifier
	end

	function CombinedDataStore:Get(defaultValue, dontAttemptGet)
		local tableResult = self.combinedStore:Get({})
		local tableValue = tableResult[self.combinedName]

		if not dontAttemptGet then
			if tableValue == nil then
				tableValue = defaultValue
			else
				if self.combinedBeforeInitialGet and not self.combinedInitialGot then
					tableValue = self.combinedBeforeInitialGet(tableValue)
				end
			end
		end
		
		-- Two deep copies before getting data. Not good.
		self.combinedInitialGot = true
		tableResult[self.combinedName] = Utils.clone(tableValue)
		self.combinedStore:Set(tableResult, true)
		return Utils.clone(tableValue)
	end

	function CombinedDataStore:Set(value, dontCallOnUpdate)
		return self.combinedStore:GetAsync({}):andThen(function(tableResult)
			tableResult[self.combinedName] = value
			self.combinedStore:Set(tableResult, dontCallOnUpdate)
			self:_Update(dontCallOnUpdate)
		end)
	end

	function CombinedDataStore:Update(updateFunc)
		self:Set(updateFunc(self:Get()))
		self:_Update()
	end

	function CombinedDataStore:Save()
		self.combinedStore:Save()
	end

	function CombinedDataStore:OnUpdate(callback)
		if not self.onUpdateCallbacks then
			self.onUpdateCallbacks = {callback}
		else
			table.insert(self.onUpdateCallbacks, callback)
		end
	end

	function CombinedDataStore:_Update(dontCallOnUpdate)
		if not dontCallOnUpdate then
			for _, callback in ipairs(self.onUpdateCallbacks or {}) do
				callback(self:Get(), self)
			end
		end

		self.combinedStore:_Update(true)
	end

	function CombinedDataStore:SetBackup(...)
		self.combinedStore:SetBackup(...)
	end
end

-- DataStore2
local DataStoreMetatable = {}

DataStoreMetatable.__index = DataStore

--Library
local DataStoreCache = {}

local DataStore2 = {}
local combinedDataStoreInfo = {}

--[[**
	<description>
	Run this once to combine all keys provided into one "main key".
	Internally, this means that data will be stored in a table with the key mainKey.
	This is used to get around the 2-DataStore2 reliability caveat.
	</description>

	<parameter name = "mainKey">
	The key that will be used to house the table.
	</parameter>

	<parameter name = "...">
	All the keys to combine under one table.
	</parameter>
**--]]
function DataStore2.Combine(mainKey, ...)
	for _, name in ipairs({...}) do
		combinedDataStoreInfo[name] = mainKey
	end
end

function DataStore2.ClearCache()
	DataStoreCache = {}
end

function DataStore2.SaveAll(player)
	if player.ClassName ~= "Player" then
		warn("Called DSB SaveAll with argument that isn't player. ", player)
		return
	end
	if DataStoreCache[player] then
		for _, dataStore in pairs(DataStoreCache[player]) do
			if dataStore.combinedStore == nil then -- Only save DATA, not its children.
				dataStore:Save()
			end
		end
	end
end

DataStore2.SaveAllAsync = function()
    Promise.try(DataStore2.SaveAll)
end

function DataStore2.PatchGlobalSettings(patch)
	for key, value in pairs(patch) do
		assert(Settings[key] ~= nil, "No such key exists: " .. key)
		-- TODO: Implement type checking with this when osyris' t is in
		Settings[key] = value
	end
end

function DataStore2.__call(_, dataStoreName, player)
	assert(
		typeof(dataStoreName) == "string" and player:IsA("Player"),
		("DataStore2() API call expected {string dataStoreName, Player player}, got {%s, %s}")
		:format(
			typeof(dataStoreName),
			typeof(player)
		)
	)

	if DataStoreCache[player] and DataStoreCache[player][dataStoreName] then
		return DataStoreCache[player][dataStoreName]
	elseif combinedDataStoreInfo[dataStoreName] then
		local dataStore = DataStore2(combinedDataStoreInfo[dataStoreName], player)

		dataStore:BeforeSave(function(combinedData)
			for key in pairs(combinedData) do
				if combinedDataStoreInfo[key] then
					local combinedStore = DataStore2(key, player)
					local value = combinedStore:Get(nil, true)
					if value ~= nil then
						if combinedStore.combinedBeforeSave then
							value = combinedStore.combinedBeforeSave(Utils.clone(value))
						end
						combinedData[key] = value
					end
				end
			end

			return combinedData
		end)

		local combinedStore = setmetatable(
			{
			combinedName = dataStoreName,
			combinedStore = dataStore,
			},
			{
			__index = function(_, key)
				return CombinedDataStore[key] or dataStore[key]
			end,
			}
		)

		if not DataStoreCache[player] then
			DataStoreCache[player] = {}
		end

		DataStoreCache[player][dataStoreName] = combinedStore
		return combinedStore
	end

	local dataStore = {
		Name = dataStoreName,
		UserId = player.UserId,
		callbacks = {},
		beforeInitialGet = {},
		afterSave = {},
		bindToClose = {},
	}

	dataStore.savingMethod = SavingMethods[DataStoreBConfig.SAVING_METHOD].new(dataStore)

	setmetatable(dataStore, DataStoreMetatable)

    local saveFinishedEvent, isSaveFinished = Instance.new("BindableEvent"), false
	local bindToCloseEvent = Instance.new("BindableEvent")

	local bindToCloseCallback = function()
		if not isSaveFinished then
			-- Defer to avoid a race between connecting and firing "saveFinishedEvent"
			Promise.defer(function()
				bindToCloseEvent:Fire() -- Resolves the Promise.race to save the data
			end)

			saveFinishedEvent.Event:Wait()
		end

		local value = dataStore:Get(nil, true)

		for _, bindToClose in ipairs(dataStore.bindToClose) do
			bindToClose(player, value)
		end
	end

    if not RunService:IsStudio() then
        local success, errorMessage = pcall(function()
            game:BindToClose(function()
                if bindToCloseCallback == nil then
                    return
                end

                bindToCloseCallback()
            end)
        end)
        if not success then
            -- It will not teleport to a new place when server updates.
            -- It doesn't interfer with session lock.
            warn("DataStore2 could not BindToClose", errorMessage)
        end
    end

	Promise.race({
		Promise.fromEvent(bindToCloseEvent.Event),
		Promise.fromEvent(player.AncestryChanged, function()
			return not player:IsDescendantOf(game)
		end),
	})
        :andThen(function()
            --print("Test") -- Only run once
            local value = dataStore:Get(nil, true)
            -- Not necessary. SaveAsync already has this safe mechanism.
            --if not value then return end

            if value.Server and value.Server.lockId then
                value.Server.lockId = nil
                -- Test server not making the final save
                -- if GameData.placeIds[game.placeId] ~= "PRODUCTION" then
                --     value.Server.lockId = game.JobId
                -- end
                --value.Server.lockTimeout = nil
            end
            dataStore:Set(value)

            dataStore:SaveAsync()
                :andThen(function()
                    print("player left, saved", dataStoreName)
                end)
                :catch(function(error)
			        warn("error when player left!", tostring(error))
		        end)
                :finally(function()
                    isSaveFinished = true
                    saveFinishedEvent:Fire()

                    DataStoreCache[player] = nil
			        bindToCloseCallback = nil
                end)

		-- --Give a long delay for people who haven't figured out the cache :^(
		-- return Promise.delay(40):andThen(function()
		-- 	DataStoreCache[player] = nil
		-- 	bindToCloseCallback = nil
		-- end)
	end)

	if not DataStoreCache[player] then
		DataStoreCache[player] = {}
	end

	DataStoreCache[player][dataStoreName] = dataStore

	return dataStore
end

DataStore2.Constants = Constants

local DSB = setmetatable(DataStore2, DataStore2)

local function combineStoreKeys()
	for _, gameKey in pairs(DsbStores.names) do
		DSB.Combine("DATA", gameKey)
	end
end

combineStoreKeys()

return DSB
