local actions = {}

function actions.openChest(state, action)
    state[tostring(action.id)] = action.t1
    return state
end

function actions.resetChest(state, action)
    state[tostring(action.id)] = nil
    return state
end

return actions