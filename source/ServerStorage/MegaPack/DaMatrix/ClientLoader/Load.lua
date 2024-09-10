local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Every package need a loading module, even if it's nil.
local MegaPackC = ReplicatedStorage.MegaPack.Client
for _, packageRootFolder in ipairs(MegaPackC:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local MegaPackShared = ReplicatedStorage.MegaPack.Shared
for _, packageRootFolder in ipairs(MegaPackShared:GetChildren()) do
    local daMatrix = packageRootFolder.DaMatrix
    require(daMatrix.Loader.Loader)
end

local module = {}

return module