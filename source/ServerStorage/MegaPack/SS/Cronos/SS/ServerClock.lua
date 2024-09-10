local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ParentF = script:FindFirstAncestor("SS")
local ServerTimeSync = require(ParentF.ServerTimeSync)

local Gaia = Mod:find({"Gaia", "Server"})

Gaia.createRemotes(ReplicatedStorage, {
    functions={
        "ClockSync",
    },
})

local ClockSyncRF = ReplicatedStorage.Remotes.Functions.ClockSync

local ServerClock = {}
ServerClock.__index = ServerClock
ServerClock.className = "ServerClock"

function ServerClock.new()
    local self = {}
    setmetatable(self, ServerClock)

    self.serverSync = ServerTimeSync.new()
    ClockSyncRF.OnServerInvoke = function(_, t0) return self:handleClockRequest(t0) end
    return self
end

function ServerClock:getTime()
    return self.serverSync:getTime()
end

function ServerClock:isServerTimeSynced()
    return self.serverSync.isServerSynced
end

function ServerClock:handleClockRequest()
    return self.serverSync:getTime()
end

function ServerClock:Destroy()

end

return ServerClock