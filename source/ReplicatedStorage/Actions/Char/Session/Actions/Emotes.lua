local actions = {}

function actions.startEmote(state, action)
    state.emotes[action.id] = action.value
    return state
end

function actions.stopEmote(state, action)
    state.emotes[action.id] = nil
    return state
end

return actions