local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TextCodec = Mod:find({"Codecs", "Text"})
local Codec = Mod:find({"Codecs", "Actions"})

local localPlayer = Players.LocalPlayer

local ActionsDecoders = {
    PlayerGameState = {
        Session = require(ReplicatedStorage.Actions.Game.Session.ActionsDataCodec.ActionsDataDecoder.ActionsDataDecoder),
    },
    PlayerState = {
        Session = require(ReplicatedStorage.Actions.Player.Session.ActionsDataCodec.ActionsDataDecoder.ActionsDataDecoder),
        Stores = require(ReplicatedStorage.Actions.Player.Stores.ActionsDataCodec.ActionsDataDecoder.ActionsDataDecoder),
    },
}

local function actionDecode(stateManager, stateType, scope, action)
    local decoder = ActionsDecoders[stateManager][stateType][scope]
    if decoder and decoder[action.name] then return decoder[action.name](action) end
    return action
end

local function decompress(compressedFrameActions)
    local json = TextCodec.decompress(compressedFrameActions)
    return HttpService:JSONDecode(json)
end

local PlayerReplicatorC = {}
PlayerReplicatorC.__index = PlayerReplicatorC
PlayerReplicatorC.className = "PlayerReplicator"
PlayerReplicatorC.TAG_NAME = PlayerReplicatorC.className

function PlayerReplicatorC.new(player)
    if localPlayer ~= player then return end

    local self = {
        _maid = Maid.new(),
        binders = {}
    }
    setmetatable(self, PlayerReplicatorC)
    if not self:getFields() then return end
    self.stateManagers = {
        PlayerState = self.binders.PlayerState,
        PlayerGameState = self.binders.PlayerGameState,
    }
    self:replicateEveryFrame()

    return self
end

function PlayerReplicatorC:replicateEveryFrame()
    self._maid:Add(self.remotes.SyncStates.OnClientEvent:Connect(function(compressedFrameActions, type)
        if type ~= "p" then return end
        -- print("[PlayerReplicatorC] Received Frame actions")
        -- print(TableUtils.print(frameActions))
        for _, compressedAction in ipairs(decompress(compressedFrameActions)) do
            local stateManager, stateType, scope, actionName = unpack(Codec.decode(compressedAction[1]))
            local action = compressedAction[2]
            action.name = actionName
            action = actionDecode(stateManager, stateType, scope, action)
            --print(stateType, scope, action.name)
            --print("sync", stateManager, stateType, scope, action)
            self.stateManagers[stateManager]:sync(stateType, scope, action)
        end
    end))
    self.remotes.ClientIsReadyForSync:FireServer()
end

function PlayerReplicatorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.remotes = {
                ClientIsReadyForSync = ComposedKey.getFirstDescendant(localPlayer, {"Remotes", "Events", "ClientIsReadyForSync"}),
                SyncStates = ComposedKey.getFirstDescendant(ReplicatedStorage, {"Remotes", "Events", "SyncStates"}),
            }
            if not self.remotes.ClientIsReadyForSync then return end
            if not self.remotes.SyncStates then return end

            local binders = {
                {"PlayerState", localPlayer},
                {"PlayerGameState", localPlayer},
            }
            for _, binderData in ipairs(binders) do
                local binderName = binderData[1]
                local inst = binderData[2]
                self.binders[binderName] = SharedSherlock:find({"Binders", "getBinder"}, {tag=binderName}):getObj(inst)
                if not self.binders[binderName] then return end
            end

            return true
        end,
        keepTrying=function()
            return localPlayer.Parent
        end,
    })
    return ok
end

function PlayerReplicatorC:Destroy()
    self._maid:Destroy()
end

return PlayerReplicatorC