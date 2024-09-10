local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharAppearanceS = {}
CharAppearanceS.__index = CharAppearanceS
CharAppearanceS.className = "CharAppearance"
CharAppearanceS.TAG_NAME = CharAppearanceS.className

function CharAppearanceS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharAppearanceS)

    if not self:getFields() then return end
    self:handleProportions()

    return self
end

function CharAppearanceS:handleProportions()
    local humanoidDescription = self.charParts.humanoid:GetAppliedDescription()
    humanoidDescription.BodyTypeScale = 0.00 -- standard R15 body shape
    humanoidDescription.DepthScale = 0.95
    humanoidDescription.HeightScale = 0.90
    humanoidDescription.ProportionScale = 0.00
    humanoidDescription.BodyTypeScale = 0.00
    humanoidDescription.WidthScale = 0.90
    humanoidDescription.HeadScale = 1
    self.charParts.humanoid:ApplyDescription(humanoidDescription)
end

function CharAppearanceS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharParts", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAppearanceS:Destroy()
    self._maid:Destroy()
end

return CharAppearanceS