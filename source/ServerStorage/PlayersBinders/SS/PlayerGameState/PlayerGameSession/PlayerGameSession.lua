local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local ClientRequests = require(script.Parent.ClientRequests)
local Replicator = require(script.Parent.Replicator)

local PlayerGameSession = {}
PlayerGameSession.__index = PlayerGameSession
PlayerGameSession.className = "PlayerGameSession"
PlayerGameSession.TAG_NAME = PlayerGameSession.className

function PlayerGameSession.new(playerGameState)
    local self = {}
    setmetatable(self, PlayerGameSession)
    self.playerGameState = playerGameState
    self.player = playerGameState.player
    self._maid = Maid.new()
    self._replicator = self._maid:Add(Replicator.new(self))
    self._clientRequests = self._maid:Add(ClientRequests.new(self))

    return self
end

function PlayerGameSession:Destroy()
    self._maid:Destroy()
end

return PlayerGameSession
