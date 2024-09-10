local IState = {}
IState.__index = IState

function IState.new()
    local self = {}
    setmetatable(self, IState)
    return self
end

function IState:onEnter()
    error("Need to implement onEnter for IState interface.", 2)
end

function IState:update()
    error("Need to implement Update for IState interface.", 2)
end

function IState:onExit()
    error("Need to implement onExit for IState interface.", 2)
end

return IState