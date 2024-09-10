local actions = {}

function actions.setExpsLock(state, action)
    state.lock = action.value
    return state
end

return actions