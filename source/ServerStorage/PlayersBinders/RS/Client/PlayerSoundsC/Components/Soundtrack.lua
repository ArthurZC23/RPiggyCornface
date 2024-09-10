local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Bach = Mod:find({"Bach", "Bach"})

local Soundtrack = {}
Soundtrack.__index = Soundtrack
Soundtrack.className = "Soundtrack"
Soundtrack.TAG_NAME = Soundtrack.className

function Soundtrack.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Soundtrack)

    -- Soundtrack needs to start as soon as possible.
    -- For that to happen, bach should be already in their correct places.
    -- I need this to manage the switch of soundtracks here. E.g. char changing places also change soundtrack.

    -- DEPRECATED
    -- local soundtracks = workspace.Audio.Soundtracks.Default:GetChildren()
    -- Bach:play(
    --     soundtracks[Random.new():NextInteger(1, #soundtracks)],
    --     Bach.SoundTypes.Soundtrack,
    --     {soundtrackType = "Default"}
    -- )

    return self
end

function Soundtrack:Destroy()
    self._maid:Destroy()
end

return Soundtrack