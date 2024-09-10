local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage.MegaPack

do
    local bindersClient = RS.Client.Binders
    local destenyFolder = ReplicatedStorage.Binders.Client
    for _, binder in ipairs(bindersClient:GetChildren()) do
        binder.Parent = destenyFolder
    end
end

local module = {}

return module