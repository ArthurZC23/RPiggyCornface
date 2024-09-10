local SignalF = {}
SignalF.__index = SignalF
SignalF.className = "SignalF"

function SignalF.new(rawSignal)
	local self = setmetatable({}, SignalF)

	self._bindableFunction = rawSignal or Instance.new("BindableFunction")
	assert(self._bindableFunction:IsA("BindableFunction"), "Instance is not a Bindable Function.")
	self._argData = nil
	self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

	return self
end

function SignalF:Invoke(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._bindableFunction:Fire()
end

function SignalF:OnInvoke(handler)
	if not (type(handler) == "function") then
        error(("Connect only accept function callbacks. callback of type (%s) was not accepted")
            :format(typeof(handler)), 2)
	end

	self._bindableFunction.OnInvoke = function()
        handler(unpack(self._argData, 1, self._argCount))
	end
end

function SignalF:Destroy()
	if self._bindableFunction then
		self._bindableFunction:Destroy()
		self._bindableFunction = nil
	end

	self._argData = nil
	self._argCount = nil
end

return SignalF