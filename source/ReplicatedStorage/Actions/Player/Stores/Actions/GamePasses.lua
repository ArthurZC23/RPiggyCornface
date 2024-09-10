local actions = {}

function actions.addGamePass(state, action)
    state.st[tostring(action.id)] = {}
    return state
end

function actions.removeGamePass(state, action)
    state.st[tostring(action.id)] = nil
    return state
end

function actions.updateGamePassRewards(state, action)
    state.st[tostring(action.id)].r = state.st[tostring(action.id)].r or {}
    state.st[tostring(action.id)].r[action.rewardId] = true
    return state
end

function actions.enableGamepass(state, action)
    state.st[tostring(action.id)]._d = nil
    return state
end

function actions.disableGamepass(state, action)
    state.st[tostring(action.id)]._d = true
    return state
end

return actions