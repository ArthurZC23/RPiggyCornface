local module = {}

function module.computeOnce(func)
	local result
	return function(...)
		if result then return result end
		result = func(...)
		return result
	end
end

function module.turnAsync(func, waitPeriod)
	return function (...)
		local result = func(...)
		while not result do
			result = func(...)
			wait(waitPeriod)
		end
		return result
	end
end

return module