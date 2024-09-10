local actions = {}

function actions.addSpin(state, action)
    state.st[action.id].spins += action.value
    state.st[action.id].t1 = nil
    return state
end

function actions.useSpin(state, action)
    state.st[action.id].spins = math.max(state.st[action.id].spins - action.value, 0)
    state.st[action.id].totalSpinsBeforeT1 += action.value
    return state
end

function actions.startSpinTimer(state, action)
    state.st[action.id].t1 = action.t1
    return state
end

function actions.reset(state, action)
    state.st[action.id].spins = action.freeSpins
    state.st[action.id].totalSpinsBeforeT1 = 0
    state.st[action.id].t1 = nil
    return state
end

return actions