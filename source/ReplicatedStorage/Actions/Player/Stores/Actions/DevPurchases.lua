local actions = {}

function actions.setPurchaseCache(state, action)
    state.cache[action.id] = action.data
    return state
end

function actions.removeCache(state, action)
    state.cache[action.id] = nil
    return state
end

function actions.updateRecordIdx(state, action)
    state.newestIdx = state.newestIdx + 1
    return state
end

return actions