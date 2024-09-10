local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Queue = Mod:find({"DataStructures", "Queue"})
--local Data = Mod:find({"Data", "Data"})
--local CronosData = Data.Cronos.SyncClientToServer
local Data = script.Parent:WaitForChild("Data")
local CronosData = require(Data.SyncClientToServer)

local ClockSyncRF = ReplicatedStorage.Remotes.Functions:WaitForChild("ClockSync")

local ClientTimeSync = {}
ClientTimeSync.__index = ClientTimeSync
ClientTimeSync.className = "ClientTimeSync"
ClientTimeSync.TAG_NAME = ClientTimeSync.className

function ClientTimeSync.new()
    local self = {}
    setmetatable(self, ClientTimeSync)
    self._maid = Maid.new()

    self.timeOffset = {
        values = Queue.new(
            {0},
            {
                maxSize=CronosData.timeOffset.samples,
                fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
            }
        ),
        movingAverage = 0,
    }

    self.roundTrip = {
        values = Queue.new(
            {0},
            {
                maxSize=CronosData.timeOffset.samples,
                fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
            }
        ),
        movingAverage = 0,
    }

    self:syncClocks()
    FastSpawn(function()
        while true do
            wait(CronosData.SyncInterval)
            self:syncClocks()
        end
    end)

    return self
end

function ClientTimeSync:syncClocks()
    -- https://en.wikipedia.org/wiki/Network_Time_Protocol
    local t0 = os.time()
	local t1 = ClockSyncRF:InvokeServer(t0)
    local t2 = t1
    local t3 = os.time()
    local timeOffset = 0.5 * ((t1 - t0) + (t2 - t3))
    local roundTrip = (t3 - t2) + (t1 - t0)
    self:udpdateStatistics(timeOffset, roundTrip)
end

function ClientTimeSync:udpdateStatistics(timeOffset, roundTrip)
    self.timeOffset.values:pushLeft(timeOffset)
    self.roundTrip.values:pushLeft(roundTrip)

    local n = self.timeOffset.values.size

    self.timeOffset.movingAverage =
        self.timeOffset.movingAverage
        + (1/n) * (timeOffset - self.timeOffset.movingAverage)

    self.roundTrip.movingAverage =
        self.roundTrip.movingAverage
        + (1/n) * (roundTrip - self.roundTrip.movingAverage)
end

function ClientTimeSync:getTime()
    return os.time() + self.timeOffset.movingAverage -- = time server
end

function ClientTimeSync:Destroy()
    self._maid:Destroy()
end

return ClientTimeSync