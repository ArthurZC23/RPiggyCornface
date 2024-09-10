local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {
    scores = {},
}

module.scores.nameToId = {}
module.scoreTypes = Mts.makeEnum("CharScoreNameToId", module.scores.nameToId)

module.scores.idToData = {}

for name, data in pairs(module.scores.nameToId) do
    data.name = name
    module.scores.nameToId[data.name] = data
    module.scores.idToData[data.id] = data
end
module.idToData = Mts.makeEnum("CharScoreIdToName", module.scores.nameToId)



return module