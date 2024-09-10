local QSignalF = {}
QSignalF.__index = QSignalF
QSignalF.className = "QSignalF"

function QSignalF.new(rawSignal)
	local self = setmetatable({}, QSignalF)

	self._bindableFunction = rawSignal or Instance.new("BindableFunction")
	assert(self._bindableFunction:IsA("BindableFunction"), "Instance is not a Bindable Function.")
	self._argData = nil
	self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

	return self
end

function QSignalF:Fire(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._bindableFunction:Fire()
end

function QSignalF:Connect(handler)
	if not (type(handler) == "function") then
        error(("Connect only accept function callbacks. callback of type (%s) was not accepted")
            :format(typeof(handler)), 2)
	end

	return self._bindableFunction.Event:Connect(function()
		handler(unpack(self._argData, 1, self._argCount))
	end)
end

function QSignalF:Wait()
	self._bindableFunction.Event:Wait()
	assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
	return unpack(self._argData, 1, self._argCount)
end

function QSignalF:Destroy()
	if self._bindableFunction then
		self._bindableFunction:Destroy()
		self._bindableFunction = nil
	end

	self._argData = nil
	self._argCount = nil
end

return QSignalF