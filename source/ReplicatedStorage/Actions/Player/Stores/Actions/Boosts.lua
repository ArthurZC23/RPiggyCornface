local actions = {}

function actions.addBoost(state, action)
    state.st[action.boostId] = {
        duration = action.duration,
        t0 = action.t0,
    }
    return state
end

function actions.removeBoost(state, action)
    state.st[action.boostId] = nil
    return state
end

return actions