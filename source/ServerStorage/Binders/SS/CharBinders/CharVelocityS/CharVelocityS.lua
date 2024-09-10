local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local BigBen = Mod:find({"Cronos", "BigBen"})

local CharVelocityS = {}
CharVelocityS.__index = CharVelocityS
CharVelocityS.className = "CharVelocity"
CharVelocityS.TAG_NAME = CharVelocityS.className

function CharVelocityS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        speed = 0,
        callbacks = {},
        randoms = {
            Black = Random.new(),
            White = Random.new(),
        }
    }
    setmetatable(self, CharVelocityS)

    if not self:getFields() then return end

    self:monitorCharVelocity()

    return self
end

function CharVelocityS:addCallback(cbId, cb)
    self.callbacks[cbId] = cb
    return function()
        self:removeCallback(cbId)
    end
end

function CharVelocityS:removeCallback(cbId)
    self.callbacks[cbId] = nil
end

function CharVelocityS:getFields()
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

function CharVelocityS:monitorCharVelocity()
    local conn
    local p0 = self.charParts.hrp.Position
    local p1 = p0
    local hFilter = Vector3.new(1, 0, 1)
    local vFilter = Vector3.new(0, 1, 0)
    local tickFunc = 1

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
                task.spawn(cb, self)
            end
        end)
    self._maid:Add(conn)
end

function CharVelocityS:Destroy()
    self._maid:Destroy()
end

return CharVelocityS