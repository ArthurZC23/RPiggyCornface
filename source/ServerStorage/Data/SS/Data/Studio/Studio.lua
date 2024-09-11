local RunService = game:GetService("RunService")

local Data = script:FindFirstAncestor("Data")
local ServerTypesData = require(Data.Game.ServerTypes)

local module = {}

module = {}

module.testSpawnAllTime = true
-- module.testSpawnOneTime = true
-- module.startScreen = true

-- module.disableLights = true

module.friends = {
    allFriends = true,
}

module.group = {
    areFakePlayersInGroup = true,
    mockRole = {
        ["925418276"] = "Owner",
        ["-1"] = "Admin",
        ["-2"] = "Member",
    },
}

module.isUserPremium = true

-- Team
module.initialTeam = "engine"

-- Monster
module.muteMonsterSound = false
module.monsterCanKill = true
module.noNpcMonster = false
module.spawnAsMonster = false

module.gps = {
    -- useMockGps = true
    -- giveGpsForFreeOnPurchase = true,
    hasGps = {
        -- ["872191424"] = {},
        -- ["910991352"] = {},
        -- ["911311691"] = {},
    },
}

module.camera = {
    ignoreCameraLock = false,
}

module.platform = {
    -- platform = "Console",
}

module.cases = {
    -- debugWithMultipleOpens = true,
}

module.waitFor = {
    -- alwaysUseDefault = true,
}

local envs = {
    [ServerTypesData.sTypes.StudioNotPublished] = true,
    [ServerTypesData.sTypes.StudioPublishedPrivate] = true,
    [ServerTypesData.sTypes.StudioPublishedTest] = true,
    [ServerTypesData.sTypes.StudioPublishedProduction] = true,
    [ServerTypesData.sTypes.LivePrivate] = true,
    [ServerTypesData.sTypes.LiveTest] = true,
}
if not envs[ServerTypesData.ServerType] then
    -- Spawn
    module.freeSpawn = false

    -- Map
    module.disableLights = false

    -- Monster
    module.noNpcMonster = false
    module.monsterCanKill = true
    module.muteMonsterSound = false


    -- module.startScreen = true
end

return module