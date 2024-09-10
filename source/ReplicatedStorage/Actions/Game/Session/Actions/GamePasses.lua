local actions = {}

function actions.addGamePass(state, action)
    state[action.id] = action.data
    return state
end

return actions