local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local Promise = Mod:find({"Promise", "Promise"})
local CharData = Data.Char.Char

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local CharRagdollS = {}
CharRagdollS.__index = CharRagdollS
CharRagdollS.className = "CharRagdoll"
CharRagdollS.TAG_NAME = CharRagdollS.className

function CharRagdollS.new(char)
    local player = PlayerUtils:GetPlayerFromCharacter(char)
    if not player then return end

    local self = {
        char = char,
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, CharRagdollS)

    if not self:getFields() then return end
    self:createRemotes()

    self:setRagdollJoints()

    return self
end

function CharRagdollS:setRagdollJoints()
    for _, joint in pairs(self.charParts.joints) do
        local att0 = GaiaShared.create("Attachment", {
            CFrame = joint.C0,
            Name = ("RagAtt0%s"):format(joint.Name),
        })
        local att1 = GaiaShared.create("Attachment", {
            CFrame = joint.C1,
            Name = ("RagAtt1%s"):format(joint.Name),
        })
        local socket = GaiaShared.create("BallSocketConstraint", {
            Name = ("%sRagdollSocket"):format(joint.Name),
            Attachment0 = att0,
            Attachment1 = att1,
            LimitsEnabled = true,
            TwistLimitsEnabled = true,
            Enabled = false,
        })

        att0.Parent = joint.Part0
        att1.Parent = joint.Part1
        socket.Parent = joint.Parent
    end
end

function CharRagdollS:createRemotes()
    local eventsNames = {"SetRagdoll"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        self[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function CharRagdollS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

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

function CharRagdollS:setRagdoll(isRagdoll, kwargs)
    if self.char:GetAttribute("Dead") and (not isRagdoll) then return end
    kwargs = kwargs or {}
    self.char:SetAttribute("isRagdoll", isRagdoll)
    for _, track in pairs(self.charParts.animator:GetPlayingAnimationTracks()) do
        track:Stop(0)
        -- Promise.fromEvent(track.DidLoop)
        --     :timeout(1)
        --     :finally(function()
        --         track:Stop(0)
        --     end)
    end
    self.SetRagdollRE:FireClient(self.player, isRagdoll, kwargs)
    for _, desc in ipairs(self.char:GetDescendants()) do
        if desc:IsA("Motor6D") and desc.Parent:GetAttribute("charLimb") then
            desc.Enabled = not isRagdoll
        elseif desc:IsA("BallSocketConstraint") then
            desc.Enabled = isRagdoll
        end
    end
end

function CharRagdollS:Destroy()
    self._maid:Destroy()
end

return CharRagdollS