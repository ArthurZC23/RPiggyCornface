local module = {}

for _, mod in ipairs(script:GetChildren()) do
	module[mod.Name] = require(mod)
end

return module