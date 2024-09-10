local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local Utils = require(script.Parent.SessionDataUtils)

local module = {}

module.getInitialSession = function(playerState)
    local data = {
        CharTags = {},
        Membership = {membership=playerState.player.MembershipType},
        Debounces = {},
        Gui = {
            onPurchase = false,
        },
        Teleport = {
            cf = nil,
            kwargs = nil,
            isTeleporting = nil,
        },
        Friends = {
            playerType = {
                -- I can use the CF trick here
                -- Risk of player left. Even so, even I store the name is the same problem.
                -- player = true
            },
            numFriends = 0,
            friends = {},
        },
        Physics = {
            anchored = false,
        },
        Multipliers = Utils.unitMultipliers(),
        Time = {
            playerTimePlayedOnJoin = 60 * playerState:get(S.Stores, "Scores").TimePlayed.allTime
        },
        PolicyService = {
            ads = nil,
            current = {},
        },
------------------------
        _Game = {},
        MapTokens = {
            st = {},
            total = 0,
        },
        Lives = {
            cur = 0, -- current
            previousLifeCache = nil,
            shouldSyncCache = false,
        },
        Items = {
            st = {},
        },
        ScreenFader = {},
    }
    return data
end

-- This should use state actions for reset
module.resetSession = function()
    return {
        -- SessionKey
    }
end

return module