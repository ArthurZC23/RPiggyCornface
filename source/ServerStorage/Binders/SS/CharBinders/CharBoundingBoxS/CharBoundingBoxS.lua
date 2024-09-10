local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local CharBoundingBoxS = {}
CharBoundingBoxS.__index = CharBoundingBoxS
CharBoundingBoxS.className = "CharBoundingBox"
CharBoundingBoxS.TAG_NAME = CharBoundingBoxS.className

function CharBoundingBoxS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharBoundingBoxS)

    if not self:getFields() then return end
    self.boxesModel = GaiaShared.create("Model", {
        Name = "Boxes",
        Parent = self.char,
    })
    self:createBoundingBox()
    self:createDirectionBoundingBox()
    self:updateBoundingBox()

    return self
end

function CharBoundingBoxS:updateBoundingBox()
    self._maid:Add(BigBen.every(1, "Heartbeat", "time_", true):Connect(function()
        local rawChar = self:getRawCharClone()
        local cf, size = rawChar:GetBoundingBox()
        size = size * Vector3.new(1, 1, 0) + self.hrp.Size * Vector3.new(0, 0 , 1)
        self.box.Position = cf.Position
        self.box.Size = size

        task.defer(function()
            rawChar:Destroy()
        end)
    end))
end

function CharBoundingBoxS:createDirectionBoundingBox()
    self.directionBox = self._maid:Add(GaiaShared.create("Part", {
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        CanTouch = false,
        Size = self.hrp.Size,
        CFrame = self.hrp.CFrame,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.SmoothPlastic,
        Transparency = 1,
        Massless = true,
        Name = ("DirectionBoundingBox%s"):format(self.char:GetAttribute("uid")),
        Parent = self.boxesModel,
    }))
    self.directionBox:SetAttribute("transpDefault", 1)
end

function CharBoundingBoxS:createBoundingBox()
    self.box = self._maid:Add(GaiaShared.create("Part", {
        CanCollide = false,
        CanQuery = false,
        CanTouch = false,
        Size = self.hrp.Size,
        CFrame = self.hrp.CFrame,
        Color = Color3.fromRGB(255, 255, 255),
        Material = Enum.Material.SmoothPlastic,
        Transparency = 1,
        Massless = true,
        Name = ("BoundingBox%s"):format(self.char:GetAttribute("uid")),
        Parent = self.boxesModel,
    }))
    self.box:SetAttribute("transpDefault", 1)
    GaiaShared.create("WeldConstraint", {
        Part0 = self.box,
        Part1 = self.hrp,
        Parent = self.box,
    })
end

function CharBoundingBoxS:getRawCharClone()
    self.char.Archivable = true
    local rawChar = self.char:Clone()
    self.char.Archivable = false
    for _, child in ipairs(rawChar:GetChildren()) do
        if not child:GetAttribute("charLimb") then child:Destroy() end
    end

    return rawChar
end

function CharBoundingBoxS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            if not self.char:GetAttribute("uid") then return end
            self.hrp = self.char:FindFirstChild("HumanoidRootPart")
            if not self.hrp then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharBoundingBoxS:Destroy()
    self._maid:Destroy()
end

return CharBoundingBoxS