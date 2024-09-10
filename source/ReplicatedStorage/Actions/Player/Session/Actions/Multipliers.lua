local actions = {}

function actions.updateMultiplier(state, action)
    state[action.multiplier] = action.value
    return state
end

return actions