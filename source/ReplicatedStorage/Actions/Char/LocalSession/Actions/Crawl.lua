local actions = {}

function actions.set(state, action)
    state.on = action.value
    return state
end

return actions