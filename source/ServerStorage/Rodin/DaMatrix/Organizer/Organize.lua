local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootF = script:FindFirstAncestor("DaMatrix").Parent
local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local BindersMover = Mod:find({"Binder", "Mover"})

BindersMover.move("Server", RootF.SS.Binders)
BindersMover.move("Client", RS.Client.Binders)

local module = {}

return module