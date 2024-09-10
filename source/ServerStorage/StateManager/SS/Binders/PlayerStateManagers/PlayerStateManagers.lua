local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Codec = Mod:find({"Codecs", "Actions"})
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsEncoders = {
    PlayerGameState = {
        Session = require(ReplicatedStorage.Actions.Game.Session.ActionsDataCodec.ActionsDataEncoder.ActionsDataEncoder),
    },
    PlayerState = {
        Session = require(ReplicatedStorage.Actions.Player.Session.ActionsDataCodec.ActionsDataEncoder.ActionsDataEncoder),
        Stores = require(ReplicatedStorage.Actions.Player.Stores.ActionsDataCodec.ActionsDataEncoder.ActionsDataEncoder),
    },
}

local Gaia = Mod:find({"Gaia", "Server"})

local PlayerStateManagers = {}
PlayerStateManagers.__index = PlayerStateManagers
PlayerStateManagers.className = "PlayerStateManagers"
PlayerStateManagers.TAG_NAME = PlayerStateManagers.className

function PlayerStateManagers.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerStateManagers)

    self:createRemotes()

    self.stateReplicationConditions = {
        isClientListening = false,
        PlayerState = false,
        PlayerGameState = false,
    }

    self.canReplicateState = {
        PlayerState = false,
        PlayerGameState = false,
    }

    self.ClientIsReadyForSyncRE.OnServerEvent:Connect(function()
        self:updateReplicationConditions("isClientListening")
    end)

    self.frameActions = {}
    for stateManager in pairs(self.canReplicateState) do
        self.frameActions[stateManager] = {}
    end

    return self
end

function PlayerStateManagers:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    local updateCanReplicateState = {
        PlayerState = function()
            return self.stateReplicationConditions.isClientListening and self.stateReplicationConditions.PlayerState
        end,
        PlayerGameState = function()
            return self.stateReplicationConditions.isClientListening and self.stateReplicationConditions.PlayerGameState
        end,
    }
    for stateManager in pairs(updateCanReplicateState) do
        if self.canReplicateState[stateManager] == true then continue end
        self.canReplicateState[stateManager] = updateCanReplicateState[stateManager]()
    end
end

function PlayerStateManagers:addFrame(stateManager, stateType, scope, action)
    local _action = TableUtils.deepCopy(action)
    local encoder = ActionsEncoders[stateManager][stateType][scope]
    if encoder and encoder[_action.name] then _action = encoder[_action.name](_action) end
    _action.name = nil
    table.insert(self.frameActions[stateManager], {Codec.encode(stateManager, stateType, scope, action.name), _action})
end

function PlayerStateManagers:createRemotes()
    Gaia.createRemotes(self.player, {
        events = {"ClientIsReadyForSync"}
    })
    self.ClientIsReadyForSyncRE = self.player.Remotes.Events.ClientIsReadyForSync
end

function PlayerStateManagers:Destroy()
    self._maid:Destroy()
end

return PlayerStateManagers