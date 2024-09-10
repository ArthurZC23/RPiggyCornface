local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("GamePack")
local GamePackS = RootF.SS

for _, packageRootFolder in ipairs(GamePackS:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local GamePackShared = ReplicatedStorage.GamePack.Shared
for _, packageRootFolder in ipairs(GamePackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local module = {}

return module