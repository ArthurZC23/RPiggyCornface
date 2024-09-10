local CollectionService = game:GetService("CollectionService")

local module = {}

local RootFolder = script.Parent

for _, dataType in ipairs(RootFolder:GetChildren()) do
     if dataType:IsA("Folder") then
        if dataType.Name == "Loader" then continue end
        module[dataType.Name] = {}
        for _, dataSubType in ipairs(dataType:GetDescendants()) do
            if dataSubType:IsA("ModuleScript") then
                -- Guarantee that the collection is added before the check
                local dataModule = require(dataSubType)
                if CollectionService:HasTag(dataSubType, "DataUtils") then continue end
                module[dataType.Name][dataSubType.Name] = dataModule
            end
        end
    end
end

return module