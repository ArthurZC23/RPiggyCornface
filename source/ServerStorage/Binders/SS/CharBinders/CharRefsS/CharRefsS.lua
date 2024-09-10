local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharRefsS = {}
CharRefsS.__index = CharRefsS
CharRefsS.className = "CharRefs"
CharRefsS.TAG_NAME = CharRefsS.className

function CharRefsS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharRefsS)

    if not self:getFields() then return end
    self:setRefs()

    return self
end

local EzRefUtils = Mod:find({"EzRef", "Utils"})
function CharRefsS:setRefs()
    GaiaShared.create("Folder", {
        Name = "References",
        Parent = self.char,
    })
    EzRefUtils.addEzRef(self.charParts.humanoid, "Humanoid")
end

function CharRefsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharState", self.char},
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharRefsS:Destroy()
    self._maid:Destroy()
end

return CharRefsS