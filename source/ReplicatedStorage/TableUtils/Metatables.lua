local module = {}

function module.makeEnum(enumName, tbl)
    assert(typeof(enumName) == "string")

    tbl = module.addStringRepresentation(tbl, function() return enumName end)
    local mt = getmetatable(tbl) or {}

    mt.__index = function(_, k)
        error(("%s is not in %s."):format(k, tostring(tbl)), 2)
    end
    mt.__newindex = function()
        error(("Creating new members in Enum %s is not allowed!"):format(tostring(tbl)), 2)
    end
    return setmetatable(tbl, mt)
end

function module.makeEnumFromArray(enumName, array)
	assert(typeof(enumName) == "string")
	local tbl = {}
	for _, v in ipairs(array) do
		tbl[v] = v
	end

	tbl = module.addStringRepresentation(tbl, function() return enumName end)
	local mt = getmetatable(tbl) or {}

	mt.__index = function(_, k)
		error(("%s is not in %s."):format(k, tostring(tbl)), 2)
	end
	mt.__newindex = function()
		error(("Creating new members in Enum %s is not allowed!"):format(tostring(tbl)), 2)
	end
	return setmetatable(tbl, mt)
end

function module.addStringRepresentation(tbl, toString)
    local mt = getmetatable(tbl) or {}
    mt.__tostring = toString
    setmetatable(tbl, mt)
    return tbl
end

return module