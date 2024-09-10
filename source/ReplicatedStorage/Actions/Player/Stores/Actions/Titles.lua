local actions = {}

function actions.addTitle(state, action)
    state.t[action.id] = state.t[action.id] or 0
    state.t[action.id] = state.t[action.id] + 1
    return state
end

function actions.removeTitle(state, action)
    state.t[action.id] = state.t[action.id] - 1
    return state
end

function actions.equipTitle(state, action)
    state.eq.t = action.id
    return state
end

function actions.unequipTitle(state, action)
    state.eq.t = nil
    return state
end

function actions.addImage(state, action)
    state.images[action.id] = state.images[action.id] or 0
    state.images[action.id] = state.images[action.id] + 1
    return state
end

function actions.removeImage(state, action)
    state.images[action.id] = state.images[action.id] - 1
    return state
end

function actions.equipImage(state, action)
    state.eq.image = action.id
    return state
end

function actions.unequipImage(state, action)
    state.eq.image = nil
    return state
end

return actions