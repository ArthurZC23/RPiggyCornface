local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})
local Promise = Mod:find({"Promise", "Promise"})

local TeleportToObbyStartS = {}
TeleportToObbyStartS.__index = TeleportToObbyStartS
TeleportToObbyStartS.className = "TeleportToObbyStart"
TeleportToObbyStartS.TAG_NAME = TeleportToObbyStartS.className

function TeleportToObbyStartS.new(Part)
    local self = {
        Part = Part,
        _maid = Maid.new(),
    }
    setmetatable(self, TeleportToObbyStartS)

    if not self:getFields() then return end
    self:handleTouch()

    return self
end

function TeleportToObbyStartS:handleTouch()
    self._maid:Add(self.Part.Touched:Connect(InstanceDebounce.playerHrpCooldownPerPlayer(
        function(player, char)
            local charParts = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharParts", inst = char})
            if not charParts then return end
            charParts.hrp:PivotTo(self.Destination:GetPivot())
        end,
        0.1
    )))
end

function TeleportToObbyStartS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.Destination = ComposedKey.getFirstDescendant(self.Part, {"StartObby"})
            if not self.Destination then return end
            self.Destination = self.Destination.Value
            if not self.Destination then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.Part.Parent
        end,
    })
    return ok
end

function TeleportToObbyStartS:Destroy()
    self._maid:Destroy()
end

return TeleportToObbyStartS