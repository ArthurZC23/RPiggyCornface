local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local CircularArray = Mod:find({"DataStructures", "Array", "Circular"})
local Maid = Mod:find({"Maid"})
local Mts = Mod:find({"Table", "Mts"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local AudioPlayer = require(script.Parent.AudioPlayer)

local Ap = setmetatable({}, {__index = AudioPlayer})

local States = {
    ["Playing"]="Playing",
    ["Paused"]="Paused",
    ["Stopped"]="Stopped",
    ["SongFinished"]="SongFinished",
}

States = Mts.makeEnum("SoundtrackAPStates", States)

Ap.soundtracks = {

    -- Load screen
    -- Initial/Lobby/Intermission = CircularArray(track)
    -- MiniGame/Match = CircularArray(track)
}
Ap.lastSoundtrack = nil
Ap.state = States.Stopped

Ap._maid = Maid.new()

local function _loadSoundtracks()
    for playlistName, playlist in pairs(SharedSherlock:find({"Bach", "Playlists", "Soundtrack"})) do
        Ap.soundtracks[playlistName] = CircularArray.new(playlist)
    end
end
_loadSoundtracks()

function Ap:getSound(soundReference, soundtrackType)
    if not soundReference then
        local _, firstSoundtrack = Ap.soundtracks[soundtrackType]:next()
        return firstSoundtrack
    elseif soundReference:IsA("Sound") then
        return soundReference
    elseif typeof(soundReference) == "string" then
        local soundName = soundReference
        if soundName then
            return Ap.soundtracks[soundtrackType]:get(soundName)
        end
    else
        error(("Sound Reference %s has unsoportted type %s"):format(tostring(soundReference), typeof(soundReference)))
    end
end

function Ap:play(soundReference, kwargs)
    if
        Ap.state == States.Playing
        and Ap.soundtrackType == kwargs.soundtrackType
    then return end

    local sound = Ap:getSound(soundReference, kwargs.soundtrackType)
    Ap.soundtrackType = kwargs.soundtrackType
    if sound ~= Ap.lastSoundtrack then
        if Ap.lastSoundtrack then
            -- if kwargs.fadeOut then
            --     local tweenInfo = TweenInfo.new(kwargs.fadeOut.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
            --     local goal = {Volume = 0}
            --     local tween = TweenService:Create(sound, tweenInfo, goal)
            --     tween.Completed:Connect(function()
            --         Ap.lastSoundtrack:Stop()
            --     end)
            --     tween:Play()
            --     Ap._maid:Add2(function()
            --         tween:Cancel()
            --         tween:Destroy()
            --         sound.Volume = 0
            --     end, "FadeOutTween")
            -- else
            --     Ap.lastSoundtrack:Stop()
            -- end
            Ap.lastSoundtrack:Stop()
        end
        Ap.lastSoundtrack = sound
    end

    kwargs._maid = Ap._maid
    AudioPlayer:play(sound, kwargs)

    Ap.state = States.Playing

    do
        local janitorKey = "SoundEnded"
        Ap._maid:Add(
            sound.Ended:Connect(function()
                local ok, err = pcall(function()
                    local _, nextSoundtrack = Ap.soundtracks[Ap.soundtrackType]:next()
                    Ap.state = States.SongFinished
                    Ap:play(nextSoundtrack, kwargs)
                end)
                if not ok then
                    ErrorReport.report("Server", ("Bach error: %s\nSoundtrack: %s"):format(tostring(err), Ap.soundtrackType), "warning")
                end
            end),
            "Disconnect",
            janitorKey
        )
    end
    -- Need to fire an event to warn other audio players -- This will couple all audio players. Don't do this for now.
end

function Ap:pause(soundReference, kwargs)
    if not Ap.lastSoundtrack then return end
    Ap.lastSoundtrack:Pause()
    Ap.state = States.Paused
end

function Ap:resume(soundReference, kwargs)
    if not Ap.lastSoundtrack then return end
    Ap.lastSoundtrack:Resume()
    Ap.state = States.Playing
end

function Ap:stop(soundReference, kwargs)
    if not Ap.lastSoundtrack then return end
    -- if kwargs.fadeOut then
    --     local tweenInfo = TweenInfo.new(kwargs.fadeOut.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
    --     local goal = {Volume = 0}
    --     local tween = TweenService:Create(Ap.lastSoundtrack, tweenInfo, goal)
    --     tween:Play()
    --     Ap._maid :Add2(function()
    --         tween:Cancel()
    --         tween:Destroy()
    --         Ap.lastSoundtrack.Volume = 0
    --     end, "FadeOutTween")
    -- else
    --     Ap.lastSoundtrack:Stop()
    -- end
    Ap.lastSoundtrack:Stop()
    Ap.state = States.Stopped
end

function Ap:Destroy()

end

return Ap
