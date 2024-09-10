local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local TextCodec = Mod:find({"Codecs", "Text"})

local binderCharStateManagers = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharStateManagers"})

local function compress(frameActions)
    local json = HttpService:JSONEncode(frameActions)
    return TextCodec.compress(json)
end

local CharReplicatorS = {}
CharReplicatorS.__index = CharReplicatorS
CharReplicatorS.className = "CharReplicator"
CharReplicatorS.TAG_NAME = CharReplicatorS.className

CharReplicatorS.replicationBuffer = {}

local SyncStatesRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "SyncStates"})
RunService.Heartbeat:Connect(function()
    for char in pairs(CharReplicatorS.replicationBuffer) do
        local charStateManagers = binderCharStateManagers:getObj(char)
        if not charStateManagers then continue end
        for stateManager, canReplicate in pairs(charStateManagers.canReplicateState) do
            if not canReplicate then continue end
            SyncStatesRE:FireClient(charStateManagers.player, compress(charStateManagers.frameActions[stateManager]), "c") -- problem found
            table.clear(charStateManagers.frameActions[stateManager])
        end
    end
end)

function CharReplicatorS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharReplicatorS)
    if not self:getFields() then return end
    self:addToReplicationBuffer(char)

    return self
end

function CharReplicatorS:addToReplicationBuffer(char)
    CharReplicatorS.replicationBuffer[char] = {}
    self._maid:Add(function()
        CharReplicatorS.replicationBuffer[char] = nil
    end)
end

function CharReplicatorS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharReplicatorS:Destroy()
    self._maid:Destroy()
end

return CharReplicatorS