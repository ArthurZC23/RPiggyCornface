local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Clock = Mod:find({"Cronos", "Clock"})
local Promise = Mod:find({"Promise", "Promise"})

local Cronos = {}
Cronos.__index = Cronos
Cronos.className = "Cronos"

Cronos._clock = Clock.new()

function Cronos:getPlayerTimeInSeconds(playerState)
    local playerTimePlayedOnJoin = playerState:get("Session", "Time").playerTimePlayedOnJoin
    return playerTimePlayedOnJoin + Cronos:getPlayerSessionTime(playerState)
end

function Cronos:getPlayerSessionTime(playerState)
    -- Cannot Use Data in Cronos
    -- seconds
    local playerTime = playerState:get("Stores", "Time")
    local joinTime = playerTime.t0
    return Cronos:getTime() - joinTime
end

function Cronos:getTime()
    return Cronos._clock:getTime()
end

function Cronos:isServerTimeSynced()
    return Cronos._clock.isServerTimeSynced()
end

-- function Cronos.wait(totalTime)
--     local t = 0
-- 	while t < totalTime do
-- 		local step = RunService.Heartbeat:Wait()
-- 		t = t + step
-- 	end
-- end
Cronos.wait = task.wait

function Cronos.waitFrames(totalNumFrames)
    local numFrames = 0
    while numFrames < totalNumFrames do
        RunService.Heartbeat:Wait()
        numFrames += 1
    end
end

function Cronos.resettableWait(totalTime, event)
	local t = 0
    local conn
	conn = event:Connect(function() t = 0 end)
	while t < totalTime do
		local step = RunService.Heartbeat:Wait()
		t = t + step
	end
	conn:Disconnect()
end

function Cronos.waitUntilT1(t1, kwargs)
    kwargs = kwargs or {}
    return Promise.new(function(resolve, reject, onCancel)
        local t0 = Cronos:getTime()
        while t0 < t1 do
            local timeLeft = t1 - t0
            if kwargs.preTickCb then
                kwargs.preTickCb(t0, t1, timeLeft)
            end
            task.wait()
            t0 = Cronos:getTime()
        end
        resolve()
    end)
end

function Cronos:Destroy()

end

Cronos.startTimestamp = Cronos:getTime()

return Cronos