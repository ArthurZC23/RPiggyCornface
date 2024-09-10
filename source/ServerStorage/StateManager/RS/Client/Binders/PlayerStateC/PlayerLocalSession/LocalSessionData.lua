local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local HumanoidData = Data.Char.Humanoid
local LocalData = Mod:find({"Data", "LocalData"})
local CameraViewsData = LocalData.Camera.CameraViews

local module = {}

module.getInitialSession = function()
    return {
        Admin = {
            experience = {
                placeId = nil,
            },
        },
        Teleport = {
            cf = nil,
            kwargs = nil,
            isTeleporting = nil,
        },
        Humanoid = {

        },
        CameraView = {
            view = CameraViewsData.views.Standard,
        },
------------------------
        House = {
            plotSelection = nil,
        },
        AvatarGui = {
            -- like eq st
            viewTab = nil,
            tabs = {
                -- tab1 = tab2
            },
            assetsCache = {},
        },
        BecomeMonsterGui = {
            viewTab = nil,
        },
        ShopGui = {
            -- like eq st
            viewTab = nil,
        },
        SpinWheelGui = {
            viewTab = nil,
        },
    }
end

return module