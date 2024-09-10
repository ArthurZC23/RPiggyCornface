local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local charsDistances = SharedSherlock:find({"Singletons", "async"}, {name="CharsDistances"})

local CharPoseReplicatorS = {}
CharPoseReplicatorS.__index = CharPoseReplicatorS
CharPoseReplicatorS.className = "CharPoseReplicator"
CharPoseReplicatorS.TAG_NAME = CharPoseReplicatorS.className

function CharPoseReplicatorS.new(char)
    local player = Players:FindFirstChild(char.Name)
    if not player then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        player = player,
    }
    setmetatable(self, CharPoseReplicatorS)

    if not self:getFields(player) then return end

    self:createRemotes()
    self:replicatePose()

    return self
end

function CharPoseReplicatorS:getFields(player)
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

function CharPoseReplicatorS:createRemotes()
    local eventsNames = {"ReplicateOthersJoints"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        CharPoseReplicatorS[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function CharPoseReplicatorS:replicatePose()
    self.ReplicateOthersJointsRE.OnServerEvent:Connect(function(player, jointsData)
        if self.player ~= player then return end
        local targetCharsIter = charsDistances:getCharsWithDistLTE(self.char, 100, {
            function(targetCharData, conditionsResults)
                local ReplicateOthersJointsRE = ComposedKey.getFirstDescendant(targetCharData.char, {"Remotes", "Events", "ReplicateOthersJoints"})
                if ReplicateOthersJointsRE then
                    conditionsResults.ReplicateOthersJointsRE = ReplicateOthersJointsRE
                    return true
                end
            end
        })
        if not targetCharsIter then return end

        for _, _, targetCharData, conditionsResults in targetCharsIter do
            local ReplicateOthersJointsRE = conditionsResults.ReplicateOthersJointsRE
            ReplicateOthersJointsRE:FireClient(targetCharData.plr, self.char, jointsData)
        end
    end)
end

function CharPoseReplicatorS:Destroy()
    self._maid:Destroy()
end

return CharPoseReplicatorS