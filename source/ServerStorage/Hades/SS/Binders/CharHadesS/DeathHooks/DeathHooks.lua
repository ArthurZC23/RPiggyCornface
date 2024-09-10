local module = {}

for _, mod in ipairs(script.Parent:GetChildren()) do
    if mod == script then continue end
    if mod:IsA("ModuleScript") then
        module[mod.Name] = require(mod).handler
    end
end

return module