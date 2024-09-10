local actions = {}

function actions.equip(state, action)
    state.eq = action.id
    return state
end

function actions.unequip(state, action)
    action.id = state.eq
    state.eq = nil
    return state
end

function actions.add(state, action)
    state.st[action.id] = true
    return state
end

return actions