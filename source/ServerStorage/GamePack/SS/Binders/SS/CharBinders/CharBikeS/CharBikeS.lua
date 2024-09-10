local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

local CharBikeS = {}
CharBikeS.__index = CharBikeS
CharBikeS.className = "CharBike"
CharBikeS.TAG_NAME = CharBikeS.className

function CharBikeS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharBikeS)

    if not self:getFields() then return end
    self:handleBike()

    return self
end

function CharBikeS:handleBike()
    local function update(state)
        local maid = self._maid:Add2(Maid.new(), "Bike")
        local bikeId = state.eq
        local bikeData = Data.Bikes.Bikes.idData[bikeId]
        self.Bike = maid:Add2(bikeData.model:Clone())
        self:setBike(self.Bike)
        maid:Add2(self:setCFrame(self.Bike, bikeData))
        self.Bike.Name = "Bike"
        self.Bike.Parent = self.char
    end
    self._maid:Add2(self.playerState:getEvent(S.Stores, "Bikes", "eq"):Connect(update))
    local state = self.playerState:get(S.Stores, "Bikes")
    update(state)
end

local GaiaShared = Mod:find({"Gaia", "Shared"})

function CharBikeS:setBike(Bike)
    for _, desc in ipairs(Bike.Model:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.Anchored = false
        desc.Massless = true
        desc.CanTouch = false
        desc.CanCollide = false
        desc.CanQuery = false
        if not desc:GetAttribute("transpDefault") then
            desc:SetAttribute("transpDefault", 0)
        end
    end
    for _, desc in ipairs(Bike.Skeleton:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.Anchored = false
        desc.Massless = true
        desc.CanTouch = false
        desc.CanCollide = false
        desc.CanQuery = false
        if not desc:GetAttribute("transpDefault") then
            desc:SetAttribute("transpDefault", 1)
        end
    end
end

function CharBikeS:setCFrame(Bike, bikeData)
    local maid = Maid.new()

    local charParts = self.charParts

    local jointsData = bikeData.joints
    local yOffset = Vector3.new(0, 0.5 * charParts.hrp.Size.Y + charParts.humanoid.HipHeight, 0)

    local Handle = Bike.Skeleton.Handle

    Handle.Anchored = false
    local C1 = jointsData.item.C1
    if RunService:IsStudio() then
        C1 = script:GetAttribute("VehicleC1") or C1
    end
    C1 += yOffset
    local motor = maid:Add2(GaiaShared.create("Motor6D", {
        Part0 = self.charParts.lowerTorso,
        Part1 = Handle,
        C0 = CFrame.new(0, -0.6, 0),
        C1 = C1,
        Name = "ToolRoot",
        Parent = Handle,
    }))

    local offset = jointsData.char["R15"].offset
    maid:Add2(function()
        self.rootJoint.C1 = self.rootJoint.C1 - offset
    end)
    self.rootJoint.C1 = self.rootJoint.C1 + offset

    return maid
end

function CharBikeS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {},
        functions = {},
    }))
end

function CharBikeS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharBikeS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            self.rootJoint = ComposedKey.getFirstDescendant(self.char, {"LowerTorso", "Root"})
            if not self.rootJoint then return end

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

function CharBikeS:Destroy()
    self._maid:Destroy()
end

return CharBikeS