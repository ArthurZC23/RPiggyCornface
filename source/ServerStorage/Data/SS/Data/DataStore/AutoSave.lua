local RunService = game:GetService("RunService")

local ONE_MINUTE = 60
if RunService:IsStudio() then
    --ONE_MINUTE = 60
end

local module = {}

module.interval = 1 * ONE_MINUTE

return module