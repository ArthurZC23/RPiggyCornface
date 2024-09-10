local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local DsbStores = Data.DataStore.DsbStores

local module = {}

module.schemaUpdates = {}

function module.fixStates(stores)
    if stores.Schema.ver ~= DsbStores.schemaVersion then
        local currentSchemaNum = stores.Schema.ver
        if currentSchemaNum == nil then
            currentSchemaNum = 0
        end
        while currentSchemaNum < DsbStores.schemaVersion do
            currentSchemaNum += 1
            module.schemaUpdates[tostring(currentSchemaNum)](stores)
        end
    end
end

return module