local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local FastMode = Mod:find({"FastMode", "Shared", "FastMode"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})
local binderCharPoseReplicator = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharPoseReplicator"})

local camera = workspace.CurrentCamera

local CharHeadMovementC = {}
CharHeadMovementC.__index = CharHeadMovementC
CharHeadMovementC.className = "CharHeadMovement"
CharHeadMovementC.TAG_NAME = CharHeadMovementC.className

function CharHeadMovementC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    if FastMode.isFastMode or Platforms.getPlatform() == Platforms.Platforms.Mobile then
        return
    end

    local self = {
        char = char,
        _maid = Maid.new(),
        interval = 0.5,
    }
    setmetatable(self, CharHeadMovementC)

    if not self:getFields() then return end
    if self.charParts.humanoid.RigType == Enum.HumanoidRigType.R15 then
        self:updateHeadR15()
    elseif self.charParts.humanoid.RigType == Enum.HumanoidRigType.R6 then
        self:updateHeadR6()
    end
    self:replicateOtherChars()

    return self
end

function CharHeadMovementC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            self.charPoseReplicator = binderCharPoseReplicator:getObj(self.char)
            if not self.charPoseReplicator then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            self.ReplicateHeadJointRE = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Events", "ReplicateHeadJoint"})
            if not self.ReplicateHeadJointRE then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharHeadMovementC:updateHeadR15()
    local hrp = self.charParts.hrp
    local neck = self.charParts.joints.neck
    local yOffset = neck.C0.Y
    local conn
    local timer = 0
    conn = RunService.Stepped:Connect(function(_, step)
        local cameraDir = hrp.CFrame:toObjectSpace(camera.CFrame).lookVector
        neck.C0 =
            CFrame.new(0, yOffset, 0)
            * CFrame.Angles(0, -math.asin(cameraDir.X), 0)
            * CFrame.Angles(math.asin(cameraDir.Y), 0, 0)

        self.charPoseReplicator.jointsData["neck"] = {
            g = {
                C0 = neck.C0,
            },
        }
        -- timer += step
        -- if timer > self.interval then
        --     timer = 0
        --     self.ReplicateHeadJointRE:FireServer(neck.C0)
        -- end
    end)
    self._maid:Add(conn)
end

function CharHeadMovementC:updateHeadR6()
    local hrp = self.charParts.hrp
    local neck = self.charParts.joints.neck
    local yOffset = neck.C0.Y
    local conn
    local timer = 0
    conn = RunService.Stepped:Connect(function(_, step)
        local cameraDir = hrp.CFrame:toObjectSpace(camera.CFrame).lookVector
        neck.C0 =
            CFrame.new(0, yOffset, 0)
            * CFrame.Angles(3 * math.pi / 2, 0, math.pi)
            * CFrame.Angles(0, 0, -math.asin(cameraDir.X))
            * CFrame.Angles(-math.asin(cameraDir.Y), 0, 0)

        self.charPoseReplicator.jointsData["neck"] = {
            g = {
                C0 = neck.C0,
            },
        }
        -- timer += step
        -- if timer > self.interval then
        --     timer = 0
        --     self.ReplicateHeadJointRE:FireServer(neck.C0)
        -- end
    end)
    self._maid:Add(conn)
end

function CharHeadMovementC:replicateOtherChars()
    self.ReplicateHeadJointRE.OnClientEvent:Connect(function(char, neckC0)
        -- print(char)
        -- print("H4")
        if not (char and char.Parent) then return end
        -- print("H5")
        local charParts = binderCharParts:getObj(char)
        if not charParts then return end
        local neck = charParts.joints.neck
        local tween = TweenService:Create(
            neck,
            TweenInfo.new(
                0.75 * self.interval,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            ),
            {
                C0 = neckC0
            }
        )
        tween:Play()
    end)
end

function CharHeadMovementC:Destroy()
    self._maid:Destroy()
end

return CharHeadMovementC