local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage.MegaPack

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local module = {}

return module