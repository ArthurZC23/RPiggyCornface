local Shared = script:FindFirstAncestor("Shared")
local Logger = require(Shared:WaitForChild("Logger"))

local module = {}

local loggers = {}

function module.getLogger(name)
    local logger = loggers[name]
    if not logger then
        logger = Logger.new(name)
    end
    loggers[name] = logger
    return logger
end

return module