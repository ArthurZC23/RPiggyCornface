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

local LogFormatter = {}
LogFormatter.__index = LogFormatter
LogFormatter.className = "LogFormatter"
LogFormatter.TAG_NAME = LogFormatter.className

function LogFormatter.new(format, dateFormat)
    -- format example (%s - %s - %s)
    local self = {
        format = format,
        dateFormat = dateFormat,
        _maid = Maid.new(),
    }
    setmetatable(self, LogFormatter)

    return self
end

function LogFormatter:Destroy()
    self._maid:Destroy()
end

return LogFormatter