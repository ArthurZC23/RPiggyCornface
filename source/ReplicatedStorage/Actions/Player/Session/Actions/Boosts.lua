local actions = {}

function actions.enableBoost(state, action)
    state[action.boostId] = true
    return state
end

function actions.disableBoost(state, action)
    state[action.boostId] = false
    return state
end

return actions