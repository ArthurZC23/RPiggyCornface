local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local BindersMover = Mod:find({"Binder", "Mover"})

local RootF = script:FindFirstAncestor("DaMatrix").Parent

local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage.MegaPack

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

BindersMover.move("Client", RS.Client)
BindersMover.move("Shared", RS.Shared)

local module = {}

return module