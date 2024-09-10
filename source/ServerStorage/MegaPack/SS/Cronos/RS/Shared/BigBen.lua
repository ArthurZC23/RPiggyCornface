local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local PriorityQueue = Mod:find({"DataStructures", "PriorityQueue"})
local Promise = Mod:find({"Promise", "Promise"})

local BigBen = {}

BigBen.tickType = {
    time_ = {
        Stepped = 0,
        Heartbeat = 0,
    },
    frame = 0,
}

local lastCbNumId = 0
local DisconnectedCbIds = {}

local function handleCallbacks(priorityQueue, tickType, runServiceMethod)
    return function(step, ...)
        local runnedAllCbs = false
        while not runnedAllCbs do
            local entry = priorityQueue:getHighestPriority()
            if not entry then return end

            local tbl, tickThreshold = entry[1], entry[2]
            local id = tbl.id

            local currentTickTime = BigBen.tickType["time_"][runServiceMethod]
            local currentTickFrame =  BigBen.tickType["frame"]
            local currentTick
            if tickType == "frame" then
                currentTick = currentTickFrame
            elseif tickType == "time_" then
                currentTick = currentTickTime
            end

            if DisconnectedCbIds[id] then
                DisconnectedCbIds[id] = nil
                priorityQueue:pop()
            elseif tickThreshold <= currentTick then
                priorityQueue:pop()
                local cb = tbl.callback
                local period = tbl.period
                local timeStep
                local frameStep

                if tbl.previousTickTime then
                    timeStep = currentTickTime - tbl.previousTickTime
                else
                    timeStep = step
                end

                if tbl.previousTickFrame then
                    frameStep = currentTickFrame - tbl.previousTickFrame
                else
                    frameStep = 1
                end

                tbl.previousTickTime = currentTickTime
                tbl.previousTickFrame = currentTickFrame

                priorityQueue:push(
                    tbl,
                    currentTick + period()
                )
                task.spawn(cb, step, timeStep, frameStep, ...)
            else
                runnedAllCbs = true
            end
        end
    end
end

local priorityQueues = {
    frame = {
        Stepped = PriorityQueue.new(),
        Heartbeat = PriorityQueue.new(),
    },
    time_ = {
        Stepped = PriorityQueue.new(),
        Heartbeat = PriorityQueue.new(),
    },
}

local callbacks = {
    Stepped = {},
    Heartbeat = {},
}

function BigBen.addCallback(cb, runServiceMethod)
    table.insert(callbacks[runServiceMethod], cb)
end

if RunService:IsStudio() then
    -- BigBen.addCallback(function(step) print(("%s Heartbeat"):format(BigBen.tickType.frame)) end, "Heartbeat")
end

function BigBen.removeCallback(cb, runServiceMethod)
    local idx = table.find(callbacks[runServiceMethod], cb)
    table.remove(callbacks[runServiceMethod], idx)
end


if RunService:IsClient() then
    priorityQueues.frame.RenderStepped = PriorityQueue.new()
    priorityQueues.time_.RenderStepped = PriorityQueue.new()
    callbacks.RenderStepped = {}

    BigBen.tickType.time_.RenderStepped = 0

    RunService.RenderStepped:Connect(function(step)
        BigBen.tickType.time_.RenderStepped += step
        BigBen.tickType.frame += 1
        for _, cb in ipairs(callbacks.RenderStepped) do
            task.spawn(cb, step)
        end
    end)

    BigBen.addCallback(handleCallbacks(priorityQueues.time_.RenderStepped, "time_", "RenderStepped"), "RenderStepped")
    BigBen.addCallback(handleCallbacks(priorityQueues.frame.RenderStepped, "frame", "RenderStepped"), "RenderStepped")
end

RunService.Stepped:Connect(function(time, step)
    BigBen.tickType.time_.Stepped += step
    if RunService:IsServer() then
        BigBen.tickType.frame += 1
    end
    for _, cb in ipairs(callbacks.Stepped) do
        task.spawn(cb, step, time)
    end
end)

RunService.Heartbeat:Connect(function(step)
    BigBen.tickType.time_.Heartbeat += step
    for _, cb in ipairs(callbacks.Heartbeat) do
        task.spawn(cb, step)
    end
end)

BigBen.addCallback(handleCallbacks(priorityQueues.time_.Stepped, "time_", "Stepped"), "Stepped")
BigBen.addCallback(handleCallbacks(priorityQueues.frame.Stepped, "frame", "Stepped"), "Stepped")
BigBen.addCallback(handleCallbacks(priorityQueues.time_.Heartbeat, "time_", "Heartbeat"), "Heartbeat")
BigBen.addCallback(handleCallbacks(priorityQueues.frame.Heartbeat, "frame", "Heartbeat"), "Heartbeat")

function BigBen.every(period, runServiceMethod, tickType, executeNextTick)
    executeNextTick = executeNextTick or false

    local _period = period
    if typeof(period) == "number" then
        _period = function() return period end
    end

    return {
        Connect = function(_, cb, cleanup)
            local currentTick
            if tickType == "frame" then
                currentTick = BigBen.tickType[tickType]
            elseif tickType == "time_" then
                currentTick = BigBen.tickType[tickType][runServiceMethod]
            end
            local id = tostring(lastCbNumId)
            lastCbNumId += 1
            local priority
            local tbl = {
                callback = cb,
                id = id,
                period = _period,
            }
            if executeNextTick then
                priority = currentTick
            else
                priority = currentTick + _period()
                tbl.previousTickFrame = BigBen.tickType["frame"]
                tbl.previousTickTime = BigBen.tickType["time_"][runServiceMethod]
            end

            priorityQueues[tickType][runServiceMethod]:push(
                tbl,
                priority
            )
            local disconnected = false
            local conn = {
                Disconnect = function()
                    DisconnectedCbIds[id] = true
                    disconnected = true
                    if cleanup then cleanup() end
                end,
                awaitDisconnect = function()
                    while not disconnected do
                        task.wait()
                    end
                end,
            }
            conn.awaitDisconnectPromise = function()
                return Promise.new(function(resolve, reject, onCancel)
                    conn.awaitDisconnect()
                    resolve()
                end)
            end
            conn.Destroy = conn.Disconnect
            return conn
        end
    }
end

function BigBen:Destroy()
    self._maid:Destroy()
end

return BigBen