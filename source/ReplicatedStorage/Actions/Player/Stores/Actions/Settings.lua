local actions = {}

function actions.setMusic(state, action)
    state.Music = action.value
    return state
end

function actions.setFastMode(state, action)
    state.FastMode = action.value
    return state
end

return actions