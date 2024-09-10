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
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local TextCodec = Mod:find({"Codecs", "Text"})
local Codec = Mod:find({"Codecs", "Actions"})

local localPlayer = Players.LocalPlayer

local ActionsDecoders = {
    CharState = {
        Session = require(ReplicatedStorage.Actions.Char.Session.ActionsDataCodec.ActionsDataDecoder.ActionsDataDecoder),
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


local CharReplicatorC = {}
CharReplicatorC.__index = CharReplicatorC
CharReplicatorC.className = "CharReplicator"
CharReplicatorC.TAG_NAME = CharReplicatorC.className

function CharReplicatorC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        char = char,
        _maid = Maid.new(),
        binders = {}
    }
    setmetatable(self, CharReplicatorC)
    if not self:getFields() then return end
    self.stateManagers = {
        CharState = self.binders.CharState,
    }
    self:replicateEveryFrame()

    return self
end

function CharReplicatorC:replicateEveryFrame()
    self._maid:Add(self.remotes.SyncStates.OnClientEvent:Connect(function(compressedFrameActions, type)
        if type ~= "c" then return end
        -- print("[CharReplicatorC] Received Frame actions")
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

function CharReplicatorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            self.remotes = {
                ClientIsReadyForSync = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Events", "ClientIsReadyForSync"}),
                SyncStates = ComposedKey.getFirstDescendant(ReplicatedStorage, {"Remotes", "Events", "SyncStates"}),
            }
            if not self.remotes.ClientIsReadyForSync then return end
            if not self.remotes.SyncStates then return end

            local binders_ = {
                {"CharState", self.char},
            }
            for _, binderData in ipairs(binders_) do
                local binderName = binderData[1]
                local inst = binderData[2]
                self.binders[binderName] = SharedSherlock:find({"Binders", "getBinder"}, {tag=binderName}):getObj(inst)
                if not self.binders[binderName] then return end
            end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharReplicatorC:Destroy()
    self._maid:Destroy()
end

return CharReplicatorC