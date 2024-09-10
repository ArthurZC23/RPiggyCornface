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

local RainbowMonsterSkinC = {}
RainbowMonsterSkinC.__index = RainbowMonsterSkinC
RainbowMonsterSkinC.className = "RainbowMonsterSkin"
RainbowMonsterSkinC.TAG_NAME = RainbowMonsterSkinC.className
RainbowMonsterSkinC.bagArray = {}

function RainbowMonsterSkinC.new(char)
    if not char:IsDescendantOf(workspace) then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, RainbowMonsterSkinC)

    if not self:getFields() then return end
    self:runRainbow()

    return self
end

local TweenService = game:GetService("TweenService")
local Promise = Mod:find({"Promise", "Promise"})
local TweenGroup = Mod:find({"Tween", "TweenGroup"})
local Functional = Mod:find({"Functional"})
function RainbowMonsterSkinC:runRainbow()
    local colors = {
        [1] = Color3.fromRGB(176, 55, 34),
        [2] = Color3.fromRGB(168, 106, 0),
        [3] = Color3.fromRGB(152, 152, 0),
        [4] = Color3.fromRGB(0, 158, 0),
        [5] = Color3.fromRGB(0, 0, 255),
        [6] = Color3.fromRGB(94, 0, 166),
        [7] = Color3.fromRGB(172, 94, 172),
    }
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

    self._maid:Add(Promise.try(function()
        while true do
            self.bodyParts = Functional.filter(self.char:GetDescendants(), function(desc)
                return desc:IsA("BasePart")
            end)
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
function RainbowMonsterSkinC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function RainbowMonsterSkinC:Destroy()
    self._maid:Destroy()
end

return RainbowMonsterSkinC