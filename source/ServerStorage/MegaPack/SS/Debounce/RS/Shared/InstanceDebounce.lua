local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local PCallUtils = Mod:find({"PCallUtils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local rootFolder = script:FindFirstAncestor("Shared")
local Utils = require(rootFolder.Utils)

local debounce = {}

function debounce.playerExecution(func)
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not player then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.onePlayerExecution(func)
    local isRunning = false
	local executed = false
    return function(candidate, ...)
		if isRunning or executed then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not player then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
		executed = true
		if not ok then error(err, 2) end
    end
end

function debounce.onePlayerExecutionPerPlayer(func)
	local playersIgnoreList = {}
	local isRunning = {}
	local executed = {}
	return function(candidate, ...)
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not player then return end
		if playersIgnoreList[player] then return end
		if isRunning[player] or executed[player] then return end
		isRunning[player] = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
		executed[player] = true
		if not ok then error(err, 2) end
	end
end

function debounce.playerExecutionCooldown(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not player then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
        Cronos.wait(timeInterval)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.cooldownPerPlayer(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local playersIgnoreList = {}
    return function(candidate, ...)
        local player = PlayerUtils.getPlayerFromPart(candidate)
        if not player then return end
        if not playersIgnoreList[player] then
            playersIgnoreList[player] = true
			local ok, err = PCallUtils.tracePcall(func, player, ...)
            Cronos.wait(timeInterval)
			playersIgnoreList[player] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.cooldownPerInstance(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local instIgnoreList = {}
    return function(inst, ...)
        if not inst:IsA("Instance") then return end
        if not instIgnoreList[inst] then
            instIgnoreList[inst] = true
			local ok, err = PCallUtils.tracePcall(func, inst, ...)
            Cronos.wait(timeInterval)
			instIgnoreList[inst] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.playerLimbExecution(func, rigType)
    rigType = rigType or "R15"
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and PlayerUtils.isLimb(candidate, rigType)) then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.playerHrp(func)
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and candidate.Name == "HumanoidRootPart") then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.onePlayerLimbExecution(func, rigType)
    rigType = rigType or "R15"
    local isRunning = false
	local executed = false
    return function(candidate, ...)
		if isRunning or executed then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and PlayerUtils.isLimb(candidate, rigType)) then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
		executed = true
		if not ok then error(err, 2) end
    end
end

function debounce.playerLimbExecutionCooldown(func, timeInterval, rigType)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    rigType = rigType or "R15"
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and PlayerUtils.isLimb(candidate, rigType)) then return end
		isRunning = true
        local char = candidate:FindFirstAncestor(player.Name)
		local ok, err = PCallUtils.tracePcall(func, player, char, candidate, ...)
        Cronos.wait(timeInterval)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.playerHrpCooldownPerPlayer(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local playersIgnoreList = {}
    return function(candidate, ...)
        if candidate.Name ~= "HumanoidRootPart" then return end
        local player = PlayerUtils.getPlayerFromPart(candidate)
        if not player then return end
        if not playersIgnoreList[player] then
            playersIgnoreList[player] = true
            local char = candidate.Parent
			local ok, err = PCallUtils.tracePcall(func, player, char, candidate, ...)
            Cronos.wait(timeInterval)
			playersIgnoreList[player] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.playerLimbCooldownPerPlayer(func, timeInterval, rigType)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    rigType = rigType or "R15"
    local playersIgnoreList = {}
    return function(candidate, ...)
        local player = PlayerUtils.getPlayerFromPart(candidate)
        if not (player and PlayerUtils.isLimb(candidate, rigType)) then return end
        if not playersIgnoreList[player] then
            playersIgnoreList[player] = true
            local char = candidate:FindFirstAncestor(player.Name)
			local ok, err = PCallUtils.tracePcall(func, player, char, candidate, ...)
            Cronos.wait(timeInterval)
			playersIgnoreList[player] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.humanoidLimbCooldownPerHumanoid(func, timeInterval, rigType)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    rigType = rigType or "R15"
    local humanoidIgnoreList = {}
    return function(candidate, ...)
        local humanoid = PlayerUtils.getHumanoidFromPart(candidate)
        if not (humanoid and PlayerUtils.isLimb(candidate, rigType)) then return end
        if not humanoidIgnoreList[humanoid] then
            humanoidIgnoreList[humanoid] = true
			local ok, err = PCallUtils.tracePcall(func, humanoid, candidate, ...)
            Cronos.wait(timeInterval)
			humanoidIgnoreList[humanoid] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.triggerInOuBox(funcInside, funcOutside, box)
    local cooldown = 0.2
    local isRunningCritical = false -- Avoid running the same player more than once
    local playersInsideBox = {}
    return function(part)
        if not isRunningCritical then
            isRunningCritical = true
            local player
            local character
            player = PlayerUtils.getPlayerFromPart(part)
            if not player or playersInsideBox[player] then
                isRunningCritical = false
                return
            end
            playersInsideBox[player] = true
            isRunningCritical = false
            character = player.Character
            funcInside(player, character, part)
            while Utils.isCharacterNearBox(character, box) do
                Cronos.wait(cooldown)
            end
            funcOutside(player, character, part)
            playersInsideBox[player] = nil
        end
    end
end

function debounce.insideBox(func, box, funcCooldown)
    local isRunningCritical = false -- Avoid running the same player more than once
    local playersInsideBox = {}
    return function(part)
        if not isRunningCritical then
            isRunningCritical = true
            local player
            local character
            player = PlayerUtils.getPlayerFromPart(part)
            if not player or playersInsideBox[player] then
                isRunningCritical = false
                return
            end
            playersInsideBox[player] = true
            isRunningCritical = false
            character = player.Character
            while Utils.isCharacterNearBox(character, box) do
                func(player, character, part)
                Cronos.wait(funcCooldown)
            end
            playersInsideBox[player] = nil
        end
    end
end

return debounce