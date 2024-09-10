local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootFolder = script:FindFirstAncestor("DataStore")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))

local GaiaShared = Mod:find({"Gaia", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})

GaiaServer.createRemotes(ReplicatedStorage, {
    events={
        "TryDeveloperPurchase",
    },
})

GaiaShared.createBindables(ServerStorage, {
    events={
        "TryDeveloperPurchase",
    },
})

require(RootFolder.SS.DevProductPurchase)
require(RootFolder.SS.ProcessReceipt)

local module = {}

return module