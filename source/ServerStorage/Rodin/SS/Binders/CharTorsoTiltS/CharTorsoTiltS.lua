local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local charsDistances = SharedSherlock:find({"Singletons", "async"}, {name="CharsDistances"})

local CharTorsoTiltS = {}
CharTorsoTiltS.__index = CharTorsoTiltS
CharTorsoTiltS.className = "CharTorsoTilt"
CharTorsoTiltS.TAG_NAME = CharTorsoTiltS.className

function CharTorsoTiltS.new(char)
    local player = Players:FindFirstChild(char.Name)
    if not player then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        player = player,
    }
    setmetatable(self, CharTorsoTiltS)

    do
        local ok = self:getFields(player)
        if not ok then return end
    end
    self:createRemotes()
    self:replicatePose()

    return self
end

function CharTorsoTiltS:getFields(player)
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


function CharTorsoTiltS:createRemotes()
    local eventsNames = {"ReplicateRootJoint"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        CharTorsoTiltS[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function CharTorsoTiltS:replicatePose()
    self.ReplicateRootJointRE.OnServerEvent:Connect(function(player, neckC0)
        if self.player ~= player then return end

        local targetCharsIter = charsDistances:getCharsWithDistLTE(self.char, 100, {
            function(targetCharData, conditionsResults)
                local ReplicateRootJointRE = ComposedKey.getFirstDescendant(targetCharData.char, {"Remotes", "Events", "ReplicateRootJoint"})
                if ReplicateRootJointRE then
                    conditionsResults.ReplicateRootJointRE = ReplicateRootJointRE
                    return true
                end
            end
        })
        if not targetCharsIter then return end

        for _, _, targetCharData, conditionsResults in targetCharsIter do
            local ReplicateRootJointRE = conditionsResults.ReplicateRootJointRE
            ReplicateRootJointRE:FireClient(targetCharData.plr, self.char, neckC0)
        end
    end)
end

function CharTorsoTiltS:Destroy()
    self._maid:Destroy()
end

return CharTorsoTiltS