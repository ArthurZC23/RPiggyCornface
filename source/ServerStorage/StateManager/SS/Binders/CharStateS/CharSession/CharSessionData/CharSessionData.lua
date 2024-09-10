local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings


local module = {}

module.getInitialSession = function(charState)
    local data = {
        Props = {},
        Regions = {
            regions = {["RegionNil"]=true},
        },
------------------------
        MapPuzzles = {
            -- keys you have on you (backpack or equipped)
            keySt = {
                -- [keyId] = true
            },
        },
        Hide = {
            on = false,
        },
    }

    return data
end

return module