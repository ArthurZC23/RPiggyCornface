local Data = script:FindFirstAncestor("Data")
local Animations = require(Data.Animations.Animations)

local module = {}

module.idData = {
    ["1"] = {
        name = "HandsUp",
        prettyName = "Hands Up",
        clientHandler = {
            name = "PlayAnimation",
            animName = "HandsUp",
        },
        serverHandler = {
            name = "PlayAnimation",
        },
        conditions = {
            bodyType = {
                human = true,
            },
            rigType = {
                R15 = true,
            },
        },
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module