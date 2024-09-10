local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local RootF = script.Parent
local BinderConfig = require(RootF:WaitForChild("BinderConfig"))

local TeleporterInGameC = {}
TeleporterInGameC.__index = TeleporterInGameC
TeleporterInGameC.className = "TeleporterInGame"
TeleporterInGameC.TAG_NAME = TeleporterInGameC.className
TeleporterInGameC.binderConfig = BinderConfig

function TeleporterInGameC.new(teleporter)
    assert(teleporter:GetAttribute("TeleportId"), "TeleporterInGameC requires TeleportId.")
    local self = {
        teleporter = teleporter,
        _maid = Maid.new(),
    }
    setmetatable(self, TeleporterInGameC)

    return self
end

function TeleporterInGameC:Destroy()
    self._maid:Destroy()
end

return TeleporterInGameC