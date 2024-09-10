local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local LoggingData = Data.Logging.Logging
local S = Data.Strings.Strings

local Shared = script:FindFirstAncestor("Shared")

local LogRecord = {}
LogRecord.__index = LogRecord
LogRecord.className = "LogRecord"
LogRecord.TAG_NAME = LogRecord.className

function LogRecord.new(message, severityLevel)
    local self = {
        message = message,
        severityLevel = severityLevel,
        _maid = Maid.new(),
    }
    setmetatable(self, LogRecord)

    return self
end

function LogRecord:Destroy()
    self._maid:Destroy()
end

return LogRecord