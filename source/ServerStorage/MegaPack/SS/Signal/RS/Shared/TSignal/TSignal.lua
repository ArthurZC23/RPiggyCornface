-- Tomarty Signal implementation.
-- Reference: https://devforum.roblox.com/t/is-it-possible-to-make-a-custom-rbxscriptsignal-with-oop/124981/11?u=bachatronic
-- Less simple to understand than Quenty Signal. Don't see the reason to use this for now.

local setmetatable = setmetatable
local table_remove = table.remove

local TSignal = {}
local Methods = {}
local Mt = {__index = Methods}
-- Although hacky,it's possible to have the metatable change based on the number of arguments in the list for better firing performance. I left that out for simplicity.

-- 'conn' is short for 'connection'
-- I use 'connection()' instead of 'connection:Disconnect()'. This means I can use functions and connections interchangeably
local ConnMt = {__call = function(conn)
    local self, method = conn[1], conn[2]
    for i, _ in ipairs(self) do
		if self[i] == method then
			local sync = self[0]
			if sync then
				sync(i)
			end
			table_remove(self, i)
			break
		end
    end

end}

function Methods:Connect(method)
	self[#self + 1] = method
	return setmetatable({self, method}, ConnMt)
end

function Methods:addToConnectionArray(connArray, method) -- 'cns' is short for 'connections', and is my lightweight version of a Maid TSignal
	self[#self + 1] = method
	connArray[#connArray + 1] = setmetatable({self, method}, ConnMt)
end

function Mt:Fire(...)
	local i0, i1 = 0, #self
	-- I have other implementations that "lock" the list instead of creating functions (which is very expensive), but they're more complex.
	-- This implementation creates unneeded functions for 0 or 1 methods, but I'm leaving those out for the sake of simplicity.
	local syncPrev = self[0]
	self[0] = syncPrev and function(i) -- Supports recursive calling, as well as disconnecting arbitrary methods during other methods
		if i<=i1 then i1=i1-1 end
		if i<=i0 then i0=i0-1 end
		syncPrev(i)
	end or function(i) -- use fewer upvalues
		if i<=i1 then i1=i1-1 end
		if i<=i0 then i0=i0-1 end
	end
	
	-- Calling backwards is better for some cases, but calling in order of connection is more intuitive
	while i0 < i1 do
		i0 = i0 + 1
		-- This should never yield. If a method needs a coroutine, it should create one itself.
		-- This is not protected from errors, but I find this useful because they are often caused by a bad input.
		self[i0](...)
	end
	
	self[0] = syncPrev
end

function TSignal.new()
	return setmetatable({}, Mt)
end


do -- Usage:
	local event = TSignal.new()
	
	local conn = event:Connect(function(...)
		print("Event firing:", ...)
	end)
	
	event:Fire(1, 2, 3)
	conn() -- Disconnect
	event:Fire(4, 5, 6)
end

return TSignal