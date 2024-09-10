local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Server"})

local RootF = script:FindFirstAncestor("ServerType")

Gaia.createRemotes(ReplicatedStorage, {
    functions={
        "GetServerType"
    }
})

require(RootF.SS.ServerType)

local module = {}

return module