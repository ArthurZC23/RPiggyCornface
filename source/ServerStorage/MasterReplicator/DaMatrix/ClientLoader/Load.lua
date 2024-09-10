local sysName = "MasterReplicator"
local RootF = script:FindFirstAncestor(sysName)

require(RootF.Client[sysName])

local module = {}

return module