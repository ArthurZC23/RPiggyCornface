local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local PCallUtils = Mod:find({"PCallUtils"})

local localPlayer = Players.LocalPlayer

local debounce = {}

function debounce.playerExecution(func)
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and player == localPlayer) then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
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
		if not (player and player == localPlayer) then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, ...)
		executed = true
		if not ok then error(err, 2) end
    end
end

function debounce.playerExecutionCooldown(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and player == localPlayer) then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, ...)
        Cronos.wait(timeInterval)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.playerLimbExecution(func, rigType)
    rigType = rigType or "R15"
    local isRunning = false
    return function(candidate, ...)
		if isRunning then return end
		local player = PlayerUtils.getPlayerFromPart(candidate)
		if not (player and PlayerUtils.isLimb(candidate, rigType) and player == localPlayer) then return end
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
		if not (player and PlayerUtils.isLimb(candidate, rigType) and player == localPlayer) then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
		executed = true
		if not ok then error(err, 2) end
    end
end

function debounce.playerHrpCooldown(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    return function(candidate, ...)
        if candidate.Name ~= "HumanoidRootPart" then return end
        local player = PlayerUtils.getPlayerFromPart(candidate)
        if not (player and candidate.Name == "HumanoidRootPart" and player == localPlayer) then return end
        local char = candidate.Parent
        local ok, err = PCallUtils.tracePcall(func, player, char, candidate, ...)
        Cronos.wait(timeInterval)
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
		if not (player and PlayerUtils.isLimb(candidate, rigType) and player == localPlayer) then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
        Cronos.wait(timeInterval)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.oneExecutionOnCondition(func, conditionFunc)
    local isRunning = false
    assert(typeof(conditionFunc) == "function", "Condition must be a function.")
    return function(candidate, ...)
        local player
        if candidate:IsA("Player") then
            player = candidate
        else
            player = PlayerUtils.getPlayerFromPart(candidate)
        end
		if not (player and player == localPlayer) then return end
        if not conditionFunc(...) then return end
        if not isRunning then
            isRunning = true
            -- This will not run again. So if add another check here with a "return nil"
            -- This piece of code becomes unnaccessible and will not throw an warning.
            local ok, err = PCallUtils.tracePcall(func, player, candidate, ...)
			if not ok then error(err, 2) end
        end
    end
end

return debounce