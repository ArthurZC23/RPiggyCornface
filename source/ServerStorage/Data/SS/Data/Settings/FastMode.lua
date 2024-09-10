local module = {}

module.idToName = {
    ["1"] = "Normal",
    ["2"] = "Fast",
    ["3"] = "SuperFast",
}
module.nameToId = {
    ["Normal"] = "1",
    ["Fast"] = "2",
    ["SuperFast"] = "3",
}

for name, id in pairs(module.nameToId) do
    module.idToName[id] = name
end

return module