local module = {}

for _, mod in ipairs(script.Parent:GetChildren()) do
    if mod == script then continue end
    module[mod.Name] = require(mod)
end

return module