local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local FastModeData = Data.Settings.FastMode
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local module = {}

if RunService:IsClient() then
    local localPlayer = Players.LocalPlayer
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})
    local settingsState = playerState:get(S.Stores, "Settings")
    local mode = FastModeData.idToName[settingsState.FastMode]
    module = {
        isFastMode = (mode == "Fast"),
    }
else
    function module.isFastMode(player)
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
        local settingsState = playerState:get(S.Stores, "Settings")
        local mode = FastModeData.idToName[settingsState.FastMode]
        return mode == "Fast"
    end
end

return module