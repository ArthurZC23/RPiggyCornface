local actions = {}

function actions.request(state, action)
    return state
end

function actions.setPurchaseState(state, action)
    state.onPurchase = action.value
    return state
end

return actions