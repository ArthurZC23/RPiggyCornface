local TweenService = game:GetService("TweenService")

local Shared = script:FindFirstAncestor("Shared")
local CFrameUtils = require(Shared:WaitForChild("CFrameUtils"))

local module = {}

local function computePos(part, directions, sizeStep, pos)
    local axisTable = CFrameUtils.getAxisTable(part)
    for axis, vector in pairs(axisTable) do
        local dir = directions[axis] * vector
        pos = pos + 0.5 * sizeStep[axis] * dir
    end
    return pos
end

local function validateDirections(directions)
    for _, axis in ipairs({"X", "Y", "Z"}) do
        assert((directions[axis] == 1) or (directions[axis] == -1) or (directions[axis] == 0), ("Invalid %s direction"):format(axis))
    end
end

function module.getSizeStepInDirection(part, sizeStep, directions)
    validateDirections(directions)
    local pos, size = part.Position, part.Size
    local newSize = size + sizeStep
    pos = computePos(part, directions, sizeStep, pos)
    size = newSize
    return pos, size
end

function module.getSizeSetInDirection(part, newSize, directions)
    validateDirections(directions)
    local pos, size = part.Position, part.Size
    local sizeStep = newSize - size
    pos = computePos(part, directions, sizeStep, pos)
    size = newSize
    return pos, size
end

function module.getSizeScaleInDirection(part, scale, directions)
    validateDirections(directions)
    local pos, size = part.Position, part.Size
    local newSize = size * scale
    local sizeStep = newSize - size
    pos = computePos(part, directions, sizeStep, pos)
    size = newSize
    return pos, size
end

function module.setSizeStepInDirection(part, sizeStep, directions)
    part.Position, part.Size = module.getSizeStepInDirection(part, sizeStep, directions, part.Position, part.Size)
end

function module.setSizeSetInDirection(part, newSize, directions)
    part.Position, part.Size = module.getSizeSetInDirection(part, newSize, directions, part.Position, part.Size)
end

function module.setSizeScaleInDirection(part, scale, directions)
    part.Position, part.Size = module.getSizeScaleInDirection(part, scale, directions, part.Position, part.Size)
end

return module