local actions = {}

function actions.addDb(state, action)
    state[action.dbName] = true
    return state
end

function actions.removeDb(state, action)
    state[action.dbName] = nil
    return state
end

return actions