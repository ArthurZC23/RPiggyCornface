local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local BindableEvents = ServerStorage.Bindables.Events
local BindableFunctions = ServerStorage.Bindables.Functions

local defaultEvents = {
    "ThePlayerReady",
    "ThePlayerExit",
    "TheCharacterReady",
}

local gameEvents = {

}

local events = TableUtils.concatArrays(defaultEvents, gameEvents)

local defaultFunctions = {}

local gameFunctions = {
}

local functions = TableUtils.concatArrays(defaultFunctions, gameFunctions)

local GaiaShared = Mod:find({"Gaia", "Shared"})
GaiaShared.createBindables(ServerStorage, {
    events = events,
    functions = functions,
})

for _, name in ipairs(functions) do
    if not BindableFunctions:FindFirstChild(name) then
        local func = Instance.new("BindableFunction")
        func.Name = name
        func.Parent = BindableFunctions
    end
end

local module = {}

return module