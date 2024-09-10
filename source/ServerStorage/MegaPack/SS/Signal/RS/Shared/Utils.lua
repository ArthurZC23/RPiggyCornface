local module = {}

function module.waitForFirst(...)
	local shunt = Instance.new("BindableEvent")
	local slots = {...}

	local function fire(...)
		for i = 1, #slots do
			slots[i]:Disconnect()
		end

		return shunt:Fire(...)
	end

	for i = 1, #slots do
		slots[i] = slots[i]:Connect(fire)
	end

	return shunt.Event:Wait()
end

function module.handleFirstEvent(events, callback)
    local conns = {}
    for _, ev in ipairs(events) do
        local conn
        conn = ev:Connect(function(...)
            for _, cn in ipairs(conns) do
                cn:Disconnect()
                cn = nil
            end
            callback(...)
        end)
        table.insert(conns, conn)
    end
end

function module.handleOneEvent(event, callback)
    local conn
    conn = event:Connect(function(...)
        conn:Disconnect()
        conn = nil
        callback(...)
    end)
end

return module
