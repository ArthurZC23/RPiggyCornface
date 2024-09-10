local actions = {}

function actions.addUnlockHairCoin(state, action)
    state.UnlockHair = state.UnlockHair + action.value
    return state
end

function actions.removeUnlockHairCoin(state, action)
    state.UnlockHair = math.max(state.UnlockHair - action.value, 0)
    return state
end

return actions