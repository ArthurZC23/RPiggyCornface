local actions = {}

function actions.finishTutorial(state, action)
    state[tostring(action.tutorialId)] = {}
    return state
end

return actions