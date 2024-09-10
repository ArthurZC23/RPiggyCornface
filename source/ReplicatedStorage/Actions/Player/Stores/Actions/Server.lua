local actions = {}

function actions.setLock(state, action)
    state.lockId = action.lockId
    return state
end

function actions.resetLock(state, action)
    state.lockId = nil
    state.lockTimeout = nil
    return state
end

function actions.UpdatePlaceVersion(state, action)
    state.placeVersion.previous = state.placeVersion.current
    state.placeVersion.current = game.PlaceVersion
    return state
end

return actions