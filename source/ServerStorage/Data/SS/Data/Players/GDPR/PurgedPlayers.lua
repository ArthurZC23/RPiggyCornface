local RunService = game:GetService("RunService")

local module = {}

module.purgedPlayers = {}

module.purge = {
    
}

if RunService:IsStudio() then
    --table.insert(module.purge, 925418276)
end

return module