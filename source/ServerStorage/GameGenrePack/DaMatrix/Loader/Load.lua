local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("GameGenrePack")
local GameGenrePackS = RootF.SS

for _, packageRootFolder in ipairs(GameGenrePackS:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local GameGenrePackShared = ReplicatedStorage.GameGenrePack.Shared
for _, packageRootFolder in ipairs(GameGenrePackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Load)
end

local module = {}

return module