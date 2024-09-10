local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})

local module = {}

local actionsPerStateType = {
    LocalSession = ActionsLoader.load(ReplicatedStorage.Actions.Char.LocalSession.Actions),
    Session = ActionsLoader.load(ReplicatedStorage.Actions.Char.Session.Actions),
}

module.enum = {}
module.array = {}

for stateType in pairs(actionsPerStateType) do
    module.array[stateType] = {}
    module.enum[stateType] = {}
end

for stateType, values in pairs(actionsPerStateType) do
    for scope in pairs(values.actions) do
        module.enum[stateType][scope] = scope
        table.insert(module.array[stateType], scope)
    end
end

return module