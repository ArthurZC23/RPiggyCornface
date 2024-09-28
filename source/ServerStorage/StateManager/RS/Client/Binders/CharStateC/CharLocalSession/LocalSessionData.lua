local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local HumanoidData = Data.Char.Humanoid
local LocalData = Mod:find({"Data", "LocalData"})
local CameraViewsData = LocalData.Camera.CameraViews
local SettingsView = LocalData.Settings.Settings.view

local module = {}

module.getInitialSession = function()
    local data = {

        ------------------------
        Animation = {
            trackIdle = {},
            trackAction1 = {},
            trackAction2 = {},
        },
        Crawl = {
            on = false,
        },
    }
    return data
end

return module