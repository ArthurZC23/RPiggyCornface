local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local MeasurePartS = {}
MeasurePartS.__index = MeasurePartS
MeasurePartS.className = "MeasurePart"
MeasurePartS.TAG_NAME = MeasurePartS.className

function MeasurePartS.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, MeasurePartS)

    task.defer(function()
        part:Destroy()
    end)

    return self
end

function MeasurePartS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function MeasurePartS:Destroy()
    self._maid:Destroy()
end

return MeasurePartS