local actions = {}

function actions.setNpcMonster(state, action)
    state._type = "npc"
    state.skinId = action.skinId or "1"
    state.playerId = nil
    state.t1 = nil

    return state
end

function actions.setPlayerMonster(state, action)
    state._type = "player"
    state.skinId = action.skinId
    state.playerId = action.playerId
    state.t1 = action.t1

    return state
end

return actions