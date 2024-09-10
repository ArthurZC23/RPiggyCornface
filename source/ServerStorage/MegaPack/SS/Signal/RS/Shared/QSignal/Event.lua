local QSignalE = {}
QSignalE.__index = QSignalE
QSignalE.className = "QSignalE"

function QSignalE.new(rawSignal)
	local self = setmetatable({}, QSignalE)

	self._bindableEvent = rawSignal or Instance.new("BindableEvent")
	assert(self._bindableEvent:IsA("BindableEvent"), "Instance is not a Bindable Event.")
	self._argData = nil
	self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

	return self
end

function QSignalE:Fire(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._bindableEvent:Fire()
end

function QSignalE:Connect(handler)
	if not (type(handler) == "function") then
        error(("Connect only accept function callbacks. callback of type (%s) was not accepted")
            :format(typeof(handler)), 2)
	end

	return self._bindableEvent.Event:Connect(function()
		handler(unpack(self._argData, 1, self._argCount))
	end)
end

function QSignalE:Wait()
	self._bindableEvent.Event:Wait()
	assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
	return unpack(self._argData, 1, self._argCount)
end

function QSignalE:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end

	self._argData = nil
	self._argCount = nil
end

return QSignalE