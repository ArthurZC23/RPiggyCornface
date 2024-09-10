local function reverse(arr)
    local reverseArr = {}
    local size = #arr
    for i, v in ipairs(arr) do
        reverseArr[size + 1 - i] = v
    end
	return reverseArr
end

local module = {}

function module.get(tbl, composedKey)
	local val = tbl
	composedKey = composedKey or {}
    local size = #composedKey
	for i, key in ipairs(composedKey) do
		val = val[key]
        if val == nil then return end
        if (typeof(val) ~= "table") and (i ~= size) then return end
	end
	return val
end

function module.set(tbl, composedKey, value)
	local val = tbl
	for i, key in ipairs(composedKey) do
		if i == #composedKey then
			val[key] = value
		else
			val[key] = val[key] or {}
			val = val[key]
		end
	end
	val = val
end

function module.getEvent(root, remote)
    return module.getFirstDescendant(root, {"Remotes", "Events", remote})
end
function module.getEventAsync(root, remote)
    return module.getAsync(root, {"Remotes", "Events", remote})
end

function module.getBEvent(root, event)
    return module.getFirstDescendant(root, {"Bindables", "Events", event})
end
function module.getBEventAsync(root, event)
    return module.getAsync(root, {"Bindables", "Events", event})
end

function module.getFunction(inst, remote)
    return module.getFirstDescendant(inst, {"Remotes", "Functions", remote})
end

function module.getFirstDescendant(inst, composedKey)
    assert(inst:IsA("Instance"), ("%s is not an instance."):format(inst:GetFullName()))
    local val = inst
    composedKey = composedKey or {}
	for _, key in ipairs(composedKey) do
		val = val:FindFirstChild(key)
        if val == nil then return end
	end
	return val
end

function module.getAncestry(inst, ancestor, cb)
    assert(inst:IsA("Instance"), ("%s is not an instance."):format(inst:GetFullName()))
    local lastParent = inst.Parent
    if not lastParent then return end
    if lastParent == ancestor then return {} end
    cb = cb or function(x) return x end
    local composedKey = {cb(lastParent)}
    while lastParent ~= ancestor and lastParent ~= nil do
        lastParent = lastParent.Parent
        if lastParent ~= ancestor and lastParent ~= nil  then
            table.insert(composedKey, cb(lastParent))
        end
    end
	return reverse(composedKey)
end

-- This only works for Instances.
function module.getAsync(inst, composedKey)
    assert(inst:IsA("Instance"), ("%s is not an instance."):format(inst:GetFullName()))
	local val = inst
	composedKey = composedKey or {}
	for _, key in ipairs(composedKey) do
		val = val:WaitForChild(key)
	end
	return val
end

-- This only works for Instances.
function module.setAsync(inst, composedKey, value)
    assert(inst:IsA("Instance"), ("%s is not an instance."):format(inst:GetFullName()))
	local val = inst
	for i, key in ipairs(composedKey) do
		if i == #composedKey then
			val[key] = value
		else
			val = val:WaitForChild(key)
		end
	end
	val = val
end

function module.parentInstance(inst, composedKey)
    assert(inst:IsA("Instance"), ("%s is not an instance."):format(inst:GetFullName()))
    local totalPath = {}
    local previousAncestor
	for i, path in ipairs(composedKey) do
        table.insert(totalPath, path)
        local ancestor = module.getFirstDescendant(game, totalPath)
        if not ancestor then
            ancestor = Instance.new("Model")
            ancestor.Name = path
            ancestor.Parent = previousAncestor
        end
		if i == #composedKey then
			inst.Parent = ancestor
		end
        previousAncestor = ancestor
	end
end

return module
