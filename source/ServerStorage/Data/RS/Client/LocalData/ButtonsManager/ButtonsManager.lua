--[[
    Deal with frontpage gui open/close.
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local TableUtils = Mod:find({"Table", "Utils"})

local Bindables = ReplicatedStorage.Bindables

local module = {}

module.guisData = {
    ["TeleportToOtherGame"] = {
        guiType = "Player",
        name = "TeleportToOtherGameController",
        open = {
            guiName="TeleportToOtherGame",
            btnName=nil,
            eventLikeBtn="TeleportToOtherGameBtn",
        },
        close = {},
    },
    ["OtherGames"] = { -- guiKey (two keys could refer to the same gui...e.g. shop with different views)
        guiType = "Player", -- guiType Player/Char
        name = "OtherGamesGridController", -- Unique Controller/View to open. In a tab gui there is a manager.
        -- Only 1 button? Yes. This is an entry for 1 button
        open = {
            btnName="OtherGamesBtn",
            guiName="OtherGames",
            eventLikeBtn=nil, -- event to open this gui like this button
            uxKwargs = {
                dilatation = {
                    expandFactor = {
                        X=1.05,
                        Y=1.05,
                    }
                }
            }
        },
        close = {},
    },
}

local proto = {
    close = {
        hasExitBtn = true,
    }
}
for _, data in pairs(module.guisData) do
    TableUtils.setProto(data, proto)
end

return module