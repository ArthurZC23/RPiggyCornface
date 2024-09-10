local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

function Ap:play(soundReference, kwargs)
    local sound = soundReference
    AudioPlayer:play(sound, kwargs)
end

function Ap:pause(soundReference, kwargs)
    Ap.lastSoundtrack:Pause()
end

function Ap:resume(soundReference, kwargs)
    Ap.lastSoundtrack:Resume()
end

function Ap:stop(soundReference, kwargs)
    Ap.lastSoundtrack:Stop()
end



function Ap:Destroy()

end

return Ap