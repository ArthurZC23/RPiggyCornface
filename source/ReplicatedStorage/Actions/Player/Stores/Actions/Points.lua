local actions = {}

function actions.Increment(state, action)
    state.current = state.current + action.value
    return state
end

function actions.Decrement(state, action)
    state.current = state.current - action.value
    return state
end

function actions.IncrementRate(state, action)
    state.rate = state.rate + action.value
    return state
end

function actions.SetRate(state, action)
    state.rate = action.value
    return state
end

return actions