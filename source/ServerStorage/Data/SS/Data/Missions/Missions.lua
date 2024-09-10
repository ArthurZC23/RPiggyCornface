local Data = script:FindFirstAncestor("Data")

local module = {}

module.idData = {
    ["1"] = {
        name = "MudPuppy",
        active = true,
        prettyName = "Find the lost Mud Puppy",
        description = "Mud Puppy was playing around the house and suddenly he disappered! No one see's him in days! YOU need to help us to find the puppy! Follow his footsteps and find him!",
        clientHandler = {
            name = "MudPuppyMissionC",
        },
        serverHandler = {
            name = "MudPuppyMissionS",
        },
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module