local actions = {}

function actions.setDevGroupData(state, action)
    state.groupData = action.groupData
    return state
end

return actions