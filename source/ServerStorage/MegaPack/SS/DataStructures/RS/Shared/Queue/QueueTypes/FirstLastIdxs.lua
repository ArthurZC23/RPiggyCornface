-- More efficient. Cannot be iterated with ipairs or serialized.

local module = {}

function module.pushLeft(queue, value)
	queue.first = queue.first - 1
	queue._queue[queue.first] = value
	queue.size = queue.size + 1
end

function module.pushRight(queue, value)
	queue.last = queue.last + 1
	queue._queue[queue.last] = value
	queue.size = queue.size + 1
end

function module.popLeft(queue)
	if queue.first > queue.last then
		return
	end
	local value = queue._queue[queue.first]
	queue._queue[queue.first] = nil
	queue.first = queue.first + 1
	queue.size = queue.size - 1
	return value
end

function module.popRight(queue)
	if queue.first > queue.last then
		return
	end
	local value = queue._queue[queue.last]
	queue._queue[queue.last] = nil
	queue.last = queue.last - 1
	queue.size = queue.size - 1
	return value
end


return module