local module = {}

function module.limitedIdGenerator(min, max)
    assert(typeof(min) == "string" and typeof(max) == "string", "min and max must be strings.")
    local nextId = min - 1
    return function()
        local nextSpawnNum = tonumber(nextId) + 1
        if nextSpawnNum <= tonumber(max) then
            nextId = tostring(nextSpawnNum)
        else
            nextId = min
        end
        return nextId
    end
end

function module.createNumIdGenerator(id0)
    id0 = id0 or 0
    local id = id0 - 1
    return function()
        id += 1
        return tostring(id)
    end
end

local _generators = {
    hitGroupId = module.limitedIdGenerator(tostring(-1e4), tostring(1e4))
}
function module.getGenerator(name)
    assert(_generators[name], ("Generator %s doesn't exist"):format(name))
    return _generators[name]
end

return module