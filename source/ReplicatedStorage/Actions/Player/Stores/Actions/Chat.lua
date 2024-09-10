local actions = {}

function actions.addTag(state, action)
    state.tags[action.id] = state.tags[action.id] or {
        qty = 0,
        cTag = "ffffff",
        cName = "ffffff",
        cMsg = "ffffff",
    }
    state.tags[action.id].qty += 1
    return state
end

function actions.editTag(state, action)
    state.tags[action.id].cTag = action.data.cTag
    state.tags[action.id].cName = action.data.cName
    state.tags[action.id].cMsg = action.data.cMsg

    return state
end

function actions.setBubble(state, action)
    state.bubble = action.data
    return state
end

function actions.removeTag(state, action)
    action.qty = action.qty or 1
    state.tags[action.id].qty = state.tags[action.id].qty - action.qty
    if state.tags[action.id].qty == 0 then
        state.tags[action.id] = nil
    end
    return state
end

function actions.equipTag(state, action)
    state.eq.tag = action.id
    return state
end

function actions.mute(state, action)
    state.mute.t1 = action.t1
    return state
end

function actions.unmute(state, action)
    state.mute.t1 = -math.huge
    return state
end

return actions