local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local TryDeveloperPurchaseBE = ServerStorage.Bindables.Events:WaitForChild("TryDeveloperPurchase")

return function (context, player, stateType, scope)
    TryDeveloperPurchaseBE:Fire(player, "1217984589")

	return true
end