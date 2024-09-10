local module = {}

function module.split(inputStr, sep)
    assert(typeof(inputStr) == "string")
    assert(typeof(sep) == "string")
	if sep == nil then sep = "%s" end
	local tbl ={}
	for str in string.gmatch(inputStr, "([^"..sep.."]+)") do
		table.insert(tbl, str)
	end
	return tbl
end

function module.firstLowerCase(str)
    return str:gsub("^%u", string.lower)
end

return module