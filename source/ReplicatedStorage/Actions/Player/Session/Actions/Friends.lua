local actions = {}

function actions.SetInGameFriendType(state, action)
    -- print("SetInGameFriendType ", action.player, typeof(action.player))
    state.playerType[action.userId] = action.friendType
    if action.friendType == "1" then
        state.friends[action.userId] = true
    end
    state.numFriends = 0
    for userId, friendType in pairs(state.playerType) do
       if friendType ~= "1" then continue end
       state.numFriends += 1
    end
    return state
end

function actions.RemoveInGameFriend(state, action)
    -- print("RemoveInGameFriend ", action.player, typeof(action.player))
    state.playerType[action.userId] = nil
    state.numFriends = 0
    state.friends[action.userId] = nil
    for userId, friendType in pairs(state.playerType) do
       if friendType ~= "1" then continue end
       state.numFriends += 1
    end

    return state
end

return actions