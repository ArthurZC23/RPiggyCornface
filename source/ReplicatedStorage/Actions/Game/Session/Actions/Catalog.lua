local actions = {}

function actions.setCatalog(state, action)
    state.catalog = action.catalog
    return state
end

return actions