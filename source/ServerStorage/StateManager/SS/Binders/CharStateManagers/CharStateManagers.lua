local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Codec = Mod:find({"Codecs", "Actions"})
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local ActionsEncoders = {
    CharState = {
        Session = require(ReplicatedStorage.Actions.Char.Session.ActionsDataCodec.ActionsDataEncoder.ActionsDataEncoder),
    },
}

local Gaia = Mod:find({"Gaia", "Server"})

local CharStateManagers = {}
CharStateManagers.__index = CharStateManagers
CharStateManagers.className = "CharStateManagers"
CharStateManagers.TAG_NAME = CharStateManagers.className

function CharStateManagers.new(char)
    local player = PlayerUtils:GetPlayerFromCharacter(char)
    if not player then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        player = player,
    }
    setmetatable(self, CharStateManagers)

    if not self:getFields() then return end
    self:createRemotes()

    self.stateReplicationConditions = {
        isClientListening = false,
        CharState = false,
    }

    self.canReplicateState = {
        CharState = false,
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

function CharStateManagers:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    local updateCanReplicateState = {
        CharState = function()
            return self.stateReplicationConditions.isClientListening and self.stateReplicationConditions.CharState
        end,
    }
    for stateManager in pairs(updateCanReplicateState) do
        if self.canReplicateState[stateManager] == true then continue end
        self.canReplicateState[stateManager] = updateCanReplicateState[stateManager]()
    end
end

function CharStateManagers:addFrame(stateManager, stateType, scope, action)
    local _action = TableUtils.deepCopy(action)
    local encoder = ActionsEncoders[stateManager][stateType][scope]
    if encoder and encoder[_action.name] then _action = encoder[_action.name](_action) end
    _action.name = nil
    table.insert(self.frameActions[stateManager], {Codec.encode(stateManager, stateType, scope, action.name), _action})
end

function CharStateManagers:createRemotes()
    Gaia.createRemotes(self.charEvents, {
        events = {"ClientIsReadyForSync"}
    })
    self.ClientIsReadyForSyncRE = self.charEvents.Remotes.Events.ClientIsReadyForSync
end

function CharStateManagers:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharStateManagers:Destroy()
    self._maid:Destroy()
end

return CharStateManagers