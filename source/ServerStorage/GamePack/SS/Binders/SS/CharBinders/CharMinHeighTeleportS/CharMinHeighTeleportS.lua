local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharMinHeighTeleportS = {}
CharMinHeighTeleportS.__index = CharMinHeighTeleportS
CharMinHeighTeleportS.className = "CharMinHeighTeleport"
CharMinHeighTeleportS.TAG_NAME = CharMinHeighTeleportS.className

function CharMinHeighTeleportS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharMinHeighTeleportS)

    if not self:getFields() then return end
    self:handleMinHeightTeleport()

    return self
end

local BigBen = Mod:find({"Cronos", "BigBen"})
function CharMinHeighTeleportS:handleMinHeightTeleport()
    self._maid:Add(BigBen.every(0.2, "Heartbeat", "time_", false):Connect(function()
        local MIN_HEIGHT = -2
        if self.charParts.hrp.Position.Y > MIN_HEIGHT then return end
        local worldId = self.playerState:get(S.Session, "Worlds").current
        local World = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace, refName=("World%s"):format(worldId)})
        local MapTeleportTargets = SharedSherlock:find({"EzRef", "Get"}, {inst=World, refName=("MapTeleportTargets")})
        local CharTeleportSE = SharedSherlock:find({"Bindable", "async"}, {root = self.char, signal = "CharTeleport"})
        CharTeleportSE:Fire({
            Targets = MapTeleportTargets.Model:GetChildren()
        })
    end))
end


local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharMinHeighTeleportS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharParts", self.char},
                {"CharState", self.char},
                {"CharProps", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharMinHeighTeleportS:Destroy()
    self._maid:Destroy()
end

return CharMinHeighTeleportS