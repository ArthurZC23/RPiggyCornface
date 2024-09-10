local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaShared = Mod:find({"Gaia", "Shared"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local LightningSparks = {}
LightningSparks.__index = LightningSparks
LightningSparks.className = "LightningSparks"
LightningSparks.TAG_NAME = LightningSparks.className

local partProto = GaiaShared.create("Part", {
    Anchored = true,
    CastShadow = false,
    CanCollide = false,
    CanTouch = false,
    Transparency = 1,
    Position = Vector3.new(1e10, 1e10, 1e10),
    Size = Vector3.new(1, 1, 1),
})

function LightningSparks.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, LightningSparks)

    return self
end

function LightningSparks:example(charParts)
    local Part1 = partProto:Clone()
    Part1.Name = "Part1"
    Part1.CFrame = charParts.hrp.CFrame

    local Part2 = partProto:Clone()
    Part2.CFrame = charParts.hrp.CFrame * CFrame.new(0, 0, -10)

    local attach1 = GaiaShared.create("Attachment", {
        Name = "Attachment1",
        Parent = Part1,
    })

    local attach2 = GaiaShared.create("Attachment", {
        Name = "Attachment2",
        Parent = Part2,
    })

    local NewBolt = LightningModule.new(Attachment1, Attachment2, 10)
end

function LightningSparks:Destroy()
    self._maid:Destroy()
end

return LightningSparks