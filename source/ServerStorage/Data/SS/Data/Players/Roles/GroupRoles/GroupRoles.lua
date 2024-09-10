local Data = script:FindFirstAncestor("Data")
local Policies = require(Data.Players.Policies.Policies)

local module = {}

module.roles = {
    ["Guest"] = {
        policies = {},
    },
    ["Player"] = {
        policies = {},
    },
    -- ["Contributor"] = {
    --     policies = {},
    -- },
    ["QA Tester"] = {
        policies = {
            [Policies.policies.tester.name] = true
        },
    },
    -- ["Moderator Trainee"] = {
    --     policies = {
    --         [Policies.policies.tester.name] = true,
    --         [Policies.policies.moderatorTrainee.name] = true,
    --     },
    -- },
    -- ["Moderator"] = {
    --     policies = {
    --         [Policies.policies.tester.name] = true,
    --         [Policies.policies.moderatorTrainee.name] = true,
    --         [Policies.policies.moderator.name] = true,
    --     },
    -- },
    -- ["QA Leader"] = {
    --     policies = {
    --         [Policies.policies.tester.name] = true,
    --         [Policies.policies.moderatorTrainee.name] = true,
    --         [Policies.policies.moderator.name] = true,
    --     },
    -- },
    ["Admin"] = {
        policies = {
            [Policies.policies.tester.name] = true,
            [Policies.policies.moderatorTrainee.name] = true,
            [Policies.policies.moderator.name] = true,
            [Policies.policies.freeCam.name] = true,
        },
    },
    -- ["Community Manager"] = {
    --     policies = {
    --         [Policies.policies.tester.name] = true,
    --         [Policies.policies.moderatorTrainee.name] = true,
    --         [Policies.policies.moderator.name] = true,
    --     },
    -- },
    ["Fan"] = {
        policies = {
            [Policies.policies.tester.name] = true,
            [Policies.policies.moderatorTrainee.name] = true,
            [Policies.policies.moderator.name] = true,
            [Policies.policies.freeCam.name] = true,
        },
    },
    ["Co-Owner"] = {
        policies = {
            [Policies.policies.tester.name] = true,
            [Policies.policies.moderatorTrainee.name] = true,
            [Policies.policies.moderator.name] = true,
            [Policies.policies.freeCam.name] = true,
        },
    },
    ["Member"] = {
        policies = {
            [Policies.policies.tester.name] = true,
            [Policies.policies.moderatorTrainee.name] = true,
            [Policies.policies.moderator.name] = true,
            [Policies.policies.freeCam.name] = true,
            [Policies.policies.owner.name] = true,
        },
    },
    ["Owner"] = {
        policies = {
            [Policies.policies.tester.name] = true,
            [Policies.policies.moderatorTrainee.name] = true,
            [Policies.policies.moderator.name] = true,
            [Policies.policies.freeCam.name] = true,
            [Policies.policies.owner.name] = true,
        },
    },
}

for role, roleData in pairs(module.roles) do
    module.roles[role]["permissions"] = {}
    for policyName in pairs(roleData.policies) do
        for permission in pairs(Policies.policies[policyName].permissions) do
            module.roles[role]["permissions"][permission] = true
        end
    end
end

return module