local actions = {}

function actions.setHide(state, action)
    state.on = action.value
    return state
end

return actions