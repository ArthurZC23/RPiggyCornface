local PhysicsService = game:GetService("PhysicsService")

local module = {}

function module.setCollisionGroup(object, groupName)
    if object:IsA("BasePart") then
        object.CollisionGroup = groupName
    end
end

function module.setCollisionGroupRecursive(object, groupName)
    module.setCollisionGroup(object, groupName)
    for _, child in ipairs(object:GetChildren()) do
        module.setCollisionGroupRecursive(child, groupName)
    end
end

return module