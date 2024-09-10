local actions = {}

function actions.add(state, action)
    state.cur = state.cur + action.value
    return state
end

function actions.remove(state, action)
    state.cur = state.cur - action.value
    return state
end

function actions.setPreviousLifeCache(state, action)
    state.previousLifeCache = action.value
    return state
end

function actions.setSyncCacheFlag(state, action)
    state.shouldSyncCache = action.value
    return state
end

return actions