local module = {}

function module.getAnimationWeightId(track, codes)
    assert(next(codes) ~= nil, "Codes cannot be nil.")
    local w1 = 10 * track.WeightTarget
    local frac = (w1 - math.floor(w1)) / 10
    local bestId
    local diff = math.huge
    for id, data in pairs(codes) do
        local _diff = math.abs(frac - data.weight)
        if _diff < diff then
            bestId = id
            diff = _diff
        end
    end
    return bestId
end

return module