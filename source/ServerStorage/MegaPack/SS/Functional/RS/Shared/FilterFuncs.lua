local root = script.Parent
local Functional = require(root.Functional)

local filters = {}

function filters.filterArrayByClasses(array, classesNames)
	local filterFunc = function(element)
		for _, name in pairs(classesNames) do
			if element:IsA(name) then return true end
		end
		return false
	end
	return Functional.filter(array, filterFunc)
end

return filters