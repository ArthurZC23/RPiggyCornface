local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = script:FindFirstAncestor("Data")
local Keys = require(Data.Puzzles.Keys)

local module = {}

module.studio = {
    ["925418276"] = {
        -- MapPuzzles = {
        --     keySt = {
        --         [Keys.nameData.Screwdriver.id] = true,
        --     },
        -- },
    },
    ["-1"] = {

    },
    ["-2"] = {

    },
    ["-3"] = {

    },
    ["-4"] = {

    },
    ["-5"] = {

    },
    ["Proto"] = {

    },
}

return module