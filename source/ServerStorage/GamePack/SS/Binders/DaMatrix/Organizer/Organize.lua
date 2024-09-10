local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local BindersMover = Mod:find({"Binder", "Mover"})

local RootF = script:FindFirstAncestor("Binders")
local RS = RootF.RS
local SS = RootF.SS

BindersMover.move("Client", RS.Client)
BindersMover.move("Shared", RS.Shared)
BindersMover.move("Server", SS)

local module = {}

return module