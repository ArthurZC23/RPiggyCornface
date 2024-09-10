local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local module = {}

module._bindersFolders = {
    Client = ReplicatedStorage.Binders.Client,
    Shared = ReplicatedStorage.Binders.Shared,
    Server = ServerStorage.Binders.SS,
}

function module.move(destiny, rootInstance)
    local bindersFolder = module._bindersFolders[("%s"):format(destiny)]
    for _, desc in ipairs(rootInstance:GetDescendants()) do
        if desc.Name == "BinderClass" then
            local binder = desc.Parent
            binder.Parent = bindersFolder
        end
    end
end

return module