local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local RootF = script:FindFirstAncestor("CharTeleportInGameC")
local CharTeleportHandlers = RootF:WaitForChild("CharTeleportHandlers")

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local CharTeleportInGameC = {}
CharTeleportInGameC.__index = CharTeleportInGameC
CharTeleportInGameC.className = "CharTeleportInGame"
CharTeleportInGameC.TAG_NAME = CharTeleportInGameC.className

function CharTeleportInGameC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharTeleportInGameC)
    if not self:getFields() then return end

    self.teleportHandler = Debounce.standard(self.teleportHandler)
    self:handleTeleport(char)

    return self
end

function CharTeleportInGameC:handleTeleport()
    local function carryServerUpdate(_, action)
        action.serverCall = true
        playerState:set("LocalSession", "Teleport", action)
    end

    self._maid:Add(playerState:getEvent("LocalSession", "Teleport", "teleport"):Connect(function(_, action)
        self:teleportHandler(action.kwargs)
    end))

    self._maid:Add(playerState:getEvent("Session", "Teleport", "teleport"):Connect(function(_, action)
        carryServerUpdate(_, action)
    end))
end

function CharTeleportInGameC:teleportHandler(kwargs)
    local handler = {}
    if kwargs.handler then
        handler.beforeTeleport = CharTeleportHandlers[kwargs.handler].beforeTeleport
        handler.afterTeleport = CharTeleportHandlers[kwargs.handler].afterTeleport
    end

    if handler.beforeTeleport then
        handler.beforeTeleport(self, kwargs)
    end

    -- Should not make vehicle check. Char should have a state that decices if can teleport or not. If not just print the state message
    -- self:checkIfInVehicle()
    self:unseatPlayer()
    self:teleport(kwargs)

    if handler.afterTeleport then
        handler.afterTeleport(self, kwargs)
    end
end

function CharTeleportInGameC:unseatPlayer()
    local humanoid = self.charParts.humanoid
    if humanoid.SeatPart then
        local seatPart = humanoid.SeatPart
        local originalSeatCFrame = seatPart.CFrame
        task.delay(1, function()
            seatPart.CFrame = originalSeatCFrame
        end)
        -- Do a futile attempt to unseat the player
        humanoid.SeatPart:Sit(nil)
        humanoid.Sit = false
        humanoid:GetPropertyChangedSignal("SeatPart"):Wait()
    end
end

function CharTeleportInGameC:teleport(kwargs)
    self.char:PivotTo(kwargs.cf)
    return true
end

function CharTeleportInGameC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharState", self.char},
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharTeleportInGameC:Destroy()
    self._maid:Destroy()
end

return CharTeleportInGameC