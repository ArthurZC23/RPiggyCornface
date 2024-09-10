local actions = {}

function actions.setInteraction(state, action)
    state.current[action.interId] = action.data
    return state
end

function actions.finish(state, action)
    state.current[action.interId] = nil
    return state
end

return actions