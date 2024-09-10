local sysName = "MasterReplicator"
local RootF = script:FindFirstAncestor(sysName)

require(RootF.SS[sysName])

local module = {}

return module