local actions = {}

function actions.setPlotSelection(state, action)
    state.plotSelection = action.value
    return state
end

return actions