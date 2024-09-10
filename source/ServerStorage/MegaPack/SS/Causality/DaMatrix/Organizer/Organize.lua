local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage.MegaPack

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

do
    local bindersShared = RS.Shared.Binders
    for _, destenyFolder in ipairs({ReplicatedStorage.Binders.Client, ServerStorage.Binders.SS}) do
        for _, binder in ipairs(bindersShared:GetChildren()) do
            binder:Clone().Parent = destenyFolder
        end
    end
    bindersShared:Destroy()
end

local module = {}

return module