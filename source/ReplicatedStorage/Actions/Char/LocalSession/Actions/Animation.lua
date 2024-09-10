local actions = {}

function actions.playIdleAnimation(state, action)
    state.trackIdle = action.value
    return state
end

function actions.stopIdleAnimation(state, action)
    action.trackIdle = state.trackIdle
    state.trackIdle = {}
    return state
end


function actions.playAction1Animation(state, action)
    state.trackAction1 = action.value
    return state
end

function actions.stopAction1Animation(state, action)
    action.trackAction1 = state.trackAction1
    state.trackAction1 = {}
    return state
end

function actions.playAction2Animation(state, action)
    state.trackAction2 = action.value
    return state
end

function actions.stopAction2Animation(state, action)
    action.trackAction2 = state.trackAction2
    state.trackAction2 = {}
    return state
end

return actions