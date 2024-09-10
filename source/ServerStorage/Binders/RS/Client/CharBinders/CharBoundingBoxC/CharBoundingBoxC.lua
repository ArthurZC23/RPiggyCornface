local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local CharBoundingBoxC = {}
CharBoundingBoxC.__index = CharBoundingBoxC
CharBoundingBoxC.className = "CharBoundingBox"
CharBoundingBoxC.TAG_NAME = CharBoundingBoxC.className

function CharBoundingBoxC.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharBoundingBoxC)

    if not self:getFields() then return end
    if CharUtils.isPChar(self.char) then
        self:updateDirectionBoundingBox()
    end

    return self
end

function CharBoundingBoxC:updateDirectionBoundingBox()
    local t = 0
    self._maid:Add(BigBen.every(1, "Heartbeat", "frame", true):Connect(function(_, timeStep)
        t += timeStep
        local pos = self.charParts.boundingBox.Position
        self.charParts.directionBoundingBox.Size = self.charParts.boundingBox.Size
        local dir = self.charVelocity.velocity
        if dir.Magnitude < 1 then
            dir = self.charParts.hrp.CFrame.LookVector
        end
        local lookAt = self.charParts.hrp.Position + dir
        local cf = CFrame.lookAt(pos, lookAt)
        self.charParts.directionBoundingBox.CFrame = cf
    end))
end

function CharBoundingBoxC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            if not self.char:GetAttribute("uid") then return end
            do
                local bindersData = {
                    {"CharParts", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            if CharUtils.isPChar(self.char) then
                local bindersData = {
                    {"CharVelocity", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharBoundingBoxC:Destroy()
    self._maid:Destroy()
end

return CharBoundingBoxC