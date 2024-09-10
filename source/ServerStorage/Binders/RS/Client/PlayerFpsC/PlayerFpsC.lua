local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})

local localPlayer = Players.LocalPlayer

local PlayerFps = {}
PlayerFps.__index = PlayerFps
PlayerFps.className = "PlayerFps"
PlayerFps.TAG_NAME = PlayerFps.className

function PlayerFps.new(player)
    if player ~= localPlayer then return end

    local self = {}
    setmetatable(self, PlayerFps)
    self.player = player
    self._maid = Maid.new()

    self.SendFpsRE = player:WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("SendFps")

    self.fpsArray = {}
    self.fpsAvg = 0
    self.lastFps = 60
    self:addFps()
    coroutine.wrap(self.flush)(self)

    return self
end

function PlayerFps:flush()
    while true do
        Cronos.wait(1)
        self.fpsAvg = 0
        for _, sample in ipairs(self.fpsArray) do
            self.fpsAvg = self.fpsAvg + sample
        end
        self.fpsAvg = self.fpsAvg / #self.fpsArray
        self.SendFpsRE:FireServer(self.fpsAvg)
        self.fpsArray = {}
        if self.player.UserId == 1700355376 or self.player.UserId == 925418276 then
            --print("FPS: ", self.fpsAvg )
        end
    end
end

function PlayerFps:addFps()
    RunService.Heartbeat:Connect(function(step)
        self.lastFps = 1/step
        table.insert(self.fpsArray, self.lastFps)
    end)
end

function PlayerFps:Destroy()
    self._maid:Destroy()
end

return PlayerFps