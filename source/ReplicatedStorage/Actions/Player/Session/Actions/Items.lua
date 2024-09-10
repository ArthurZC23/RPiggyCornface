local actions = {}

function actions.add(state, action)
    state.st[action.id] = {}
    return state
end

function actions.remove(state, action)
    state.st[action.id] = nil
    return state
end


return actions