local actions = {}

function actions.fadeIn(state, action)
    state.fadeOut = nil
    state.fadeIn = action.data
    return state
end

function actions.fadeOut(state, action)
    state.fadeIn = nil
    state.fadeOut = action.data
    return state
end

return actions