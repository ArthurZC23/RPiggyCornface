local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

for _, region in ipairs(CollectionService:GetTagged("Region")) do
    region.CanCollide = false
    region.Transparency = 1
    if region:GetAttribute("regionEditModeOffset") ~= nil then
        region.Position = region.Position - region:GetAttribute("regionEditModeOffset")
    end
end

local module = {
    raycast = {
        frameRate = 30,
    },
    pooling = {
        cooldown = 0.5,
    },
}

module.raycast.period = 1 / module.raycast.frameRate

module.regions = {
    ["RegionNil"]="RegionNil",
    ["RegionLobby"] = "RegionLobby",
    ["RegionArena"] = "RegionArena",
    ["RegionObby"] = "RegionObby",
}
module.regions = Mts.makeEnum("Regions", module.regions)

module.regionsData = {
    ["RegionNil"] = {},
    ["RegionLobby"] = {},
    ["RegionArena"] = {},
    ["RegionObby"] = {},
}

-- add and remove at the same time
module.regionsEvents = {
    ["RegionNil"] = {},
    ["RegionLobby"] = {},
    ["RegionArena"] = {},
    ["RegionObby"] = {},
}

module.addRegionsEvents = {
    ["RegionNil"] = {},
    ["RegionLobby"] = {
        ["PlaySoundtrack"] = {
            soundtrackName = "Default",
            fadeIn = {
                duration = 1,
            },
            fadeOut = {
                duration = 0.5,
            },
        },
    },
    ["RegionArena"] = {
        ["PlaySoundtrack"] = {
            soundtrackName = "Arena",
            fadeIn = {
                duration = 1,
            },
            fadeOut = {
                duration = 0.5,
            },
        },
    },
    ["RegionObby"] = {
        ["PlaySoundtrack"] = {
            soundtrackName = "Obby",
            fadeIn = {
                duration = 1,
            },
            fadeOut = {
                duration = 0.5,
            },
        },
    },
}

module.removeRegionsEvents = {
    ["RegionNil"] = {},
    ["RegionLobby"] = {},
    ["RegionArena"] = {},
    ["RegionObby"] = {},
}

-- module.regionToCode = {
--     [module.regions["RegionNil"]] = "1",
-- }

-- module.codeToRegion = {}
-- for regionName, code  in pairs(module.regionToCode) do
--     module.codeToRegion[code] = regionName
-- end

return module