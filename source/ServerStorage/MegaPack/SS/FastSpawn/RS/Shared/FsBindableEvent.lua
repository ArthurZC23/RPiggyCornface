local module = function(func, ...)
	local bindable = Instance.new("BindableEvent")
	local args = {...}
	bindable.Event:Connect(function()
		func(unpack(args))
	end)
	bindable:Fire()
	-- This will not work with deferred events. I think. I should test.
	bindable:Destroy()
end

return module