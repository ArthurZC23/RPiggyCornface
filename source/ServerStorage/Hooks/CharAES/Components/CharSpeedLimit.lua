local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local Queue = Mod:find({"DataStructures", "Queue"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local CharData = Data.Char.Char

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local CharSpeedLimit = {}
CharSpeedLimit.__index = CharSpeedLimit
CharSpeedLimit.className = "CharSpeedLimit"
CharSpeedLimit.TAG_NAME = CharSpeedLimit.className

function CharSpeedLimit.new(player, char)
    -- This doesn't work with teleport
    return
    -- local self = {
    --     player = player,
    --     char = char,
    --     _maid = Maid.new(),
    -- }
    -- setmetatable(self, CharSpeedLimit)

    -- if not self:getFields() then return end

    -- local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    -- if not playerState then return end

    -- FastSpawn(function()
    --     self:handleSpeedLimit(playerState)
    -- end)

    -- return self
end

function CharSpeedLimit:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.hrp = self.char:FindFirstChild("HumanoidRootPart")
            if not self.hrp then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharSpeedLimit:handleSpeedLimit(playerState)
    self.limit = 10
    self.extraSpeed = 15
    self.pos0 = self.hrp.Position
    self.pos1 = self.pos0
    self.positionsQueue = Queue.new(
        {},
        {
            maxSize=self.limit,
            fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
        }
    )
    self.exploitStrikes = 0
    --print("START SPEED LIMIT")
    while self.char.Parent do
        local step = RunService.Heartbeat:Wait()
        if playerState.isDestroyed then return end
        self.pos0 = self.pos1
        self.pos1 = self.hrp.Position
        self.positionsQueue:pushLeft(self.pos1)
        local speed = ((self.pos1 - self.pos0) * Vector3.new(1, 0, 1)).Magnitude / step
        -- print("Speed: ", speed)
        local charMaxSpeed = CharData.humanoid.Speed
        if speed > charMaxSpeed + self.extraSpeed then
            -- print("+ STIRKE")
            self.exploitStrikes += 1
        else
            -- print("- STIRKE")
            self.exploitStrikes = math.max(self.exploitStrikes - 1, 0)
        end
        if self.exploitStrikes > self.limit then
            local pos = self.positionsQueue:popRight()
            self.hrp.CFrame = self.hrp.CFrame - self.hrp.CFrame.Position + pos
            self.exploitStrikes = self.limit/2
        end
    end
end

function CharSpeedLimit:Destroy()
    --print("Destroy")
    self._maid:Destroy()
end

return CharSpeedLimit