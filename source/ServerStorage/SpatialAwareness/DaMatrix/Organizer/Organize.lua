local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage

do
    local bindersClient = RS.Client.Binders
    local destenyFolder = ReplicatedStorage.Binders.Client
    for _, binder in ipairs(bindersClient:GetChildren()) do
        binder.Parent = destenyFolder
    end
end

do
    local bindersServer = RootF.SS.Binders
    local destenyFolder = ServerStorage.Binders.SS
    for _, binder in ipairs(bindersServer:GetChildren()) do
        binder.Parent = destenyFolder
    end
end

-- do
--     local bindersShared = RS.Shared.Binders
--     for _, destenyFolder in ipairs({ReplicatedStorage.Binders.Client, ServerStorage.Binders.SS}) do
--         for _, binder in ipairs(bindersShared:GetChildren()) do
--             binder:Clone().Parent = destenyFolder
--         end
--     end
--     bindersShared:Destroy()
-- end

local module = {}

return module