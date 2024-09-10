local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local GaiaServer = Mod:find({"Gaia", "Server"})
local TextCodec = Mod:find({"Codecs", "Text"})
local TableUtils = Mod:find({"Table", "Utils"})

local binderPlayerStateManagers = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerStateManagers"})
GaiaServer.createRemotes(ReplicatedStorage, {
    events = {
        "SyncStates"
    },
})

local function compress(frameActions)
    -- TableUtils.print(frameActions)
    local json = HttpService:JSONEncode(frameActions)
    return TextCodec.compress(json)
end

local PlayerReplicatorS = {}
PlayerReplicatorS.__index = PlayerReplicatorS
PlayerReplicatorS.className = "PlayerReplicator"
PlayerReplicatorS.TAG_NAME = PlayerReplicatorS.className

PlayerReplicatorS.replicationBuffer = {}

local SyncStatesRE = ReplicatedStorage.Remotes.Events.SyncStates
RunService.Heartbeat:Connect(function()
    for player in pairs(PlayerReplicatorS.replicationBuffer) do
        local playerStateManagers = binderPlayerStateManagers:getObj(player)
        if not playerStateManagers then continue end
        for stateManager, canReplicate in pairs(playerStateManagers.canReplicateState) do
            if not canReplicate then continue end
            SyncStatesRE:FireClient(player, compress(playerStateManagers.frameActions[stateManager]), "p") -- problem found
            table.clear(playerStateManagers.frameActions[stateManager])
        end
    end
end)

function PlayerReplicatorS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerReplicatorS)
    if not self:getFields() then return end
    self:addToReplicationBuffer(player)

    return self
end

function PlayerReplicatorS:addToReplicationBuffer(player)
    PlayerReplicatorS.replicationBuffer[player] = {}
    self._maid:Add(function()
        PlayerReplicatorS.replicationBuffer[player] = nil
    end)
end

function PlayerReplicatorS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerReplicatorS:Destroy()
    self._maid:Destroy()
end

return PlayerReplicatorS