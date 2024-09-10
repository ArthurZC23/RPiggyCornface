local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})
local Promise = Mod:find({"Promise", "Promise"})
-- Cronos is used in Data. Its data cannot be set there.
--local Data = Mod:find({"Data", "Data"})
--local SyncData = require(Data.Cronos.ServerTimeSync)
local Data = script.Parent.Data
local SyncData = require(Data.ServerTimeSync)
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})


local ONE_MINUTE = 60
local ONE_HOUR = 60 * ONE_MINUTE

local function RFC2616DateStringToUnixTimestamp(dateStr)
    local day, monthStr, year, hour, min, sec = dateStr:match(".*, (.*) (.*) (.*) (.*):(.*):(.*) .*")
	local month = SyncData.monthStrToNum[monthStr]
	local date = {
		day=day,
		month=month,
		year=year,
		hour=hour,
		min=min,
		sec=sec
	}
	return os.time(date)
end

local function fetchWebPage()
    local t0, t3, ok, response

    local idx = 1
    while not ok and SyncData.urls[idx] do
        t0 = os.time()
        ok, response = pcall(function()
            return HttpService:RequestAsync({Url=SyncData.urls[idx]})
        end)
        t3 = os.time()
        idx = idx + 1
    end

    return ok, response, t0, t3
end

local function fetchSyncedTime()
    return Promise.new(function(resolve, reject)
        local ok, response, t0, t3 = fetchWebPage()

        local t1
        if ok then
            local dateStr = response.Headers.date
            t1 = RFC2616DateStringToUnixTimestamp(dateStr)
        else
            t1 = (t3 + t0) / 2
        end

        local t2 = t1
        local roundTrip = (t3 - t2) + (t1 - t0)
        local timeOffset = 0.5 * ((t1 - t0) + (t2 - t3))
        resolve({
            roundTrip = roundTrip,
            timeOffset = timeOffset,
        })
    end)
        :catch(function(err)

        end)
end

local ServerTimeSynce = {}
ServerTimeSynce.__index = ServerTimeSynce
ServerTimeSynce.className = "ServerTimeSynce"

function ServerTimeSynce.new()
    local self = {}
    setmetatable(self, ServerTimeSynce)
    self._maid = Maid.new()
    self.isServerSynced = false
    self.roundTrip = 0
    self.timeOffset = 0

    self:sync():await()
    FastSpawn(function()
        while true do
            Promise.delay(ONE_HOUR):await()
            self:sync()
        end
    end)
    return self
end

function ServerTimeSynce:sync()
    return Promise.retry(fetchSyncedTime, 3)
        :andThen(function(data)
            self.isServerSynced = true
            self.roundTrip = data.roundTrip
            self.timeOffset = data.timeOffset
        end)
        :catch(function(err)
            local msg = ("Server was unable to sync time.\nError: %s"):format(tostring(err))
            ErrorReport.report("Server", msg, "error")
        end)
end

function ServerTimeSynce:getTime()
    return os.time() + self.timeOffset
end

function ServerTimeSynce:Destroy()
    self._maid:Destroy()

end

return ServerTimeSynce