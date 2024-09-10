local Stack = {}
Stack.__index = Stack

function Stack.new(kwargs)
    local self = {}
    setmetatable(self, Stack)
    kwargs =  kwargs or {}
    self.maxSize = kwargs.maxSize or math.huge
    self.stack = {}
    self.size = 0
    return self
end

function Stack:push(arg)
    assert(self.size < self.maxSize, "Stack overflow")
    self.size += 1
	self.stack[self.size] = arg
end

function Stack:pop()
	assert(self.size > 0, "Stack underflow")
	local arg = self.stack[self.size]
	self.stack[self.size] = nil
    self.size -= 1
	return arg
end

function Stack:peek()
	return self.stack[self.size]
end

function Stack:isEmpty()
	return self.size == 0
end

function Stack:isFull()
	return self.size == self.maxSize
end

return Stack