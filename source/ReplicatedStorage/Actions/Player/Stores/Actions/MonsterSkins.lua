local actions = {}

function actions.eq(state, action)
    state.eq = action.id
    return state
end

function actions.add(state, action)
    state.st[action.id] = {}
    return state
end

return actions