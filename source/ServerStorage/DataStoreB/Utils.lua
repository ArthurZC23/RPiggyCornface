local utils = {}

local function cloneTable(tbl)
    local clone = {}

	for key, value in pairs(tbl) do
		if typeof(value) == "table" then
			clone[key] = cloneTable(value)
		else
			clone[key] = value
		end
	end

	return clone
end

function utils.clone(value)
	if typeof(value) == "table" then
		return cloneTable(value)
	else
		return value
	end
end

function utils.offlineData(backupRetries, backupValue)
	local max_retries = backupRetries
	local validRetryNumber = type(max_retries) == "number" and max_retries > 0
	if validRetryNumber then
		local backupCount = 0
		return function()
			backupCount = backupCount + 1
			if backupCount >= max_retries then
				return {
					backup = true,
					haveValue = true,
					value = backupValue
				}

			end
		end
	end
end

return utils