local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Data = Mod:find({"Data", "Data"})
local DataStoreBConfig = Data.DataStore.DsbConfig

return {
	-- OrderedBackups: The berezaa method that ensures prevention of data loss
	-- Standard: Standard data stores. Equivalent to :GetDataStore(key):GetAsync(UserId)
	-- LimitedBackup: Refactor of berezaa method to have a cyclic number of backuns and no need for ordered DS
	SavingMethod = DataStoreBConfig.SAVING_METHOD,
}