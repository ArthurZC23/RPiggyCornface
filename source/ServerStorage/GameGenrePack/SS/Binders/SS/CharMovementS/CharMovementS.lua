local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharMovementS = {}
CharMovementS.__index = CharMovementS
CharMovementS.className = "CharMovement"
CharMovementS.TAG_NAME = CharMovementS.className

function CharMovementS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        keysTool = {},
    }
    setmetatable(self, CharMovementS)

    if not self:getFields() then return end
    self:setSpeed()

    return self
end

function CharMovementS:setSpeed()
    self.charParts.humanoid.WalkSpeed = Data.Char.Char.speed.default
end


local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharMovementS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharParts", self.char},
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

function CharMovementS:Destroy()
    self._maid:Destroy()
end

return CharMovementS