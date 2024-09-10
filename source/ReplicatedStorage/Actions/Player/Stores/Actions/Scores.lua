local actions = {}

function actions.set(state, action)
    local scoreType = action.scoreType
    local timeType = action.timeType
    state[scoreType][timeType] = action.value
    return state
end

function actions.increment(state, action)
    local scoreType = action.scoreType
    local timeType = action.timeType
    state[scoreType][timeType] = state[scoreType][timeType] + action.value
    return state
end

return actions