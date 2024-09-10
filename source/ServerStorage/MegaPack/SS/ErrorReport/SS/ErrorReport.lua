local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})
local Filters = Mod:find({"ErrorReport", "Filters"})

local GameAnalytics = require(ServerStorage.GameAnalytics)

local module = {}

module.severity = {
    debug = "debug",
    info = "info",
    warning = "warning",
    error = "error",
    critical = "critical",
}
module.severity = Mts.makeEnum("ErrorSeverity", module.severity)

function module.report(id, message, severity)
    message = debug.traceback(message, 2)
    -- warn(message)
    -- message = Filters.filterMessageServer(message)
    -- if not message then return end

    task.spawn(function()
        error(message)
    end)

    GameAnalytics:addErrorEvent(id, {
        severity = GameAnalytics.EGAErrorSeverity[severity],
        message = message
    })
end

function module.reportFromClient(player, message)
    -- print("Received from client", message)
    -- severity = GameAnalytics.EGAErrorSeverity[severity] or GameAnalytics.EGAErrorSeverity.error
    -- message = debug.traceback(message, 2) -- Makes no sense, this is not the traceback from client
    -- message = Filters.filterMessageServer(message)
    -- if not message then return end
    -- print("Add event to server ", message)

    local id = tostring(player.UserId)
    message = ("%s %s"):format(id, message)

    GameAnalytics:addErrorEvent(id, {
		severity = GameAnalytics.EGAErrorSeverity.error,
		message = message,
	})
end

return module