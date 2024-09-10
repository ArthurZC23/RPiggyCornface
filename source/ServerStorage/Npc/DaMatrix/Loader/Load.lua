local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent

do
    local binders = RootF.SS.Binders
    for _, binder in ipairs(binders:GetChildren()) do
        binder.Parent = ServerStorage.Binders.SS
    end
end

local module = {}

return module