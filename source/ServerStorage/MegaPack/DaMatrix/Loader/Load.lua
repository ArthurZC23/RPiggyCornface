local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("MegaPack")
local MegaPackS = RootF.SS

for _, packageRootFolder in ipairs(MegaPackS:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local MegaPackShared = ReplicatedStorage.MegaPack.Shared
for _, packageRootFolder in ipairs(MegaPackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local module = {}

return module