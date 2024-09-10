local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

do
    local Binders = RootF.SS.Binders
    for _, binder in ipairs(Binders:GetChildren()) do
        binder.Parent = ServerStorage.Binders.SS
    end
end

local module = {}

return module