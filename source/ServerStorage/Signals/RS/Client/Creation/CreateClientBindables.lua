local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local defaultEvents = {
    "BigNotificationGui",
    "ClientViewPortSizeChange",
    "DisableGuis",
    "TeleportInGame",
    "NotificationStream",
}

local guiEvents = {
    "ActivateShopTab",
    "ShowPopUp",
}

local movieEvents = {
    "PlayMovie",
    "MovieStopped",
    "SkipMovie",
    "EnableSkipMovie",
}

local gameEvents = {

}

local events = TableUtils.concatArrays(defaultEvents, guiEvents, gameEvents, movieEvents)

local defaultFunctions = {

}

local gameFunctions = {

}

local functions = TableUtils.concatArrays(defaultFunctions, gameFunctions)

local GaiaShared = Mod:find({"Gaia", "Shared"})
GaiaShared.createBindables(ReplicatedStorage, {
    events = events,
    functions = functions,
})

local module = {}

return module