local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local ParentF = script:FindFirstAncestor("Client")
local ClientTimeSync = require(ParentF.ClientTimeSync)

local ClientClock = {}
ClientClock.__index = ClientClock
ClientClock.className = "ClientClock"

function ClientClock.new()
    local self = {}
    setmetatable(self, ClientClock)
    self._maid = Maid.new()
    self.clientSync = self._maid:Add(ClientTimeSync.new())
    return self
end

function ClientClock:getPing()
    return 0.5 * self.clientSync.roundTrip.movingAverage
end

function ClientClock:getRoundTripTime()
    return self.clientSync.roundTrip.movingAverage
end

function ClientClock:getTime()
	return self.clientSync:getTime()
end

function ClientClock:Destroy()
    self._maid:Destroy()
end

return ClientClock