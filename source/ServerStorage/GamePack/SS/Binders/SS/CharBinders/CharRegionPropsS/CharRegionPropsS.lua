local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharRegionPropsS = {}
CharRegionPropsS.__index = CharRegionPropsS
CharRegionPropsS.className = "CharRegionProps"
CharRegionPropsS.TAG_NAME = CharRegionPropsS.className

function CharRegionPropsS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharRegionPropsS)

    if not self:getFields() then return end
    self:handleRegions()

    return self
end

local EzRefUtils = Mod:find({"EzRef", "Utils"})
function CharRegionPropsS:handleRegions()
    local function updateProps(state, action)
        for _, propData in ipairs(action) do
            local inst = EzRefUtils.getCompositeEzRef(self.char, propData.ezRef)
            local prop = self.charProps.props[inst]
            if not prop then continue end
            prop[propData.method](prop, unpack(propData.args))
        end
    end
    self._maid:Add2(self.charState:getEvent(S.Session, "Regions", "Props"):Connect(updateProps))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharRegionPropsS:getFields()
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

function CharRegionPropsS:Destroy()
    self._maid:Destroy()
end

return CharRegionPropsS