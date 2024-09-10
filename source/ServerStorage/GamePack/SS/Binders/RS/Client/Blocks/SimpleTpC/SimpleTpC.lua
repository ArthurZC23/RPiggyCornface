local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function setAttributes()

end
setAttributes()

local SimpleTpC = {}
SimpleTpC.__index = SimpleTpC
SimpleTpC.className = "SimpleTp"
SimpleTpC.TAG_NAME = SimpleTpC.className

function SimpleTpC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, SimpleTpC)

    if not self:getFields() then return end
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function SimpleTpC:handleTouch()
    self._maid:Add2(self.Toucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
        function(player, char, _)
            local charParts = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharParts", inst = char})
            if not charParts then return end
            charParts.hrp:PivotTo(self.Target:GetPivot())
        end,
        0.5
    )))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function SimpleTpC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.Toucher = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Toucher"})
            if not self.Toucher then return end

            self.Target = ComposedKey.getFirstDescendant(self.Toucher, {"Target"})
            if not self.Target then return end
            self.Target = self.Target.Value
            if not self.Target then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function SimpleTpC:Destroy()
    self._maid:Destroy()
end

return SimpleTpC