local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

local actions = {}

function actions.add(state, action)
    state.st[action.id] = true
    state.total = TableUtils.len(state.st)
    return state
end

function actions.remove(state, action)
    state.st[action.id] = nil
    state.total = TableUtils.len(state.st)
    return state
end

function actions.reset(state, action)
    state.st = {}
    state.total = 0
    return state
end

return actions