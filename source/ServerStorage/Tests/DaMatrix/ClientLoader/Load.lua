local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("Tests")

-- Comment out tests that are not running. Tmp solution.
--require(Tests.SpecificTest)

local module = {}

local binders = RootF.Client.Binders
for _, b in ipairs(binders:GetChildren()) do
     b.Parent = ReplicatedStorage.Binders.Client
end

return module