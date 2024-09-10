local actions = {}

function actions.AddRegions(state, action)
    --print("Add Regions")
    for region in pairs(action.regions) do
        --print("Added Region: ", region)
        state.regions[region] = true
    end
    action.flux = "in"
    return state
end

function actions.RemoveRegions(state, action)
    --print("Remove Regions")
    for region in pairs(action.regions) do
        --print("Removd Region: ", region)
        state.regions[region] = nil
    end
    action.flux = "out"
    return state
end

return actions