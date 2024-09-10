local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("DataAsync")

local RS = RootF.RS
RS.Name = "DataAsync"
RS.Parent = ReplicatedStorage

local module = {}

return module