local actions = {}

function actions.Increment(state, action)
    state.current = state.current + action.value
    return state
end

return actions