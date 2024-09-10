local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Server"})
local Maid = Mod:find({"Maid"})

local Replicator = {}
Replicator.__index = Replicator

Replicator.stateType = "Stores"

function Replicator.new(playerStores)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Replicator)
    self.playerStores = playerStores
    self.player = playerStores.player
    self:createRemotes()
    self:replicate()
    return self
end

function Replicator:createRemotes()
    self._maid:Add(Gaia.createBinderRemotes(self, self.player, {
        functions={
            "RequestPlayerStoresReplica"
        },
    }))
end

function Replicator:replicate()
    local function _sendReplica(plr)
        if plr ~= self.player then return end
        local replica = self.playerStores.initialReplica
        self.playerStores.initialReplica = nil
        self.playerStores.playerState:updateReplicationConditions(Replicator.stateType)
        return replica
    end
    self.RequestPlayerStoresReplicaRF.OnServerInvoke = _sendReplica
end

function Replicator:sync(scope, action)
    self.playerStores.playerState.stateManagers:addFrame("PlayerState", Replicator.stateType, scope, action)
end

function Replicator:Destroy()
    self._maid:Destroy()
end

return Replicator