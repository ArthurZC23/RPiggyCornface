local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function setAttributes()

end
setAttributes()

local IceAgeSkinC = {}
IceAgeSkinC.__index = IceAgeSkinC
IceAgeSkinC.className = "IceAgeSkin"
IceAgeSkinC.TAG_NAME = IceAgeSkinC.className
IceAgeSkinC.bagArray = {}

function IceAgeSkinC.new(char)
    if not char:IsDescendantOf(workspace) then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, IceAgeSkinC)

    if not self:getFields() then return end
    self:runRainbow()

    return self
end

local TweenService = game:GetService("TweenService")
local Promise = Mod:find({"Promise", "Promise"})
local TweenGroup = Mod:find({"Tween", "TweenGroup"})
function IceAgeSkinC:runRainbow()
    local colors = {
        [1] = Color3.fromRGB(119, 152, 171),
        [2] = Color3.fromRGB(125, 161, 180),
    }
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

    self._maid:Add(Promise.try(function()
        while true do
            for _, color in ipairs(colors) do
                local goal = {Color = color}
                local tweens = {}
                for name, bodyPart in pairs(self.bodyParts) do
                    local tween = TweenService:Create(bodyPart, tweenInfo, goal)
                    table.insert(tweens, tween)
                end
                local tweenGroup = TweenGroup.new(tweens)
                tweenGroup:Play()
                tweenGroup:AllCompletedOnce()
                :catchAndPrint()
                :await()
            end
        end
    end))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local TableUtils = Mod:find({"Table", "Utils"})
function IceAgeSkinC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.bodyParts = {
                Tail = self.char:FindFirstChild("Tail"),
                Body = self.char:FindFirstChild("Body"),
                Wings = self.char.Accessories:FindFirstChild("Wings"),
            }
            if TableUtils.len(self.bodyParts) ~= 3 then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function IceAgeSkinC:Destroy()
    self._maid:Destroy()
end

return IceAgeSkinC