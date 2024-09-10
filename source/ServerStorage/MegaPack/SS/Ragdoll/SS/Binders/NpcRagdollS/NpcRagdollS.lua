local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaServer = Mod:find({"Gaia", "Server"})
local ArrayIterators = Mod:find({"Iterators", "Array"})
local Promise = Mod:find({"Promise", "Promise"})
local CharData = Data.Char.Char

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local NpcRagdollS = {}
NpcRagdollS.__index = NpcRagdollS
NpcRagdollS.className = "NpcRagdoll"
NpcRagdollS.TAG_NAME = NpcRagdollS.className

function NpcRagdollS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, NpcRagdollS)

    if not self:getFields() then return end
    -- self:createRemotes()

    self:setRagdollJoints()

    return self
end

function NpcRagdollS:setRagdollJoints()
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

function NpcRagdollS:createRemotes()
    local eventsNames = {"SetRagdoll"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        self[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function NpcRagdollS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end


function NpcRagdollS:setRagdoll(isRagdoll)
    for _, desc in ipairs(self.char:GetDescendants()) do
        if desc:IsA("Motor6D") and desc.Parent:GetAttribute("charLimb") then
            desc.Enabled = not isRagdoll
        elseif desc:IsA("BallSocketConstraint") then
            desc.Enabled = isRagdoll
        end
    end

    if isRagdoll then
        self.charParts.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        self.charParts.humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        for _, track in pairs(self.charParts.animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
            -- Promise.fromEvent(track.DidLoop)
            --     :timeout(1)
            --     :finally(function()
            --         track:Stop(0)
            --     end)
        end
    else
        self.charParts.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        self.charParts.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    -- local bodyVelocity = GaiaShared.create("BodyVelocity", {
    --     Velocity = Vector3.new(Random.new():NextInteger(-10, 10), 0, Random.new():NextInteger(-10, 10)),
    --     Parent = self.charParts.head,
    -- })
    -- Debris:AddItem(bodyVelocity, 0.1)
end

function NpcRagdollS:Destroy()
    self._maid:Destroy()
end

return NpcRagdollS