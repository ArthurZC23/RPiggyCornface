local Logging = {}
Logging.__index = Logging
Logging.className = "Logging"

local function printF(self, msg)
    print(msg)
end
local dummyLogger = {
    debug = printF,
    info = printF,
}

function Logging.getLogger()
    return dummyLogger
end

return Logging