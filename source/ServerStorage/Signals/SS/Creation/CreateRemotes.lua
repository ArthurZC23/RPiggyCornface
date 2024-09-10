local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage.Remotes.Events
local RemoteFunctions = ReplicatedStorage.Remotes.Functions

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local defaultEvents = {
    "ThePlayerReady",
    "BigNotificationGui",
    "DisableGuis",
    "PlayMovie",
    "MovieStopped",
    "HamletBridge",
    "TeleportInGame",
    "SessionLockingWarning",
    "NotificationStream",
    "GetSharedData",
}

local gameEvents = {}

local events = TableUtils.concatArrays(defaultEvents, gameEvents)

local defaultFunctions = {
    "GetCache",
    "GetSharedData",
    "SocialRewardsCode",
    "GetDialogueData",
    "GaiaRequestInstance",
    "GaiaDeleteTmpInstance"
}

local gameFunctions = {}

local functions = TableUtils.concatArrays(defaultFunctions, gameFunctions)

for _, name in ipairs(events) do
    if not RemoteEvents:FindFirstChild(name) then
        local event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = RemoteEvents
    end
end

for _, name in ipairs(functions) do
    if not RemoteFunctions:FindFirstChild(name) then
        local func = Instance.new("RemoteFunction")
        func.Name = name
        func.Parent = RemoteFunctions
    end
end

local module = {}

return module