local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Every package need a loading module, even if it's nil.
local GameGenrePackC = ReplicatedStorage.GameGenrePack.Client
for _, packageRootFolder in ipairs(GameGenrePackC:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local GameGenrePackShared = ReplicatedStorage.GameGenrePack.Shared
for _, packageRootFolder in ipairs(GameGenrePackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local module = {}

return module