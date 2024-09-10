local RootF = script.Parent

local AudioPlayers = require(RootF.AudioPlayers)
local SoundTypes = require(RootF.SoundTypes)

local Bach = {}
Bach.__index = Bach

-- This should have all possible sound types.
-- All games should have the same sound types and a default audio player for it.

Bach.SoundTypes = SoundTypes.soundTypes

local function _loadAudioPlayers(bach)
    bach.audioPlayers = {}

    for sType, _ in pairs(SoundTypes.soundTypes) do
        bach.audioPlayers[sType] = AudioPlayers[sType]
    end
end
_loadAudioPlayers(Bach)

function Bach:play(soundReference, soundType, kwargs)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer:play(soundReference, kwargs)
end

-- Let client code deal with event callbacks, yield while playing and etc. Bach only play music.
function Bach:getSound(soundReference, soundType)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    return audioPlayer:getSound(soundReference)
end

function Bach:pause(soundReference, soundType, kwargs)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer:pause(soundReference, kwargs)
end

function Bach:resume(soundReference, soundType, kwargs)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer:resume(soundReference, kwargs)
end

function Bach:stop(soundReference, soundType, kwargs)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer:stop(soundReference, kwargs)
end

function Bach:mute(soundType)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer.soundGroup.Volume = 0
end

function Bach:unmute(soundType)
    local audioPlayer = Bach.audioPlayers[SoundTypes.soundTypes[soundType]]
    audioPlayer.soundGroup.Volume = 1
end

function Bach:Destroy()

end

return Bach