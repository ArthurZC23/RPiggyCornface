local actions = {}

function actions.addCriticalTimestamp(state, action)
    state.cts[action.id] = true
    return state
end

return actions