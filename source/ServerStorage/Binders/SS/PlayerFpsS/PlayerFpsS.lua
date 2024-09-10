local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Queue = Mod:find({"DataStructures", "Queue"})

local Gaia = Mod:find({"Gaia", "Server"})

local PlayerFps = {}
PlayerFps.__index = PlayerFps
PlayerFps.className = "PlayerFps"
PlayerFps.TAG_NAME = PlayerFps.className

function PlayerFps.new(player)
    local self = {}
    setmetatable(self, PlayerFps)
    self.player = player
    self._maid = Maid.new()

    Gaia.createRemotes(player, {
        events = {"SendFps"}
    })

    self.fpsQueue = Queue.new({}, {
        maxSize=10,
        fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
    })

    self.SendFpsRE = player.Remotes.Events.SendFps
    self.SendFpsRE.OnServerEvent:Connect(function(plr, fps)
        if player ~= plr then return end
        self:updateFps(fps)
    end)

    return self
end

function PlayerFps:updateFps(fps)
    self.fpsQueue:pushLeft(fps)

    self.fpsAvg = 0
    local size = 0
    for _, sample in pairs(self.fpsQueue._queue) do
        self.fpsAvg = self.fpsAvg + sample
        size = size + 1
    end
    self.fpsAvg = self.fpsAvg / size
    --print(("%s FPS: %s"):format(self.player.Name, self.fpsAvg))
end

function PlayerFps:Destroy()
    self._maid:Destroy()
end

return PlayerFps