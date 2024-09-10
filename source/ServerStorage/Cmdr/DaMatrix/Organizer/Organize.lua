local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("Cmdr")

local RS = RootF.RS
RS.Name = "Cmdr"
RS.Parent = ReplicatedStorage

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local module = {}

return module