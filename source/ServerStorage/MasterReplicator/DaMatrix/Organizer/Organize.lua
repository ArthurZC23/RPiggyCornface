local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sysName = "MasterReplicator"
local RootF = script:FindFirstAncestor(sysName)

local RS = RootF.RS
RS.Parent = ReplicatedStorage
RS.Name = sysName

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local module = {}

return module