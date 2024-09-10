local module = {}

module.idToData = {}

module.idToData["1"] = {
    prettyName = "code1",
    message = "Test Code",
    startDate = {day=30, month=3, year=2021},
    expirationDate = {day=10, month=2, year=2090},
    removalData = {day=20, month=2, year=2090}
}

module.prettyNameToId = {}

for id, data in pairs(module.idToData) do
    assert(not module.prettyNameToId[data.prettyName], "Cannot repeat names in social reward codes.")
    module.prettyNameToId[data.prettyName] = id
end

return module