local actions = {}

function actions.addDevProduct(state, action)
    state.totalDevP += action.devProductPrice
    state.total += action.devProductPrice
    return state
end

function actions.addGp(state, action)
    state.totalGp += action.gpPrice
    state.total += action.gpPrice
    return state
end

return actions