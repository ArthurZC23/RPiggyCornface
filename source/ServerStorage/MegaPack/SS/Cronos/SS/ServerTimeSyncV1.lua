local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = ComposedKey("ReplicatedStorage", "Sherlocks", "Shared", "Mod")
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})
local Promise = Mod:find({"Promise", "Promise"})
local Data = Mod:find({"Data", "Data"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local SyncData = Data.Cronos.ServerTimeSynce

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

local function fetchSyncedTime()
    return Promise.new(function(resolve, reject)
        local requestTime, requestSuccessful, response
        local idx = 1
        while not requestSuccessful and SyncData.urls[idx] do
            requestTime = os.clock()
            requestSuccessful, response = pcall(function()
                return HttpService:RequestAsync({Url=SyncData.urls[idx]})
            end)
            idx = idx + 1
        end

        if not requestSuccessful then
            Promise.delay(1)
                :andThenCall(
                    reject,
                    ("Failed to access sites for time syncing.\nError: %s"):format(tostring(response))
                )
        end

        local dateStr = response.Headers.data
        local originTime = RFC2616DateStringToUnixTimestamp(dateStr)
        local responseTime = os.clock()
        local responseDelay = (responseTime - requestTime) / 2
        resolve({
            originTime = originTime,
            responseTime = responseTime,
            responseDelay = responseDelay,
        })
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
    self.originTime = os.clock()
    self.responseTime = os.clock()
    self.responseDelay = 0
    self.t0 = self.originTime - self.responseTime - self.responseDelay
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
    Promise.retry(fetchSyncedTime, 3)
        :andThen(function(timeValues)
            self.isServerSynced = true
            self.originTime = timeValues.originTime
            self.responseTime = timeValues.responseTime
            self.responseDelay = timeValues.responseDelay
            self.t0 = self.originTime - self.responseTime - self.responseDelay
        end)
        :catch(function(err)
            local msg = ("Server was unable to sync time.\nError: %s"):format(tostring(err))
            ErrorReport.report("Server", msg, "error")
        end)
end

function ServerTimeSynce:getTime()
    return self.t0 + os.clock()
end

function ServerTimeSynce:Destroy()
    self._maid:Destroy()

end

return ServerTimeSynce