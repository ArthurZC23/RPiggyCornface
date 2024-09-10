local module = {}

module.singletons = {}

function module.addSingleton(id, sigleton)
    module.singletons[id] = sigleton
end

return module