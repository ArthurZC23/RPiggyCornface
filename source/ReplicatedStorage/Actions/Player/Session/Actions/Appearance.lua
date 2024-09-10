local actions = {}

function actions.setMorph(state, action)
    state.morph.id = action.value
    return state
end

function actions.setAge(state, action)
    state.age[action.bodyType] = action.value
    return state
end

function actions.setGender(state, action)
    state.gender[action.bodyType] = action.value
    return state
end

return actions