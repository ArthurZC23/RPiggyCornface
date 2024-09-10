local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sysName = "Leaderboard"

local RootF = script:FindFirstAncestor(sysName)

do
    local binders = RootF.Client.Binders
    for _, b in ipairs(binders:GetChildren()) do
         b.Parent = ReplicatedStorage.Binders.Client
    end
end

local module = {}

return module