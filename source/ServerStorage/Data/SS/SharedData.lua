local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local SS = script.Parent
local Data = require(SS.DataS)

local GetSharedDataRF = ReplicatedStorage.Remotes.Functions:WaitForChild("GetSharedData")

local module = {}

-- Is not necessary setting true keys in order to work, only false.
module.mask = {
    Animations={
        Animations=true,
    },
    Badges = {
        Badges = false,
    },
    Boosts = {},
    Camera={
        Camera=true,
    },
    DataStore = false,
    GamePasses = true,
    Mobile = true,
    Players = {
        Bans=false,
    },
    Money_1 = {
        UI=true,
        Shop=false
    },
    Robux={
        UI=false
    },
    Particles = {
        Particles = false,
    },
    Spawner = false,
    SocialRewards = {
        CodeStatus = true,
        SocialCodes = false,
    },
}

-- module.sharedData = TableUtils.applyMask(Data, module.mask)
module.sharedData = TableUtils.deepCopy(Data)
local function _filter(tbl)
    for key, value in pairs(tbl) do
        if typeof(value) == "table" then
            if value._serverOnly then
                tbl[key] = nil
            else
                _filter(value)
            end
        end
    end
end
_filter(module.sharedData)

GetSharedDataRF.OnServerInvoke = function()
    return module.sharedData
end

-- Debug
--TableUtils.print(module.sharedData)

return module