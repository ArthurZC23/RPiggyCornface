local module = {}

function module.getRandom3dUnitVector()
    return Random.new():NextUnitVector()
end

function module.getRandom3dUnitVectorWithPositiveComponents()
    return Vector3.new(
        Random.new():NextNumber(),
        Random.new():NextNumber(),
        Random.new():NextNumber()
    ).Unit
end

function module.areCollinear(v1, v2, eps)
    eps = eps or 1e-2
    return v1.Unit:Dot(v2.Unit) >= 1 - eps
end

function module.projectOnPlane(p0, plP, plN)
    return p0 + (plP - p0):Dot(plN) * plN
end

function module.projectOnBasePart(p0, part, plN)
    local offset = 0.5 * (part.Size * module.vectorAbs(part.CFrame:VectorToObjectSpace(plN))) * plN
    return module.projectOnPlane(p0, part.Position + offset, plN)
end

function module.vectorAbs(v)
    return Vector3.new(
        math.abs(v.X),
        math.abs(v.Y),
        math.abs(v.Z)
    )
end

return module