local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sysName = "Collisions"
local RootF = script:FindFirstAncestor(sysName)

local RS = RootF.RS
RS.Name = sysName
RS.Parent = ReplicatedStorage

local module = {}

return module