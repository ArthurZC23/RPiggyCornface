local casting = {}

function casting.toTableVector(robloxVector)
    local tableVector = {}
    tableVector.x = robloxVector.X
    tableVector.y = robloxVector.Y
    if typeof(robloxVector) == "Vector3" then
        tableVector.z = robloxVector.Z
    end
    return tableVector
end

function casting.toRobloxVector(tableVector)
    if tableVector.z then
        return Vector3.new(
            tableVector.x,
            tableVector.y,
            tableVector.z
        )
    else
        return Vector2.new(
            tableVector.x,
            tableVector.y
        )
    end
end

return casting