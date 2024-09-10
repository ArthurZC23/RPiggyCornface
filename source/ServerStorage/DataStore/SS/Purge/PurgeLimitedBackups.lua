local DataStoreService = game:GetService("DataStoreService")

local function clear(userId, name)
    local CURRENT_KEY = "Newest" -- Confirm if it's this one
	local dataStore = DataStoreService:GetDataStore(name .. "/" .. userId)
    local lastData = dataStore:GetAsync(CURRENT_KEY)
    local lastKey = lastData.key
    for key=1, lastKey do
        print(("Remove key %s"):format(key))
        dataStore:RemoveAsync(tostring(key))
    end
    print("Remove current key")
    dataStore:RemoveAsync(CURRENT_KEY)
end

-- local name = "DATA"
-- local userId = 1836255969

-- clear(userId, name)