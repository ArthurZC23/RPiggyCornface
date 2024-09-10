local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Set = Mod:find({"DataStructures", "Set"})

local rootFolder = script:FindFirstAncestor("Shared")
local Utils = require(rootFolder:WaitForChild("Utils"))

local module = {}

local classSet = Set.new(
    {"Part", "UnionOperation", "MeshPart"},
    {
        createSetFrom="Values",
    }
)

function module.setOwnershipToPlayer(model, player)
    local f =  function (part)
        part:SetNetworkOwner(player)
    end
    Utils.applyByClass(model, f, classSet.set)
end

function module.setOwnershipToServer(model)
	local f =  function (part)
        --print("Part: ", part)
        part:SetNetworkOwner()
    end
    Utils.applyByClass(model, f, classSet.set)
end

return module