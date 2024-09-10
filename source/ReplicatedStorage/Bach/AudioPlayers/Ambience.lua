local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local CircularArray = Mod:find({"DataStructures", "Array", "Circular"})
local Maid = Mod:find({"Maid"})
local Mts = Mod:find({"Table", "Mts"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

local States = {
    ["Playing"]="Playing",
    ["Paused"]="Paused",
    ["Stopped"]="Stopped",
}

States = Mts.makeEnum("AmbienceAPStates", States)

Ap.ambiences = {
    -- Ambient 1=CircularArray(tracks)
    -- Ambient 2
}
Ap.lastAmbience = nil
Ap.state = States.Stopped

Ap._maid = Maid.new()

local function _loadAmbience()
    for playlistName, playlist in pairs(SharedSherlock:find({"Bach", "Playlists", "Ambience"})) do
        Ap.ambiences[playlistName] = CircularArray.new(playlist)
    end
end
_loadAmbience()

function Ap:getSound(soundReference, ambienceType)
    if not soundReference then
        local _, firstSoundtrack = Ap.soundtracks[ambienceType]:next()
        return firstSoundtrack
    elseif soundReference:IsA("Sound") then
        return soundReference
    elseif typeof(soundReference) == "string" then
        local soundName = soundReference
        if soundName then
            return Ap.soundtracks[ambienceType]:get(soundName)
        end
    else
        error(("Sound Reference %s has unsoportted type %s"):format(tostring(soundReference), typeof(soundReference)))
    end
end

function Ap:play(soundReference, kwargs)
    local sound = Ap:getSound(soundReference, kwargs.ambienceType)
    if sound ~= Ap.lastAmbience then
        if Ap.lastAmbience:IsA("Sound") then
            Ap.lastAmbience:Stop()
        end
        Ap.lastAmbience = sound
    end

    AudioPlayer.play(Ap, kwargs)

    Ap.state = States.Playing

    do
        local janitorKey = "SoundEnded"
        Ap._maid:Add(
            sound.Ended:Connect(function()
                local _, nextSound = Ap.soundtracks[Ap.ambienceType]:next()
                Ap:play(nextSound, kwargs)
            end),
            "Disconnect",
            janitorKey
        )
    end
end

function Ap:pause(soundReference, kwargs)
    Ap.lastAmbience:Pause()
    Ap.state = States.Paused
end

function Ap:resume(soundReference, kwargs)
    Ap.lastAmbience:Resume()
    Ap.state = States.Playing
end

function Ap:stop(soundReference, kwargs)
    Ap.lastAmbience:Stop()
    Ap.state = States.Stopped
end

function Ap:Destroy()

end

return Ap