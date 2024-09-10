local actions = {}

function actions.setPlayerWithMostFriends(state, action)
    state.playerWithMostFriends.userId = action.userId
    state.playerWithMostFriends.numFriends = action.numFriends
    return state
end

return actions