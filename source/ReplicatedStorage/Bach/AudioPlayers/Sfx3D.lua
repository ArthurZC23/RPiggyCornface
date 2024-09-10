local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

function Ap:play(soundReference, kwargs)
    local sound = soundReference
    AudioPlayer:play(sound, kwargs)
end

function Ap:Destroy()

end

return Ap