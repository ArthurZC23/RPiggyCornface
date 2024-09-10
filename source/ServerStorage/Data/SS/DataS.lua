local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local module = {}

local DataModules = script.Parent.Data

local function getPathFromDataScopeToModule(folder, mod)
    local pathInst = {mod}
    local pathName = {mod.Name}
    while pathInst[1] ~= folder do
        --print("1: ", pathInst[1], pathInst[1].Parent)
        table.insert(pathInst, 1, pathInst[1].Parent)
        --print("2: ", pathInst[1])
        table.insert(pathName, 1, pathInst[1].Name)
    end
    return pathName
end

module.metatables = {}

-- local t0 = os.time()
-- local t1 = t0
for _, folder in ipairs(DataModules:GetChildren()) do
    if folder:IsA("Folder") then
        if folder.Name == "Loader" then continue end
        module[folder.Name] = {}
        for _, mod in ipairs(folder:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                -- Guarantee that the collection is added before the check
                -- print("Loading: ", mod:GetFullName())
                local dataModule = require(mod)
                if CollectionService:HasTag(mod, "DataUtils") then continue end
                local pathName = getPathFromDataScopeToModule(folder, mod)
                ComposedKey.set(module, pathName, dataModule)

                ------------------
                -- Cannot replicate functions
                -- if rawget(dataModule, "metatables") then
                --     table.insert(module.metatables, {pathName})
                --     dataModule.metatables = nil
                -- end
                ------------------

                --module[dataType.Name][mod.Name] = dataModule

                -- t0 = t1
                -- t1 = os.time()
                -- print("Loaded: ", mod:GetFullName(), t1 - t0)
            end
        end
    end
end

return module