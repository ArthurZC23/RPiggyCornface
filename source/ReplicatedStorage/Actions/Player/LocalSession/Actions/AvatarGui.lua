local actions = {}

function actions.viewTab(state, action)
    state.viewTab = action.tabName
    return state
end

function actions.setTab(state, action)
    state.tabs[action.tabName] = action.value
    return state
end

function actions.reset(state, action)
    state.viewTab = nil
    state.tabs = {}
    return state
end

function actions.addToAssetCache(state, action)
    state.assetsCache[action.assetId] = action.value
    return state
end

return actions