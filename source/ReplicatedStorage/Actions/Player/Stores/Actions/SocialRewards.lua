local actions = {}

function actions.addCode(state, action)
    state.codes[action.code] = true
    return state
end

return actions