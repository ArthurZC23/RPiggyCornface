local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local FastSpawn = Mod:find({"FastSpawn"})
local Mts = Mod:find({"Table", "Mts"})

local Connection = {}
Connection.__index = Connection
Connection.className = "Connection"

Connection.types = {
    ["PCallback"] = "PCallback",
    ["DeferredThread"] = "DeferredThread",
    ["ImmediateThread"] = "ImmediateThread",
}
Connection.types = Mts.makeEnum("ConnectionTypes", Connection.types)

Connection._runMethods = {
    [Connection.types.PCallback] = function(fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then
            ErrorReport.report(nil, ("PCall connection\n%s"):format(err), "error")
        end
    end,
    [Connection.types.DeferredThread] = function(fn, ...)
        -- Fast spawn will be implemented with coroutines.
        -- So this is actually the Immediate Thread implementation!
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

function Connection.new(signal, fn, connectionType)
    local self = {
        _fn = fn,
        _next = signal._handlerListHead,
        _connectionType = Connection.types[connectionType],
        _connected = true,
        _runMethod = Connection._runMethods[connectionType],
    }
    setmetatable(self, Connection)

    return self
end

function Connection:Disconnect()
    assert(self._connected, "Can't disconnect a connection twice.")
    self._connected = false

    -- Remove from Linked List
    if self._signal._handlerListHead == self then
        self._signal._handlerListHead = self._next
    else
        local prev = self._signal._handlerListHead
        while prev and prev._next ~= self do
            prev = prev._next
        end
        if prev then
            prev._next = self._next
        end
    end
end

function Connection:run(...)
    self._runMethod(self._fn, ...)
end

function Connection:Destroy()
    self:Disconnect()
end

return Connection