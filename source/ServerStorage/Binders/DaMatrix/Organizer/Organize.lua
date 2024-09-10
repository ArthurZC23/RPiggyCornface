local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local BindersMover = Mod:find({"Binder", "Mover"})

local RootF = script:FindFirstAncestor("Binders")
local RS = RootF.RS

BindersMover.move("Client", RS.Client)
BindersMover.move("Shared", RS.Shared)

local module = {}

return module