local actions = {}

function actions.setCameraView(state, action)
    state.previousView = state.view
    state.view = action.view
    return state
end

return actions