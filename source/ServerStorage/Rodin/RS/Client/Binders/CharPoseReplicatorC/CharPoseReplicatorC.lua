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
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local localPlayer = Players.LocalPlayer

local CharPoseReplicatorC = {}
CharPoseReplicatorC.__index = CharPoseReplicatorC
CharPoseReplicatorC.className = "CharPoseReplicator"
CharPoseReplicatorC.TAG_NAME = CharPoseReplicatorC.className

function CharPoseReplicatorC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        char = char,
        _maid = Maid.new(),
        interval = 0.5,
        jointsData = {},
    }
    setmetatable(self, CharPoseReplicatorC)

    if not self:getFields() then return end
    self:replicate()
    self:replicateOtherChars()

    return self
end

function CharPoseReplicatorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            self.ReplicateOthersJointsRE = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Events", "ReplicateOthersJoints"})
            if not self.ReplicateOthersJointsRE then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharPoseReplicatorC:replicate()
    local timer = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(step)
        timer += step
        if timer > self.interval then
            timer = 0
            self.ReplicateOthersJointsRE:FireServer(self.jointsData)
        end
    end)

    self._maid:Add(conn)
end

function CharPoseReplicatorC:replicateOtherChars()
    self.ReplicateOthersJointsRE.OnClientEvent:Connect(function(char, jointsData)
        if not (char and char.Parent) then return end
        local charParts = binderCharParts:getObj(char)
        if not charParts then return end
        for jName, jData in pairs(jointsData) do
            local joint = charParts.joints[jName]
            local tween = TweenService:Create(
                joint,
                TweenInfo.new(
                    0.75 * self.interval,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out,
                    0,
                    false,
                    0
                ),
                jData.g
            )
            tween:Play()
        end
    end)
end

function CharPoseReplicatorC:Destroy()
    self._maid:Destroy()
end

return CharPoseReplicatorC