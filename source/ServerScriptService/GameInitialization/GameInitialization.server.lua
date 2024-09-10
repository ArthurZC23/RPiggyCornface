local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RootF = script:FindFirstAncestor("GameInitialization")

require(RootF.OrganizeDaMatrix)
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
require(RootF.LoadDaMatrix)
local Gaia = Mod:find({"Gaia", "Shared"})

Gaia.create("BoolValue", {
    Name="GameLoaded",
    Value=true,
    Parent = ReplicatedStorage,
})