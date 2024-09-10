local module = {}

function module.filter(array, func)
    local filteredArray = {}
	for i, v in ipairs(array) do
		if func(v) then table.insert(filteredArray, v) end
	end
    return filteredArray
end

function module.map(array, func)
	local mapArray = {}
	for i, v in ipairs(array) do
		table.insert(mapArray, func(v, i, array))
	end
	return mapArray
end

function module.mapUsingValueAsKey(array, func)
	local map = {}
	for i, v in ipairs(array) do
        map[v] = func(v, i, array)
	end
	return map
end

function module.filterThenMap(array, filter, map)
    local mapArray = {}
	for i, v in ipairs(array) do
		if filter(v) then
            table.insert(mapArray, map(v, i, array))
        end
	end
    return mapArray
end

function module.reduce(array, reducer, kwargs)
	kwargs = kwargs or {}
	local start = kwargs.start or 1
	local finish = kwargs.finish or #array
	local acumulator = kwargs.acc0 or array[start]
	for i=start+1,finish do
		acumulator = reducer(acumulator, array[i])
	end
	return acumulator
end

function module.unique(array)
    local set = {}
    local uniqueArray = {}
	for i, v in ipairs(array) do
        if set[v] then continue end
        table.insert(uniqueArray, v)
	end
    return uniqueArray
end

return module