local actions = {}

function actions.SetFirstJoinTime(state, action)
    state.t00 = action.joinTime
    return state
end

function actions.SetJoinTime(state, action)
    state.t1 = state.t0
    state.t0 = action.joinTime
    return state
end

return actions