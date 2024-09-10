local actions = {}

function actions.addTag(state, action)
    state[action.tag] = true
    return state
end

function actions.removeTag(state, action)
    state[action.tag] = nil
    return state
end

return actions