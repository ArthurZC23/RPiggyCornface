local module = {}

function module.setDataModuleMetatables(dataModule)
    local metatables = rawget(dataModule, "metatables")
    if not metatables then return end
    for tblName, metatable in pairs(metatables) do
        setmetatable(module[tblName], metatable)
    end
end

function module.setDataScopeMetatables(dataModule, tblName)
    setmetatable(dataModule[tblName], dataModule.metatables[tblName])
end

return module