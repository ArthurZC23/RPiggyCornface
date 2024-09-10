local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local module = {}

-- Default
for _, mod in ipairs(script:GetChildren()) do
    module[mod.Name] = require(mod)
end

-- Game Audio Players
for _, mod in ipairs(SharedSherlock:find({"Bach", "AudioPlayers"})) do
    if not module[mod.Name] then
        error(("Invalid sound type %s. You cannot attach an audio player for it"):format(mod.Name))
    end
    module[mod.Name] = require(mod)
end

-- Add sound group. This works because the modules are only loaded here.
local lazySoundGroupAttach = function(getSound, soundGroup)
    return function (...)
        local sound = getSound(...)
        sound.SoundGroup = soundGroup
        return sound
    end
end

for apName, ap in pairs(module) do
    local soundGroup = Instance.new("SoundGroup")
    soundGroup.Name = apName
    soundGroup.Parent = SoundService
    ap.soundGroup = soundGroup
    ap.getSound = lazySoundGroupAttach(ap.getSound, soundGroup)
end

return module