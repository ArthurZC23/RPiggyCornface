local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local FastMode = Mod:find({"FastMode", "Shared", "FastMode"})

local charsDistances = SharedSherlock:find({"Singletons", "async"}, {name="CharsDistances"})

local CharHeadMovementS = {}
CharHeadMovementS.__index = CharHeadMovementS
CharHeadMovementS.className = "CharHeadMovement"
CharHeadMovementS.TAG_NAME = CharHeadMovementS.className

function CharHeadMovementS.new(char)
    local player = Players:FindFirstChild(char.Name)
    if not player then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        player = player,
    }
    setmetatable(self, CharHeadMovementS)

    if not self:shouldReplicateHead() then return end
    if not self:getFields(player) then return end
    self:createRemotes()
    self:replicateHeadMovement()

    return self
end

function CharHeadMovementS:shouldReplicateHead()
    if Platforms.getPlatform() == Platforms.Platforms.Mobile then return false end
    if FastMode.isFastMode(self.player) then return false end
    return true
end

function CharHeadMovementS:replicateHeadMovement()
    self.ReplicateHeadJointRE.OnServerEvent:Connect(function(player, neckC0)
        -- print("H1")
        if self.player ~= player then return end

        local targetCharsIter = charsDistances:getCharsWithDistLTE(self.char, 100, {
            function(targetCharData, conditionsResults)
                -- print("H1_2")
                local ReplicateHeadJointRE = ComposedKey.getFirstDescendant(targetCharData.char, {"Remotes", "Events", "ReplicateHeadJoint"})
                if ReplicateHeadJointRE then
                    -- print("H1_3")
                    conditionsResults.ReplicateHeadJointRE = ReplicateHeadJointRE
                    return true
                end
            end
        })
        if not targetCharsIter then return end

        -- print("H2")
        for _, _, targetCharData, conditionsResults in targetCharsIter do
            -- print("H3")
            local ReplicateHeadJointRE = conditionsResults.ReplicateHeadJointRE
            -- if player.Name == "Player1" then
            --     TableUtils.print(targetCharData)
            --     TableUtils.print(conditionsResults)
            --     print(ReplicateHeadJointRE:GetFullName())
            -- end
            -- wrong
            ReplicateHeadJointRE:FireClient(targetCharData.plr, self.char, neckC0)
        end
    end)
end

function CharHeadMovementS:createRemotes()
    local eventsNames = {"ReplicateHeadJoint"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        CharHeadMovementS[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function CharHeadMovementS:getFields(player)
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

function CharHeadMovementS:Destroy()
    self._maid:Destroy()
end

return CharHeadMovementS