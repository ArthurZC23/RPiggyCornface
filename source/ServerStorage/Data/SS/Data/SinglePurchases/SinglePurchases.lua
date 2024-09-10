local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {}

module.Status = {
    ["Started"] = "1",
    ["Finished"] = "2",
}

module.data = {
    --{name=S.StarterPack, id=""},
}

local function createMappings()
    module.nameToData = {}
    module.idToData = {}
    for _, data in pairs(module.data) do
        module.nameToData[data.name] = data
        module.idToData[data.id] = data
    end
end
createMappings()

return module