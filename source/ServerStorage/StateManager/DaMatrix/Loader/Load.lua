local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local module = {}

CollectionService:AddTag(game, "GameState")
local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

return module