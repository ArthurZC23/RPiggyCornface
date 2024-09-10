local actions = {}

function actions.viewTab(state, action)
    state.viewTab = action.tabName
    return state
end

function actions.reset(state, action)
    state.viewTab = nil
    return state
end

return actions