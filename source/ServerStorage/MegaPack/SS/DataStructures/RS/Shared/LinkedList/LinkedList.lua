-- Incomplete. There is no add or remove method.

local LinkedList = {}
LinkedList.__index = LinkedList

function LinkedList.new(array)
    local self = {}
    setmetatable(self, LinkedList)
    self.head = nil
    -- Keep the array order
    for i=#array,1,-1 do
        self.head = {nextNode = self.head, value = array[i]}
	end

	self._traverse = coroutine.create(function()
		local val = self.head.value
		self.head = self.head.nextNode
		coroutine.yield(val)
	end)

    return self
end

-- Need add and remove methods

function LinkedList:add()

end

function LinkedList:next()
	return coroutine.resume(self._traverse)
end

function LinkedList:Destroy()

end

return LinkedList