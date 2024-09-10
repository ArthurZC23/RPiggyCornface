local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

function Ap:getSound(soundName)
    return workspace.Audio.Sfx[soundName]
end

function Ap:play(soundReference, kwargs)
    local soundName = soundReference
    local sound = Ap:getSound(soundName)
    AudioPlayer:play(sound, kwargs)
end

function Ap:stop(soundReference, kwargs)
    local soundName = soundReference
    local sound = Ap:getSound(soundName)
    AudioPlayer:stop(sound, kwargs)
end

function Ap:Destroy()

end

return Ap