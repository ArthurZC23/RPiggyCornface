local actions = {}

function actions.set(state, action)
    local scoreType = action.scoreType
    state.scores[scoreType] = action.value

    return state
end

function actions.increment(state, action)
    local scoreType = action.scoreType
    state.scores[scoreType] = state.scores[scoreType] + action.value

    return state
end

function actions.decrement(state, action)
    local scoreType = action.scoreType
    state.scores[scoreType] = state.scores[scoreType] - action.value

    return state
end

function actions.reset(state, action)
    local scoreType = action.scoreType
    state.scores[scoreType] = 0

    return state
end

return actions