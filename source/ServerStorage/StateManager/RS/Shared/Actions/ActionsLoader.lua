local module = {}

function module.load(root)
    if module[root] then return module[root] end
    local actions = {}
    local function loadActions(actionsModule)
        actions[actionsModule.Name] = require(actionsModule)
        for funcName, func in pairs(actions[actionsModule.Name]) do
            actions[actionsModule.Name][funcName] = func
        end
    end
    root.ChildAdded:Connect(loadActions)
    for _, actionsModule in ipairs(root:GetChildren()) do
        loadActions(actionsModule)
    end

    local actionsModule = {}

    function actionsModule.apply(scope, state, action)
        return actions[scope][action.name](state, action)
    end

    actionsModule.actions = actions

    module[root] = actionsModule

    return module[root]
end

return module