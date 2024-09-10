local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

module.idData = {
    ["1"] = {
        name = "Axe",
        prettyName = "Axe",
        CameraAngles = Vector3.new(0, 0, 1.4),
        CameraPosition = Vector3.new(0, 4, 0),
        CameraPositionOffset = Vector3.new(0.4, 0, 0),
    },
    ["2"] = {
        name = "Hammer",
        prettyName = "Hammer",
        CameraAngles = Vector3.new(0, 0, -0.5),
        CameraPosition = Vector3.new(0, 3.5, 0),
        CameraPositionOffset = Vector3.new(0.3, 0, 0),
    },
    ["3"] = {
        name = "KeyYellow",
        prettyName = "Yellow Key",
        CameraAngles = Vector3.new(0, 0, 1.7),
        CameraPosition = Vector3.new(0, 3.5, 0),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
    -- ["4"] = {
    --     name = "Saw",
    --     prettyName = "Saw",
    --     CameraAngles = Vector3.new(0, 0, 0),
    --     CameraPosition = Vector3.new(0, 1.4, 0),
    --     CameraPositionOffset = Vector3.new(0, 0, 0),
    -- },
    ["5"] = {
        name = "Screwdriver",
        prettyName = "Screwdriver",
        CameraAngles = Vector3.new(0, 0, 1),
        CameraPosition = Vector3.new(0, 0, 1.5),
        CameraPositionOffset = Vector3.new(0, -0.1, 0),
    },
    ["6"] = {
        name = "ShapeBallBlue",
        prettyName = "Blue Ball",
        CameraAngles = Vector3.new(0, 0, 0),
        CameraPosition = Vector3.new(0, 2, 0),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
    ["7"] = {
        name = "ShapeCubeRed",
        prettyName = "Red Cube",
        CameraAngles = Vector3.new(0, 0, 0),
        CameraPosition = Vector3.new(1, 1, 1),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
    ["8"] = {
        name = "ShapeTrianglePink",
        prettyName = "Pink Triangle",
        CameraAngles = Vector3.new(0, 0, 0),
        CameraPosition = Vector3.new(0, 2, 0),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
    ["9"] = {
        name = "Shovel",
        prettyName = "Shovel",
        CameraAngles = Vector3.new(0, 0, 2.1),
        CameraPosition = Vector3.new(0, 3.5, 0),
        CameraPositionOffset = Vector3.new(-1, 0, 0),
    },
    ["10"] = {
        name = "WoodPlank",
        prettyName = "Wood Plank",
        CameraAngles = Vector3.new(0, 0, -1.7),
        CameraPosition = Vector3.new(0, 7, 0),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
    ["11"] = {
        name = "Scythe",
        prettyName = "Scythe",
        CameraAngles = Vector3.new(0, 0, 2.2),
        CameraPosition = Vector3.new(0, -5, 0),
        CameraPositionOffset = Vector3.new(-2, 0, 0),
    },
    ["12"] = {
        name = "KeyRed",
        prettyName = "Red Key",
        CameraAngles = Vector3.new(0, 0, 1.7),
        CameraPosition = Vector3.new(0, 3.5, 0),
        CameraPositionOffset = Vector3.new(0, 0, 0),
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.CameraAngles = data.CameraAngles or Vector3.new(0, 0, 0)
    data.CameraPosition = data.CameraPosition or Vector3.new(0, 1, 0)
    data.CameraPositionOffset = data.CameraPositionOffset or Vector3.new(0, 0, 0)

    data.tool = ReplicatedStorage.Assets.Puzzles.Keys.Tools[data.name]
    data.tool.CanBeDropped = false
    data.tool:SetAttribute("keyId", id)
    for _, desc in ipairs(data.tool.Model:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.Massless = true
        desc.CanCollide = false
        desc.Anchored = false
        if not desc:GetAttribute("transpDefault") then
            desc:SetAttribute("transpDefault", 0)
        end
    end

    data.keySpawnModel = ReplicatedStorage.Assets.Puzzles.Keys.KeySpawner[data.name]
    data.keySpawnModel:SetAttribute("keyId", id)
    data.keySpawnModel.PrimaryPart = data.keySpawnModel.Skeleton.SRef
    for _, desc in ipairs(data.keySpawnModel:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
        end
        if desc:IsA("WeldConstraint") then
            desc:Destroy()
        end
    end

    for _, desc in ipairs(data.keySpawnModel.Model:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        if not desc:GetAttribute("transpDefault") then
            desc:SetAttribute("transpDefault", 0)
        end
        desc.CanQuery = true
        desc.CanTouch = true
    end

    data.id = id
    module.nameData[data.name] = data
end

return module