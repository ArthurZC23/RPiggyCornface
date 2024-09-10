local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

function Ap:play(soundReference, kwargs)

end

function Ap:pause(soundReference, kwargs)

end

function Ap:resume(soundReference, kwargs)

end

function Ap:stop(soundReference, kwargs)

end

function Ap:Destroy()

end

return Ap