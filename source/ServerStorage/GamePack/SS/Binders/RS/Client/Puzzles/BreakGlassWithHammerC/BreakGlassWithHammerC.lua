local CollectionService = game:GetService("CollectionService")
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

local BreakGlassWithHammerC = {}
BreakGlassWithHammerC.__index = BreakGlassWithHammerC
BreakGlassWithHammerC.className = "BreakGlassWithHammer"
BreakGlassWithHammerC.TAG_NAME = BreakGlassWithHammerC.className

function BreakGlassWithHammerC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
        keys = {},
    }
    setmetatable(self, BreakGlassWithHammerC)

    if not self:getFields() then return end
    self:handleFinishPuzzle()

    return self
end

function BreakGlassWithHammerC:handleFinishPuzzle()
    self._maid:Add(self.puzzle.FinishPuzzleSE:Connect(function()
        for _, child in ipairs(self.GlassModel:GetChildren()) do
            child:Destroy()
        end
        CollectionService:RemoveTag(self.RootModel, BreakGlassWithHammerC.TAG_NAME)
    end))

    self.puzzle:handleTouch()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function BreakGlassWithHammerC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.GlassModel = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="GlassModel"})
            if not self.GlassModel then return end

            local bindersData = {
                {"Puzzle", self.RootModel},
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

function BreakGlassWithHammerC:Destroy()
    self._maid:Destroy()
end

return BreakGlassWithHammerC