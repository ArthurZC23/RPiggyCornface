local RootFolder = script:FindFirstAncestor("TableUtils")

local ComposedKey = require(RootFolder.ComposedKey)

local module = {}

function module.slice(array, idx0, idx1, step)
    local slice = {}
    local size = #array
    idx0 = idx0 or 1
    idx1 = idx1 or size
    step = step or 1

    if idx0 < 0 then
        idx0 = size + 1 + idx0
    end
    if idx1 < 0 then
        idx1 = size + 1 + idx1
    end

    for i = idx0, idx1, step do
        table.insert(slice, array[i])
    end
    return slice
end

function module.find(array, findFunc)
    for _, v in ipairs(array) do
        if findFunc(v) then return v end
    end
    return
end

function module.len(tbl)
    local len = 0
    for _,_ in pairs(tbl) do len = len + 1 end
    return len
end

function module.getTableType(t)
    if next(t) == nil then return "Empty" end
    local isArray = true
    local isDictionary = true
    for k, _ in next, t do
        if typeof(k) == "number" and k%1 == 0 and k > 0 then
            isDictionary = false
        else
            isArray = false
        end
    end
    if isArray then
        return "Array"
    elseif isDictionary then
        return "Dictionary"
    else
        return "Mixed"
    end
end

function module.getKeys(tbl)
    local array = {}
    for key,_ in pairs(tbl) do 
        table.insert(array, key)
    end
    return array
end

function module.getValues(tbl)
    local array = {}
    for _,value in pairs(tbl) do 
        table.insert(array, value)
    end
    return array
end

function module.deepCompare(t1, t2, ignoreMt)
	ignoreMt = ignoreMt or true
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= "table" and ty2 ~= "table" then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if (not ignoreMt) and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not module.deepCompare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not module.deepCompare(v1,v2) then return false end
	end
	return true
end

function module.breakKeyValInSyncedArrays(tbl)
    local keyArray = {}
    local valArray = {}
    for key, value in pairs(tbl) do
        table.insert(keyArray, key)
        table.insert(valArray, value)
    end
    return keyArray, valArray
end

function module.shallowCopy(tbl)
    local clone = {}
    for key,value in pairs(tbl) do
        clone[key] = value
    end
    return clone
end

function module.deepCopy(tbl)
    local clone = {}
    for key,value in pairs(tbl) do
        if typeof(value) == "table" then
            clone[key] = module.deepCopy(value)
        else
            clone[key] = value
        end
    end
    return clone
end

function module.getDesc(tbl)
    local desc = {}
    for key, value in pairs(tbl) do
        if typeof(value) == "table" then
            local _desc = module.getDesc(value)
            desc = module.concatArrays(desc, _desc)
        else
            table.insert(desc, value)
        end
    end
    return desc
end

function module.print(tbl, prefix, depth)
	prefix = prefix or ""
    depth = depth or 1
	for key,value in pairs(tbl) do
		if typeof(value) == "table" then
            if next(value) then
                if depth >= 10 then
                    print("{possible auto ref}")
                else
                    module.print(value, ("%s.%s"):format(prefix, tostring(key)), depth + 1)
                end
            else
                print(("%s.%s = {}"):format(prefix, tostring(key)))
            end
		else
			print(("%s.%s = %s"):format(prefix, tostring(key), tostring(value)))
		end
	end
end

function module.stringify(v, spaces, usesemicolon, depth)
    depth = depth or 1
	if type(v) ~= "table" then
		return tostring(v)
	elseif next(v) == nil then
		return "{}"
    elseif depth >= 10 then
        return "{possible auto ref}"
	end

	spaces = spaces or 2

	local space = (" "):rep(depth * spaces)
	local sep = usesemicolon and ";" or ","
	local concatenationBuilder = {"{"}

	for k, x in next, v do
		table.insert(
            concatenationBuilder,
            ("\n%s[%s] = %s%s"):format(
                space,
                type(k)=="number"and tostring(k)or("%s"):format(tostring(k)),
                module.stringify(x, spaces, usesemicolon, depth+1), sep)
            )
	end

	local s = table.concat(concatenationBuilder)
	return ("%s\n%s}"):format(s:sub(1,-2), space:sub(1, -spaces-1))
end

function module.stringifyKeys(tbl, spaces, usesemicolon, depth)
    local concatenationBuilder = {"{"}
    spaces = spaces or 2
    depth = depth or 1
    local space = (" "):rep(depth * spaces)
    local sep = usesemicolon and ";" or ","
    for k in pairs(tbl) do
        table.insert(concatenationBuilder, ("\n%s[%s]%s"):format(space, tostring(k), sep))
    end
    table.insert(concatenationBuilder,"\n}")
    return table.concat(concatenationBuilder)
end

function module.complementUnrestrained(cTbl, ...)
    for _, tbl in pairs({...}) do
        for key, value in pairs(tbl) do cTbl[key] = value end
    end
end

function module.complementUnrestrainedDeepCopy(cTbl, ...)
    local cTbl_ = module.deepCopy(cTbl)
    for _, tbl in pairs({...}) do
        for key, value in pairs(tbl) do cTbl_[key] = value end
    end
    return cTbl_
end

function module.complementRestrained(cTbl, ...)
    for _, tbl in pairs({...}) do
        for key, value in pairs(tbl) do
            if cTbl[key] == nil then
                cTbl[key] = value
            end
        end
    end
end

function module.complementRestrainedDeepCopy(cTbl, ...)
    local cTbl_ = module.deepCopy(cTbl)
    for _, tbl in pairs({...}) do
        for key, value in pairs(tbl) do
            if cTbl_[key] == nil then
                cTbl_[key] = value
            end
        end
    end
end

function module.concatArrays(...)
	local concatenadArray = {}
	local arrays = {...}
	for _, arr in ipairs(arrays) do
        for _, value in ipairs(arr) do
            table.insert(concatenadArray, value)
        end
	end
	return concatenadArray
end

function module.setTable(tbl, dataTable)
	for key, data in pairs(dataTable) do
		if typeof(data) == "table" then
			tbl[key] = tbl[key] or {}
			module.setTable(tbl[key], data)
		else
			tbl[key] = data
		end
	end
end

function module.setProto(tbl, proto)
	for key, data in pairs(proto) do
		if typeof(data) == "table" then
			tbl[key] = tbl[key] or {}
			module.setProto(tbl[key], data)
		else
			if tbl[key] == nil then
				tbl[key] = data
			end
		end
	end
end

function module.setInstance(instance, dataTable)
	for key, data in pairs(dataTable) do
		if typeof(instance[key]) == "Instance" then
			module.setInstance(instance[key], data)
		else
			instance[key] = data
		end
	end
end

function module.flatNestedTable(tbl, composedKey, flatTable)
    composedKey = composedKey or {}
    flatTable = flatTable or {}
    for k, v in pairs(tbl) do
        local newComposedKey = module.deepCopy(composedKey)
        table.insert(newComposedKey, k)
        if typeof(v) == "table" and next(v) then
            module.flatNestedTable(tbl[k], newComposedKey, flatTable)
        else
            flatTable[newComposedKey] = v
        end
    end
    return flatTable
end

function module.printFlatTable(flatTable)
    for composedKey, v in pairs(flatTable) do
        local key = table.concat(composedKey, "/")
        -- module.print(composedKey)
        print(("%s: %s"):format(key, tostring(v)))
    end
end

function module.filter(tbl, keepFunc)
    local keepTbl = {}
    for k, v in pairs(tbl) do
        if keepFunc(k, v) then keepTbl[k] = v end
    end
	return keepTbl
end

function module.reverse(arr)
    local reverseArr = {}
    local size = #arr
    for i, v in ipairs(arr) do
        reverseArr[size + 1 - i] = v
    end
	return reverseArr
end

function module.applyMask(tbl, mask)
	local composedTable = {}
	local function fillComposedTable(composedTable, mask, composedKey)
		for k, v in pairs(mask) do
			local newComposedKey = module.deepCopy(composedKey)
			table.insert(newComposedKey, k)
			if typeof(v) == "table" then
				fillComposedTable(mask[k], composedTable, newComposedKey)
			else
				composedTable[newComposedKey] = v
			end
		end
	end
	fillComposedTable(composedTable, mask, {})
	local maskedTbl = module.deepCopy(tbl)
	for composedKey, copyValue in pairs(composedTable) do
		if copyValue == false then
			ComposedKey.set(maskedTbl, composedKey, nil)
		end
	end
	return maskedTbl
end

-- Get composed keys from table. When reaching leaf, add a composed key to array. Why? Getter composed keys to be able to set value is super ineficient

return module