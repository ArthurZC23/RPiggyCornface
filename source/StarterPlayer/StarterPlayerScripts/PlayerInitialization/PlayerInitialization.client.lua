local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local RootF = script:FindFirstAncestor("PlayerInitialization")
local localPlayer = Players.LocalPlayer

ReplicatedStorage:WaitForChild("GameLoaded")

SharedSherlock:find({"WaitFor", "Val"}, {
    getter=function()
        local playerReady = localPlayer:GetAttribute("PlayerReady")
        if not playerReady then return nil, "PlayerReady attr was not found." end
        return true
    end,
    keepTrying=function()
        return true
    end,
})

require(RootF:WaitForChild("OrganizePlayerMatrix"))
require(RootF:WaitForChild("LoadPlayerMatrix"))