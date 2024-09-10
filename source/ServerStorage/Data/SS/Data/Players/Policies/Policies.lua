local module = {}

module.policies = {
    tester = {
        name = "tester",
        permissions = {
            accessTestServer = true
        },
    },
    freeCam = {
        name = "freeCam",
        permissions = {
            freeCam = true
        },
    },
    moderatorTrainee = {
        name = "moderatorTrainee",
        permissions = {
            useModerationTraineeCommands = true,
        },
    },
    moderator = {
        name = "moderator",
        permissions = {
            useModerationCommands = true,
        },
    },
    owner = {
        name = "owner",
        permissions = {
            ownerCommands = true,
        },
    },
}

return module