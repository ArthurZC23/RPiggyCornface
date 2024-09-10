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
local LogRecord = require(Shared:WaitForChild("LogRecord"))

local Logger = {}
Logger.__index = Logger
Logger.className = "Logger"
Logger.TAG_NAME = Logger.className

function Logger.new(name)
    local self = {
        name = name,
        _maid = Maid.new(),
        propagateToParent = true,
        filters = {},
        handlers = {},
    }
    setmetatable(self, Logger)

    self:getParentLogger(name)

    return self
end

function Logger:getParentLogger(name)
    self.parentLogger = nil
end

function Logger:hasRequiredSeverityLevel(method, requestSeverityLevel)
    return function(message)
        if self.loggerSeverityLevel >= requestSeverityLevel  then -- code here
            local logRecord = LogRecord.new(message, requestSeverityLevel)
            method(self, message)
        end
    end
end

function Logger:log(message, severityLevel)
    self[LoggingData.severityToMethod[severityLevel]](self, message)
end

function Logger:info()
    -- Check level of call

end

function Logger:exception()
    -- Like error but dumps a stack trace

end

function Logger:config()
    self.loggerSeverityLevel = 1 -- config this

    for _, methodName in ipairs({"info"}) do
        self[methodName] = self:hasRequiredSeverityLevel(
            self[methodName], LoggingData.severity[methodName:upper()]
        )
    end
end

function Logger:addHandler(handler)
    table.insert(self.handlers, handler)
end

function Logger:removeHandler(handler)
    local idx = table.find(self.handlers, handler)
    table.remove(self.handlers, idx)
end

function Logger:addFilter(filter)
    table.insert(self.filters, filter)
end

function Logger:removeFilter(filter)
    local idx = table.find(self.filters, filter)
    table.remove(self.filters, idx)
end

function Logger:setLevel(level)
    self.loggerSeverityLevel = LoggingData.severity[level]
end

function Logger:Destroy()
    self._maid:Destroy()
end

return Logger