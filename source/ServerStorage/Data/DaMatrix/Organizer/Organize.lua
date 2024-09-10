local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("Data")

local RS = RootF.RS
RS.Name = "Data"
RS.Parent = ReplicatedStorage

local module = {}

return module