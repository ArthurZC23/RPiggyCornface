local actions = {}

function actions.addBadge(state, action)
    --No, set must use string, not non consecutive numbers.
    -- Numeric table with gaps cannot be serialized!
    state[tostring(action.id)] = true
    return state
end

function actions.addBadgeInverse(state, action)
    state[tostring(action.id)] = nil
    return state
end

return actions