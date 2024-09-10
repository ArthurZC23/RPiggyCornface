local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Shared"})

Gaia.createBindables(ReplicatedStorage, {
    events = {
      "GameGenericNotification",
    },
})

local sysName = "Notifications"

local RootF = script:FindFirstAncestor(sysName)

-- do
--     local binder = RootF.SS.Binders.Npc
--     binder.Parent = ServerStorage.Binders.SS
-- end

local module = {}

return module