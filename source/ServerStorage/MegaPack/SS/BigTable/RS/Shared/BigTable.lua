local _bigTable = {}

local module = {}

function module.set(scope, key, val)
    _bigTable[scope] = _bigTable[scope] or {}
    _bigTable[scope][key] = val
    return function()
        module.delete(scope, key)
    end
end

function module.delete(scope, key)
    _bigTable[scope] = _bigTable[scope] or {}
    _bigTable[scope][key] = nil
end

function module.get(scope, key)
    _bigTable[scope] = _bigTable[scope] or {}
    -- print(scope, key, _bigTable[scope][key])
    return _bigTable[scope][key]
end

function module.getScope(scope)
    return _bigTable[scope]
end


return module