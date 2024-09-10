local SharedF = script:FindFirstAncestor("Shared")
local FsmLogger = require(SharedF:WaitForChild("FsmLogger"))

local module = {}

function module.loadModules(fsmName, StatesFolder, debug)
    local logger = FsmLogger.getLogger(fsmName, debug)
    local States = {}
    for _, stateMod in ipairs(StatesFolder:GetChildren()) do
        States[stateMod.Name] = logger(require(stateMod))
    end
    return States
end

function module.loadObjs(States, ...)
    local states = {}
    for stateName, stateMod in pairs(States) do
        states[stateName] = stateMod.new(...)
    end
    return states
end

return module