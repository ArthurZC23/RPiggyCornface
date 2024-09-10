local RunService = game:GetService("RunService")

local isClient = RunService:IsClient()

local module = {}

local function addLoggerHof(fsmName, stateName, callbackName, callback, debug)
    if debug then
        local machineType
        if isClient then
            machineType = "Client"
        else
            machineType = "Server"
        end
        return function(...)
            print(("FSM %s Start %s %s on %s"):format(fsmName, stateName, callbackName, machineType))
            local result = callback(...)
            print(("FSM %s Finished %s %s on %s"):format(fsmName, stateName, callbackName, machineType))
            return result
        end
    end
    return function(...) return callback(...) end
end

function module.getLogger(fsmName, debug)
    debug = debug or false
    return function (stateClass)
        return module.addLogger(fsmName, stateClass, debug)
    end
end

function module.addLogger(fsmName, stateClass, debug)
    for _, callbackName in ipairs({"onEnter", "update", "onExit"}) do
        local callback = stateClass[callbackName]
        stateClass[callbackName] = addLoggerHof(fsmName, stateClass.className, callbackName, callback, debug)
    end
    return stateClass
end

return module