local rootFolder  = script.Parent
local cast = require(rootFolder.Casting)

local abs = math.abs
local max = math.max

local norms = {}

function norms.normP(vec, p)
    local tableVec = cast.toTableVector(vec)
    local result = 0
    for _, xi in pairs(tableVec) do
        result = result + abs(xi) ^ p
    end
    result = result ^ (1/p)
    return result
end

function norms.normInf(vec)
    local tableVec = cast.toTableVector(vec)
    local result = 0
    for _, component in pairs(tableVec) do
        result = max(result, component)
    end
    return result
end

return norms