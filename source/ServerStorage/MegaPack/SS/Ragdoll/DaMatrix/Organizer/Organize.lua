local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

for _, binder in ipairs(RootF.RS.Client.Binders:GetChildren()) do
    binder.Parent = ReplicatedStorage.Binders.Client
end

for _, binder in ipairs(RootF.SS.Binders:GetChildren()) do
    binder.Parent = ServerStorage.Binders.SS
end

local module = {}

return module