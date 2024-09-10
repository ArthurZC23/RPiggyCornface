local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Every package need a loading module, even if it's nil.
local GamePackC = ReplicatedStorage.GamePack.Client
for _, packageRootFolder in ipairs(GamePackC:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local GamePackShared = ReplicatedStorage.GamePack.Shared
for _, packageRootFolder in ipairs(GamePackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local module = {}

return module