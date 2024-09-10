local actions = {}

function actions.update(state, action)
    state.membership = action.value
    return state
end

return actions