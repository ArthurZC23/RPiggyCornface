local actions = {}

function actions.addKey(state, action)
    state.keySt[action.id] = true
    return state
end

function actions.removeKey(state, action)
    state.keySt[action.id] = nil
    return state
end

function actions.resetKeys(state, action)
    state.keySt = {}
    return state
end

return actions