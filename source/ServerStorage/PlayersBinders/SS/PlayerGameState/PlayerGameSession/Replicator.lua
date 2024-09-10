local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local TableUtils = Mod:find({"Table", "Utils"})

local Gaia = Mod:find({"Gaia", "Server"})

local Replicator = {}
Replicator.__index = Replicator

Replicator.stateType = "Session"

function Replicator.new(playerGameSession)
    local self = {}
    setmetatable(self, Replicator)
    self.playerGameSession = playerGameSession
    self.player = playerGameSession.player
    self:createRemotes()


    local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
    local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})
    gameState:getAllEvents("Session"):Connect(function(scope, action) self:sync(scope, action) end)
    self.initialReplica = TableUtils.deepCopy(gameState._stateTypes[Replicator.stateType].states)

    self:replicate()
    return self
end

function Replicator:createRemotes()
    Gaia.createRemotes(self.player, {
        functions={
            "RequestGameSessionReplica",
        },
    })
    self.RequestGameSessionReplicaRF = self.player.Remotes.Functions.RequestGameSessionReplica
end

function Replicator:replicate()
    local function _sendReplica(plr)
        if plr ~= self.player then return end
        self.playerGameSession.playerGameState:updateReplicationConditions(Replicator.stateType)
        return self.initialReplica
    end
    self.RequestGameSessionReplicaRF.OnServerInvoke = _sendReplica
end

function Replicator:sync(scope, action)
    ---- The action should be sent immediately to avoid lag. In the client, the actions are only processed after the initial state is processes
    self.playerGameSession.playerGameState.stateManagers:addFrame("PlayerGameState", Replicator.stateType, scope, action)
end

function Replicator:Destroy()

end


return Replicator