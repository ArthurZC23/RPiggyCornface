local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Gaia = Mod:find({"Gaia", "Shared"})

local RootF = script.Parent
local Connection = require(RootF.Connection)

local Signal = {}
Signal.__index = Signal
Signal.className = "Signal"

Signal._Fire = {
    [Connection.types.PCallback] = function(fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then
            ErrorReport.report(nil, ("PCall connection\n%s"):format(err), "error")
        end
    end,
    [Connection.types.DeferredThread] = function(fn, ...)
        FastSpawn(fn, ...)
    end,
    [Connection.types.ImmediateThread] = function(fn, ...)
        local thread = coroutine.create(fn)
        local ok, err = coroutine.resume(thread, ...)
        if not ok then
            ErrorReport.report(
                nil,
                ("Coroutine Connection\nError: %s\nTraceback: %s"):format(err, debug.traceback(thread)),
                "error"
            )
        end
    end,
}

function Signal.new()
    local self = {}
    setmetatable(self, Signal)
    self._maid = Maid.new()
    --self._threads = {}
    self._waitEvent = self._maid:Add(Gaia.create("BindableEvent", {}))
    return self
end

function Signal:Connect(fn, connectionType)
    -- I believe deferred is the best default value as it keeps the bindable implementation.
    -- Need to check changes to quenty signal class and fast spawn.
    -- Quenty doesn't have fast spawn, I made my own.
    connectionType = connectionType or Connection.types.DeferredThread
    local connection = self._maid:Add(Connection.new(self, fn, connectionType))
    self._connListHead = connection
    return connection
end

function Signal:Fire(...)
    local conn = self._connListHead
    while conn do
        if conn._connected then conn:run(...) end
        conn = conn._next
    end

    self.args = {...}

    -- Need to wait all connections to finish
    self._waitEvent:Fire()
    -- self:_resumeThreads(...)
    -- self._threads = {}
end

-- function Signal:_resumeThreads(...)
--     for _, thread in ipairs(self._threads) do
--         coroutine.resume(thread, ...)
--     end
-- end

function Signal:Wait()
    self._waitEvent.Event:Wait()
    return unpack(self.args)
    -- table.insert(self._threads, coroutine.running())
    -- return coroutine.yield()
end

function Signal:Destroy()
    self._maid:Destroy()
end

return Signal