local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local BindersMover = Mod:find({"Binder", "Mover"})

local RootF = script:FindFirstAncestor("Vehicles")
local RS = RootF.RS
RS.Name = RootF.Name
RS.Parent = ReplicatedStorage

local ClientLoader = RootF.DaMatrix.ClientLoader
ClientLoader.Name = "Loader"
ClientLoader.Parent = RS.Client

local SS = RootF.SS

BindersMover.move("Client", RS.Client.Binders)
BindersMover.move("Server", RootF.SS.Binders)

local module = {}

return module