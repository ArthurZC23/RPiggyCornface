local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local localPlayer = Players.LocalPlayer
local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local CharVelocityC = {}
CharVelocityC.__index = CharVelocityC
CharVelocityC.className = "CharVelocity"
CharVelocityC.TAG_NAME = CharVelocityC.className

function CharVelocityC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)

    local self = {
        char = char,
        _maid = Maid.new(),
        speed = 0,
        isLocalChar = isLocalChar,
        callbacks = {},
        velocity = Vector3.zero,
    }
    setmetatable(self, CharVelocityC)

    if not self:getFields() then return end

    self:monitorCharVelocity()

    return self
end

function CharVelocityC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharVelocityC:monitorCharVelocity()
    local conn
    local p0 = self.charParts.hrp.Position
    local p1 = p0
    local hFilter = Vector3.new(1, 0, 1)
    local vFilter = Vector3.new(0, 1, 0)
    local tickFunc

    if self.isLocalChar then
        tickFunc = 1
    else
        tickFunc = function()
            local defaultTick = 3
            local localChar = localPlayer.Character
            if not (localChar and localChar.Parent) then return defaultTick end
            local localCharParts = binderCharParts:getObj(localChar)
            if not localCharParts then return defaultTick end
            local distance = (localCharParts.hrp.Position - self.charParts.hrp.Position).Magnitude
            if distance < 100 then
                return 2
            elseif distance < 200 then
                return 3
            else
                return 10
            end
        end
    end

    conn = BigBen.every(tickFunc, "Heartbeat", "frame"):Connect(function(step, timeStep, frameStep)
            p1 = self.charParts.hrp.Position
            self.velocity = (p1 - p0) / timeStep
            self.speed = self.velocity.Magnitude
            self.speedH =  (self.velocity * hFilter).Magnitude
            self.speedV = (self.velocity * vFilter).Magnitude
            p0 = p1
            -- print(step, timeStep, frameStep)
            -- print("Speed: ", self.speed, self.speedH, self.speedV)
            for _, cb in ipairs(self.callbacks) do
                -- Check distance
                task.spawn(cb, self)
            end
        end)
    self._maid:Add(conn)
end

function CharVelocityC:Destroy()
    self._maid:Destroy()
end

return CharVelocityC