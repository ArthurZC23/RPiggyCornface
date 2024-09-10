local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("Signals")

local RS = RootF.RS
RS.Parent = ReplicatedStorage.MegaPack
RS.Name = "Signals"

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local module = {}

return module
