local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Server"})
local Maid = Mod:find({"Maid"})

local Replicator = {}
Replicator.__index = Replicator

Replicator.stateType = "Session"

function Replicator.new(playerSession)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Replicator)
    self.playerSession = playerSession
    self.player = playerSession.player
    self:createRemotes()
    self:replicate()
    return self
end

function Replicator:createRemotes()
    self._maid:Add(Gaia.createBinderRemotes(self, self.player, {
        functions={
            "RequestPlayerSessionReplica"
        },
    }))
end

function Replicator:replicate()
    local function _sendReplica(plr)
        if plr ~= self.player then return end
        local replica = self.playerSession.initialReplica
        self.playerSession.initialReplica = nil
        self.playerSession.playerState:updateReplicationConditions(Replicator.stateType)
        return replica
    end
    self.RequestPlayerSessionReplicaRF.OnServerInvoke = _sendReplica
end

function Replicator:sync(scope, action)
    self.playerSession.playerState.stateManagers:addFrame("PlayerState", Replicator.stateType, scope, action)
end

function Replicator:Destroy()
    self._maid:Destroy()
end

return Replicator