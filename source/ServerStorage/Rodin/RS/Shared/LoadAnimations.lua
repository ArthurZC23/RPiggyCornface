local module = {}

function module.loadTracks(animationsData, animator)
    local tracks = {}
    for animName, animData in pairs(animationsData) do
        tracks[animName] = animator:LoadAnimation(animData.anim)
    end
    return tracks
end

return module