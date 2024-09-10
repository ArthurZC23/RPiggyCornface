-- Simple, can be iterated with iparis and serialized.

local module = {}

function module.pushLeft(queue, value)
	queue.size = queue.size + 1
	table.insert(queue._queue, 1, value)
end

function module.pushRight(queue, value)
	queue.size = queue.size + 1
	table.insert(queue._queue, value)
end

function module.popLeft(queue)
	queue.size = queue.size - 1
	return table.remove(queue._queue, 1)
end

function module.popRight(queue)
	queue.size = queue.size - 1
	return table.remove(queue._queue)
end


return module