local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("Tests")

local Tests = RootF.SS.Tests

-- Comment out tests that are not running. Tmp solution.
--require(Tests.SpecificTest)

local module = {}

do
    local Binders = RootF.SS.Binders
    for _, binder in ipairs(Binders:GetChildren()) do
        binder.Parent = ServerStorage.Binders.SS
    end
end

return module