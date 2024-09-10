local actions = {}

function actions.setExperience(state, action)
    local data = action.data
    state.experience = {
        placeId = data.placeId,
    }
    return state
end

return actions