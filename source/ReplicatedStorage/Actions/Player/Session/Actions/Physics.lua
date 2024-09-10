local actions = {}

function actions.setAnchored(state, action)
    state.anchored = action.value
    return state
end

return actions