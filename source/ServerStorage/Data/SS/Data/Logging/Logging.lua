local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local module = {}

module.severity = Mts.makeEnum("Logging Severity Level", {
    CRITICAL = 50,
    ERROR = 40,
    WARNING = 30,
    INFO = 20,
    DEBUG = 10,
})

module.severityToMethod = Mts.makeEnum("Logging Severity Level Method", {
    [module.severity.DEBUG] = "debug",
    [module.severity.INFO] = "info",
    [module.severity.WARNING] = "warning",
    [module.severity.ERROR] = "error",
    [module.severity.CRITICAL] = "critical",
})

return module