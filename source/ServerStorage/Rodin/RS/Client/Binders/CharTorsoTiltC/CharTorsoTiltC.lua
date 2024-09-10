local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local Data = Mod:find({"Data", "Data"})
local CharData = Data.Char.Char
local S = Data.Strings.Strings
local Math = Mod:find({"Math", "Math"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})
local binderPlayerFps = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerFps"})
local binderCharPoseReplicator = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharPoseReplicator"})

local CharTorsoTiltC = {}
CharTorsoTiltC.__index = CharTorsoTiltC
CharTorsoTiltC.className = "CharTorsoTilt"
CharTorsoTiltC.TAG_NAME = CharTorsoTiltC.className

function CharTorsoTiltC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        char = char,
        _maid = Maid.new(),
        interval = 0.5,
    }
    setmetatable(self, CharTorsoTiltC)

    if not self:getFields() then return end
    if self.charParts.humanoid.RigType == Enum.HumanoidRigType.R15 then
        -- self:updatePoseR15()
    elseif self.charParts.humanoid.RigType == Enum.HumanoidRigType.R6 then
        self:updatePoseR6()
    end
    self:replicateOtherChars()

    return self
end

function CharTorsoTiltC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            self.charPoseReplicator = binderCharPoseReplicator:getObj(self.char)
            if not self.charPoseReplicator then return end

            self.playerFps = binderPlayerFps:getObj(localPlayer)
            if not self.playerFps then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            self.ReplicateRootJointRE = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Events", "ReplicateRootJoint"})
            if not self.ReplicateRootJointRE then return end

            self.c00 = self.charParts.joints.rootJoint.C0

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharTorsoTiltC:updatePoseR15()

end

function CharTorsoTiltC:updatePoseR6()
    local hrp = self.charParts.hrp
    local rootJoint = self.charParts.joints.rootJoint
    local humanoid = self.charParts.humanoid
    local conn
    local timer = 0

    local c00 = rootJoint.C0
    local tilt = CFrame.new()
    local baseTilt = tilt
    local MaxTiltAngle = 8

    local lastMoveVector = hrp.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
    local moveVector = hrp.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
    local totalDuration = 0.2
    local duration = totalDuration

    conn = RunService.Stepped:Connect(function(_, step)
        moveVector = hrp.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
        local maxTiltAngle = math.min(0 + ((humanoid.WalkSpeed / CharData.speed.default) * MaxTiltAngle), MaxTiltAngle)

        if (moveVector - lastMoveVector).Magnitude > 0.1 then
            duration = 0
            baseTilt = tilt
            lastMoveVector = moveVector
        elseif duration < totalDuration then
            duration = math.min(duration + step, totalDuration)
            tilt = baseTilt:Lerp(
                CFrame.Angles(
                    math.rad(-lastMoveVector.Z) * maxTiltAngle,
                    math.rad(-lastMoveVector.X) * maxTiltAngle,
                    0
                ),
                duration / totalDuration
            )
        end
        rootJoint.C0 = c00 * tilt

        self.charPoseReplicator.jointsData["rootJoint"] = {
            g = {
                C0 = rootJoint.C0,
            },
        }
        -- timer += step
        -- if timer > self.interval then
        --     timer = 0
        --     self.ReplicateRootJointRE:FireServer(rootJoint.C0)
        -- end
    end)

    self._maid:Add(conn)

end

function CharTorsoTiltC:replicateOtherChars()
    self.ReplicateRootJointRE.OnClientEvent:Connect(function(char, C0)
        if not (char and char.Parent) then return end
        local charParts = binderCharParts:getObj(char)
        if not charParts then return end
        local rootJoint = charParts.joints.rootJoint
        local tween = TweenService:Create(
            rootJoint,
            TweenInfo.new(
                0.75 * self.interval,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            ),
            {
                C0 = C0
            }
        )
        tween:Play()
    end)
end

function CharTorsoTiltC:Destroy()
    self._maid:Destroy()
end

return CharTorsoTiltC