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

local LogHandler = {}
LogHandler.__index = LogHandler
LogHandler.className = "LogHandler"
LogHandler.TAG_NAME = LogHandler.className

function LogHandler.new(message, severityLevel)
    local self = {
        message = message,
        severityLevel = severityLevel,
        _maid = Maid.new(),
        filters = {},
    }
    setmetatable(self, LogHandler)

    return self
end

function LogHandler:setLevel()
    self.loggerSeverityLevel = 1
end

function LogHandler:setFormatter(formatter)
    self.formatter = formatter
end

function LogHandler:addFilter(filter)
    table.insert(self.filters, filter)
end

function LogHandler:removeFilter(filter)
    local idx = table.find(self.filters, filter)
    table.remove(self.filters, idx)
end

function LogHandler:filter(record)
    return true
end

function LogHandler:Destroy()
    self._maid:Destroy()
end

return LogHandler