local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local VectorsMath = Mod:find({"Math", "Vectors"})

local module = {}

module.getSurface = {
    front=function (part) return part.CFrame.LookVector end,
    back=function (part) return -part.CFrame.LookVector end,
    top=function (part) return part.CFrame.UpVector end,
    bottom=function (part) return -part.CFrame.UpVector end,
    right=function (part) return part.CFrame.RightVector end,
    left=function (part) return -part.CFrame.RightVector end,
}

function module.ToEulerAnglesXYZVector(cf)
    local x, y, z = cf:ToEulerAnglesXYZ()
    return Vector3.new(x, y, z)
end

function module.getPivotAfterSettingPosition(inst, pos)
    local cf = inst:GetPivot()
    return cf.Rotation + pos
end

function module.setPivotPositionWithRayGuarantee(inst, p1, raycastParams, offset)
    -- This is not for teleport, but for moving super fast
    offset = offset or 0
    local cf = inst:GetPivot()
    local p0 = cf.Position
    local delta = p1 - p0
    local dir = delta.Unit
    local raycastResult = workspace:Raycast(p0, p1 - p0, raycastParams)
    if raycastResult and raycastResult.Instance then
        local distance = raycastResult.Distance
        inst:PivotTo(cf + math.max(distance - offset, 0) * dir)
    else
        inst:PivotTo(cf + delta)
    end
end

function module.getInstPivotPositionWithRayGuarantee(inst, p1, raycastParams, offset)
    -- This is not for teleport, but for moving super fast
    offset = offset or 0
    local cf = inst:GetPivot()
    local p0 = cf.Position
    local delta = p1 - p0
    local dir = delta.Unit
    local raycastResult = workspace:Raycast(p0, p1 - p0, raycastParams)
    if raycastResult and raycastResult.Instance then
        local distance = raycastResult.Distance
        return p0 + math.max(distance - offset, 0) * dir
    else
        return p0 + delta
    end
end

function module.getPointPivotPositionWithRayGuarantee(p0, p1, raycastParams, offset)
    -- This is not for teleport, but for moving super fast
    offset = offset or 0
    local delta = p1 - p0
    local dir = delta.Unit
    local raycastResult = workspace:Raycast(p0, p1 - p0, raycastParams)
    if raycastResult and raycastResult.Instance then
        local distance = raycastResult.Distance
        return p0 + math.max(distance - offset, 0) * dir
    else
        return p0 + delta
    end
end

function module.setPivotPosition(inst, pos)
    local cf = inst:GetPivot()
    inst:PivotTo(cf - cf.Position + pos)
end

function module.reorientFront(part, newLookDirAxis)
    local size = part.Size
    if newLookDirAxis == "+X" then
        part.Size = Vector3.new(size.Z, size.Y, size.X)
        part.CFrame = part.CFrame * CFrame.Angles(0, -0.5 * math.pi, 0)
    elseif newLookDirAxis == "-X" then
        part.Size = Vector3.new(size.Z, size.Y, size.X)
        part.CFrame = part.CFrame * CFrame.Angles(0, 0.5 * math.pi, 0)
    elseif newLookDirAxis == "+Y" then
        part.Size = Vector3.new(size.X, size.Z, size.Y)
        part.CFrame = part.CFrame * CFrame.Angles(0.5 * math.pi, 0, 0)
    elseif newLookDirAxis == "-Y" then
        part.Size = Vector3.new(size.X, size.Z, size.Y)
        part.CFrame = part.CFrame * CFrame.Angles(-0.5 * math.pi, 0, 0)
    elseif newLookDirAxis == "-Z" then
        part.CFrame = part.CFrame * CFrame.Angles(0, math.pi, 0)
    else
        error(("Invalid newLookDirAxis %s"):format(newLookDirAxis))
    end
end

function module.getAxis(inst)
    local cf = inst:GetPivot()
    return cf.RightVector, cf.UpVector, cf.LookVector
end

function module.getAxisTable(inst)
    local cf = inst:GetPivot()
    return {X = cf.RightVector, Y = cf.UpVector, Z = cf.LookVector}
end

function module.positionOnWorldTop(inst, referencePart)
    local cf = inst:GetPivot()
    local yOffset
    if inst:IsA("Part") then
        yOffset = inst.Size.Y
    elseif inst:IsA("Model") then
        local bbCf, bbSize = inst:GetBoundingBox()
        yOffset = bbSize.Y
    end
    return
        cf - cf.Position + referencePart.Position +
        0.5 * (referencePart.Size.Y + yOffset) * Vector3.new(0, 1, 0)
end

function module.pivotOnWorldTop(inst, referencePart)
    local cf = inst:GetPivot()
    local yOffset
    if inst:IsA("Part") then
        yOffset = inst.Size.Y
    elseif inst:IsA("Model") then
        local bbCf, bbSize = inst:GetBoundingBox()
        yOffset = bbSize.Y
    end
    return
        referencePart.CFrame +
        0.5 * (referencePart.Size.Y + yOffset) * Vector3.new(0, 1, 0)
end

function module.getAxisFromDir(direction)
    if direction == "UpVector" then
        return "Y"
    elseif direction == "RightVector" then
        return "X"
    elseif direction == "LookVector" then
        return "Z"
    end
end

function module.pivotOnPart(inst, referencePart, normal)
    local sizeOffset
    if inst:IsA("Part") then
        sizeOffset = inst.CFrame:VectorToObjectSpace(normal):Dot(inst.Size)
    elseif inst:IsA("Model") then
        local _, bbSize = inst:GetBoundingBox()
        sizeOffset = inst.CFrame:VectorToObjectSpace(normal):Dot(bbSize)
    end
    return
        referencePart.CFrame +
        0.5 * (referencePart.CFrame:VectorToObjectSpace(normal):Dot(referencePart.Size) + sizeOffset) * normal
end

function module.pivotAround(inst, referencePart, percentage)
    percentage = percentage or 1
    local refSizeH = referencePart.Size * Vector3.new(
        (-0.5 + Random.new():NextNumber()) * percentage,
        0,
        (-0.5 + Random.new():NextNumber()) * percentage
    )
    return
        inst:GetPivot()
        + refSizeH
end

function module.copyAngles(targetCf, refCf)
    return targetCf * CFrame.Angles(targetCf:ToEulerAnglesXYZ()):Inverse() * CFrame.Angles(refCf:ToEulerAnglesXYZ())
end

function module.normalIdToCFrameVector(cf, direction)
    if direction == Enum.NormalId.Top then
        return cf.UpVector
    elseif direction == Enum.NormalId.Bottom then
        return -cf.UpVector
    elseif direction == Enum.NormalId.Back then
        return -cf.LookVector
    elseif direction == Enum.NormalId.Front then
        return cf.LookVector
    elseif direction == Enum.NormalId.Right then
        return cf.RightVector
    elseif direction == Enum.NormalId.Left then
        return -cf.RightVector
    else
        error(("Invalid direction %s"):format(tostring(direction)))
    end
end

function module.getDirectionData(part, dir)
    local eps = 1e-2
    local threshold = 1 - eps

    local pz = dir:Dot(part.CFrame.LookVector)
    if pz > threshold then
        return part.CFrame.LookVector, "LookVector", "Z"
    elseif pz < -threshold then
        return -part.CFrame.LookVector, "LookVector", "Z"
    end

    local px = dir:Dot(part.CFrame.RightVector)
    if px > threshold then
        return -part.CFrame.RightVector, "RightVector", "X"
    elseif px < -threshold then
        return part.CFrame.RightVector, "RightVector", "X"
    end

    local py = dir:Dot(part.CFrame.UpVector)
    if py > threshold then
        return -part.CFrame.UpVector, "UpVector", "Y"
    elseif py < -threshold then
        return part.CFrame.UpVector, "UpVector", "Y"
    end
end

function module.getOrthogonalVectors(dir)
    if VectorsMath.areCollinear(dir, Vector3.yAxis) then
        return Vector3.xAxis, Vector3.zAxis
    end
    local cf = CFrame.lookAt(Vector3.new(0, 0, 0), dir)
    return cf.RightVector, cf.UpVector
end

function module.vectorRotation(v, u, theta)
    if VectorsMath.areCollinear(v, u) then
        warn("Vectors are collinear.")
        return v
    end
    local w = v:Cross(u)
    return CFrame.fromAxisAngle(w, theta):VectorToWorldSpace(v)
end

do
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.IgnoreWater = true

    function module.projectPointIntoPart(point, part)
        raycastParams.FilterDescendantsInstances = {part}
        local ray = workspace:Raycast(point, part.Position - point, raycastParams)
        if not ray then
            warn(("ray didn't hit %s"):format(part:GetFullName()))
            return
        end
        local normal = ray.Normal
        local _, _, axis = module.getDirectionData(part, normal)
        point = (point - point:Dot(normal) * normal)
            + (part.Position:Dot(normal)
            + 0.5 * (part.Size)[axis]) * normal
        return true
    end

    function module.projectPartIntoPart(p0, partToProject, part)
        raycastParams.FilterDescendantsInstances = {part}
        local ray = workspace:Raycast(p0, part.Position - p0, raycastParams)
        if not ray then
            warn(("ray didn't hit %s"):format(part:GetFullName()))
            return
        end
        local normal = ray.Normal
        local _, _, axis = module.getDirectionData(part, normal)
        module.setPivotPosition(
            partToProject,
            (p0 - p0:Dot(normal) * normal)
            + (part.Position:Dot(normal)
            + 0.5 * (partToProject.Size + part.Size)[axis]) * normal
        )
        return true
    end
end

return module