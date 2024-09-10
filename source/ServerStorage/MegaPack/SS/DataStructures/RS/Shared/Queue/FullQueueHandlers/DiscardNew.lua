local module = {}

function module.pushLeft(pushLeft)
	return function(queue, value)
		if queue.size < queue.maxSize then
			pushLeft(queue, value)
		end
	end
end

function module.pushRight(pushRight)
	return function(queue, value)
		if queue.size < queue.maxSize then
			pushRight(queue, value)
		end
	end
end

function module.popLeft(popLeft)
	return popLeft
end

function module.popRight(popRight)
	return popRight
end


return module