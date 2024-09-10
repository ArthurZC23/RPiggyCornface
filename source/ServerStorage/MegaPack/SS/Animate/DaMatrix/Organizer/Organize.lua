local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

for _, binder in ipairs(RootF.RS.Client:GetChildren()) do
    binder.Parent = ReplicatedStorage.Binders.Client
end

local module = {}

return module