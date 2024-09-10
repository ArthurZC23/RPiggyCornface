local actions = {}

function actions.ban(state, action)
    state = action.data
    return state
end

return actions