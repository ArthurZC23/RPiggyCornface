local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})

local module = {}

function module.getTotalMass(model)
    local massArray = {}
    for _, obj in ipairs(model:GetDescendants()) do
        if
            (obj.ClassName == "Part" or
            obj.ClassName == "MeshPart" or
            obj.ClassName == "UnionOperation") and
            not (obj.Massless or
            obj:FindFirstAncestorOfClass("Accessory") )
        then
            table.insert(massArray, obj:GetMass())
        end
    end
    local totalMass = Functional.reduce(
        massArray,
        function(a, b) return a + b end
    )
    return totalMass
end

return module