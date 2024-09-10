local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("John")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Shared"})

Gaia.createBindables(ServerStorage, {
    events={
        "JohnShout"
    }
})

require(RootF.AddJohnToChat)

local module = {}

return module