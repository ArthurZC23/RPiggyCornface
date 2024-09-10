local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local PCallUtils = Mod:find({"PCallUtils"})
local Promise = Mod:find({"Promise", "Promise"})

local debounce = {}

function debounce.standard(func)
	local isRunning = false
    local traceback = debug.traceback(nil, 2)
	return function(...)
		if not isRunning then
			isRunning = true
			local ok, err = PCallUtils.tracePcallV2(func, traceback, ...)
			isRunning = false
			if not ok then error(err, 2) end
		end
	end
end

function debounce.oneExecution(func)
    local isRunning = false
    return function(...)
        if not isRunning then
            isRunning = true
			local ok, res = PCallUtils.tracePcall(func, ...)
			if not ok then error(res, 2) end
            return res
        end
    end
end

function debounce.cooldown(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local isRunning = false
    return function(...)
        if not isRunning then
            isRunning = true
			local ok, err = PCallUtils.tracePcall(func, ...)
            Cronos.wait(timeInterval)
			isRunning = false
			if not ok then error(err, 2) end
        end
    end
end

function debounce.remotes(func)
    local isRunning = false
    return function(player, ...)
		if isRunning then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

-- function debounce.events(func, events)
--     local isRunning = false
--     SignalUtils.handleFirstEvent(events, function()
--         isRunning = false
--     end)

--     return function(...)
-- 		if isRunning then return end
-- 		isRunning = true
-- 		local ok, err = PCallUtils.tracePcall(func, ...)
-- 		if not ok then error(err, 2) end
--     end
-- end

function debounce.playerExclusiveRemote(func, exclusivePlayer, cooldown)
    local isRunning = false
    assert(exclusivePlayer, "require player")
    assert(cooldown, "require cooldown even if its 0, to avoid missing parenthesis.")
    return function(player, ...)
        if player ~= exclusivePlayer then return end
        if isRunning then return end
        local values = {...}
        return Promise.try(function()
            isRunning = true
            func(player, unpack(values))
        end)
        :catch(function(err)
            task.defer(function()
                error(tostring(err))
            end)
        end)
        :finally(function()
            if cooldown > 0 then
                task.wait(cooldown)
            end
            isRunning = false
        end)
    end
end

function debounce.oneRemotesExecution(func)
    local isRunning = false
	local executed = false
    return function(player, ...)
		if isRunning or executed then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
		executed = true
		if not ok then error(err, 2) end
    end
end

function debounce.remotesPerPlayer(func)
    local playersIgnoreList = {}
    return function(player, ...)
        if not player:IsA("Player") then return end
        if not playersIgnoreList[player] then
            playersIgnoreList[player] = true
			local ok, err = PCallUtils.tracePcall(func, player, ...)
			playersIgnoreList[player] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.remotesExecutionCooldown(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local isRunning = false
    return function(player, ...)
		if isRunning then return end
		isRunning = true
		local ok, err = PCallUtils.tracePcall(func, player, ...)
        Cronos.wait(timeInterval)
		isRunning = false
		if not ok then error(err, 2) end
    end
end

function debounce.playerRemote(func, player, kwargs)
    assert(player and player:IsA("Player"), ("Invalid player parameter %s"):format(tostring(player), typeof(player)))
    local isRunning = false
    return function(plr, ...)
        if plr ~= player then return end
        if isRunning then return end
		isRunning = true
        local ok, err = PCallUtils.tracePcall(func, player, ...)
        if kwargs.timeInterval then
            Cronos.wait(kwargs.timeInterval)
        end
        isRunning = false
        if not ok then error(err, 2) end
    end
end

function debounce.remotesCooldownPerPlayer(func, timeInterval, kwargs)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    kwargs = kwargs or {}
    local playersIgnoreList = {}
    return function(player, ...)
        if not player:IsA("Player") then return end
        if playersIgnoreList[player] and kwargs.playerIgnoredCallback then
            kwargs.playerIgnoredCallback()
        else
            playersIgnoreList[player] = true
			local ok, err = PCallUtils.tracePcall(func, player, ...)
            Cronos.wait(timeInterval)
			playersIgnoreList[player] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.remotesCooldownPerInstance(func, timeInterval)
    assert(timeInterval ~= nil, "Time interval cannot be nil")
    local instsIgnoreList = {}
    return function(player, inst, ...)
        if not instsIgnoreList[inst] then
            instsIgnoreList[inst] = true
			local ok, err = PCallUtils.tracePcall(func, player, inst, ...)
            Cronos.wait(timeInterval)
			instsIgnoreList[inst] = nil
			if not ok then error(err, 2) end
        end
    end
end

function debounce.oneExecutionOnCondition(func, conditionFunc)
    local isRunning = false
    assert(typeof(conditionFunc) == "function", "Condition must be a function.")
    return function(...)
        if not conditionFunc(...) then return end
        if not isRunning then
            isRunning = true
            -- This will not run again. So if add another check here with a "return nil"
            -- This piece of code becomes unnaccessible and will not throw an warning.
			local ok, err = PCallUtils.tracePcall(func, ...)
			if not ok then error(err, 2) end
        end
    end
end

function debounce.onCondition(func, conditionFunc)
    return function(...)
        if conditionFunc() then
            func(...)
        end
    end
end

return debounce