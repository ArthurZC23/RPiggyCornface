local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Handlers = script.Parent.Handlers

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local productsData = Data.DataStore.DeveloperProducts

local map = {}
for id, pData in pairs(productsData) do
    map[id] = require(Handlers[pData.handler]).handler
end


return map