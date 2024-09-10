local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local module = {}

for _, binder in ipairs(RS.Client.Binders:GetChildren()) do
    binder.Parent = ReplicatedStorage.Binders.Client
end

-- for _, binder in ipairs(RootF.SS.Binders:GetChildren()) do
--     binder.Parent = ServerStorage.Binders.SS
-- end

return module