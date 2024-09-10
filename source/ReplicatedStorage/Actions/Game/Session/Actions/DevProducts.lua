local actions = {}

function actions.addDevProduct(state, action)
    state[action.id] = action.data
    return state
end

return actions