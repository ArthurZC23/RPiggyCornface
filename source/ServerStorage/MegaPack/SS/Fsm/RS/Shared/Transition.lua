local Transition = {}
Transition.__index = Transition

function Transition.new(name, from, to, condition, onBeforeTransition, onAfterTransition, kwargs)
    local self = {}
    setmetatable(self, Transition)
	self._name = name
	self.from = from
    self.to = to
    self._condition = condition
    self.onBeforeTransition = onBeforeTransition or function () end
	self.onAfterTransition = onAfterTransition or function () end
	self.kwargs = kwargs
    return self
end

function Transition:verifyCondition(dataContainer)
	return self:_condition(dataContainer)
end

return Transition