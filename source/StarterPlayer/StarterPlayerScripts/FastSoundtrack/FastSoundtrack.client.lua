local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Bach = require(ReplicatedStorage.Bach.Bach)

local soundtracks = workspace.Audio.Soundtracks.Default:GetChildren()
-- if RunService:IsStudio() then
--     return
-- end
-- Bach:play(
--     soundtracks[Random.new():NextInteger(1, #soundtracks)],
--     Bach.SoundTypes.Soundtrack,
--     {soundtrackType = "Default"}
-- )