local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharData = Data.Char.Char
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

local CharPartsC = {}
CharPartsC.__index = CharPartsC
CharPartsC.className = "CharParts"
CharPartsC.TAG_NAME = CharPartsC.className

function CharPartsC.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharPartsC)

    if not self:getFields() then return end

    return self
end

function CharPartsC:getFields()
    local str1 = ("Local Player: %s"):format(localPlayer:GetFullName())
    local str2 = ("Target: %s"):format(self.char:GetFullName())
    local str = table.concat({str1, str2}, "\n")
    return WaitFor.GetAsync({
        getter=function()
            if not self.char.Parent then return nil, "char" end

            self.charId = self.char:GetAttribute("uid")
            if not self.charId then return nil, "uid" end

            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return nil, "rigType" end

            if CharUtils.isPChar(self.char) then
                self.player = Players:GetPlayerFromCharacter(self.char)
                if not self.player then return nil, "Player" end
            end

            self.hrp = self.char:FindFirstChild("HumanoidRootPart")
            if not self.hrp then return nil, "HumanoidRootPart" end

            self.humanoid = self.char:FindFirstChild("Humanoid")
            if not self.humanoid then return nil, "Humanoid" end

            self.animator = self.humanoid:FindFirstChild("Animator")
            if not self.animator then return nil, "Animator" end

            if self.rigType == "R6" then
                -- self.bodyColors = self.char:FindFirstChild("Body Colors")
                -- if not self.bodyColors then return nil, "Body Colors" end

                -- self.shirt = self.char:FindFirstChild("Shirt")
                -- if not self.shirt then return nil, "Shirt" end
                -- self.pants = self.char:FindFirstChild("Pants")
                -- if not self.pants then return nil, "Pants" end

                self.head = self.char:FindFirstChild("Head")
                if not self.head then return nil, "Head" end

                self.torso = self.char:FindFirstChild("Torso")
                if not self.torso then return nil, "Torso" end

                self.leftLeg = self.char:FindFirstChild("Left Leg")
                if not self.leftLeg then return nil, "Left Leg" end

                self.rightLeg = self.char:FindFirstChild("Right Leg")
                if not self.rightLeg then return nil, "Right Leg" end

                self.leftArm = self.char:FindFirstChild("Left Arm")
                if not self.leftArm then return nil, "Left Arm" end

                self.rightArm = self.char:FindFirstChild("Right Arm")
                if not self.rightArm then return nil, "Right Arm" end

                self.joints = {}
                for jName, jData in pairs(CharData[("joints%s"):format(self.rigType)]) do
                    local joint = self[jData.ParentName]:FindFirstChild(jData.instName)
                    if not joint then return nil, ("Joint %s"):format(jData.instName) end
                    self.joints[jName] = joint
                end
            elseif self.rigType == "R15" then
                -- self.bodyColors = self.char:FindFirstChild("Body Colors")
                -- if not self.bodyColors then return nil, "Body Colors" end

                -- self.shirt = self.char:FindFirstChild("Shirt")
                -- if not self.shirt then return nil, "Shirt" end
                -- self.pants = self.char:FindFirstChild("Pants")
                -- if not self.pants then return nil, "Pants" end

                self.head = self.char:FindFirstChild("Head")
                if not self.head then return nil, "Head" end

                self.lowerTorso = self.char:FindFirstChild("LowerTorso")
                if not self.lowerTorso then return nil, "LowerTorso" end

                self.leftFoot = self.char:FindFirstChild("LeftFoot")
                if not self.leftFoot then return nil, "LeftFoot" end

                self.leftHand = self.char:FindFirstChild("LeftHand")
                if not self.leftHand then return nil, "LeftHand" end

                self.leftLowerArm = self.char:FindFirstChild("LeftLowerArm")
                if not self.leftLowerArm then return nil, "LeftLowerArm" end

                self.leftLowerLeg = self.char:FindFirstChild("LeftLowerLeg")
                if not self.leftLowerLeg then return nil, "LeftLowerLeg" end

                self.leftUpperArm = self.char:FindFirstChild("LeftUpperArm")
                if not self.leftUpperArm then return nil, "LeftUpperArm" end

                self.leftUpperLeg = self.char:FindFirstChild("LeftUpperLeg")
                if not self.leftUpperLeg then return nil, "LeftUpperLeg" end

                self.rightFoot = self.char:FindFirstChild("RightFoot")
                if not self.rightFoot then return nil, "RightFoot" end

                self.rightHand = self.char:FindFirstChild("RightHand")
                if not self.rightHand then return nil, "RightHand" end

                self.rightLowerArm = self.char:FindFirstChild("RightLowerArm")
                if not self.rightLowerArm then return nil, "RightLowerArm" end

                self.rightLowerLeg = self.char:FindFirstChild("RightLowerLeg")
                if not self.rightLowerLeg then return nil,"RightLowerLeg"  end

                self.rightUpperArm = self.char:FindFirstChild("RightUpperArm")
                if not self.rightUpperArm then return nil, "RightUpperArm" end

                self.rightUpperLeg = self.char:FindFirstChild("RightUpperLeg")
                if not self.rightUpperLeg then return nil, "RightUpperLeg" end

                self.upperTorso = self.char:FindFirstChild("UpperTorso")
                if not self.upperTorso then return nil, "UpperTorso" end

                self.joints = {}
                for jName, jData in pairs(CharData[("joints%s"):format(self.rigType)]) do
                    local joint = self[jData.ParentName]:FindFirstChild(jData.instName)
                    if not joint then return nil, ("Joint %s"):format(jData.instName) end
                    self.joints[jName] = joint
                end
                if self.char:HasTag("Monster") then
                    self.Toucher = self.char:FindFirstChild("Toucher")
                    if not self.Toucher then return nil, "Toucher" end
                end
            elseif self.rigType == "Monster_R6_1" then
                self.Toucher = self.char:FindFirstChild("Toucher")
                if not self.Toucher then return nil, "Toucher" end
            end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        debugMsg = str
    })
end

function CharPartsC:Destroy()
    self._maid:Destroy()
end

return CharPartsC