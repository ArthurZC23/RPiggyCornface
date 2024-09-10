local actions = {}

function actions.setAdsAllowed(state, action)
    state.ads = action.value
    return state
end

function actions.setPoliceService(state, action)
    state.current = action.value
    return state
end

return actions