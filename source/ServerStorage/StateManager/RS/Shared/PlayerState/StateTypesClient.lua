local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local module = {}

module.enum = Mts.makeEnum("StateTypesClient", {
    ["Stores"] = "Stores",
    ["Session"] = "Session",
    ["LocalSession"] = "LocalSession",
})

module.array = {}

for k in pairs(module.enum) do table.insert(module.array, k) end

return module