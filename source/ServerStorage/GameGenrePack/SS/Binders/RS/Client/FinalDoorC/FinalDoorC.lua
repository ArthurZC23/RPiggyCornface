local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local FinalDoorC = {}
FinalDoorC.__index = FinalDoorC
FinalDoorC.className = "FinalDoor"
FinalDoorC.TAG_NAME = FinalDoorC.className

function FinalDoorC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, FinalDoorC)

    if not self:getFields() then return end
    self:handleGameEnd()
    self:handleDoorOpen()

    return self
end

function FinalDoorC:handleGameEnd()
    local function update()
        local NewRootModel = ReplicatedStorage.Assets.Models.FinalDoor:Clone()
        NewRootModel:PivotTo(self.RootModel:GetPivot())
        NewRootModel:AddTag(FinalDoorC.TAG_NAME)
        NewRootModel.Parent = self.RootModel.Parent
        self.RootModel:Destroy()
    end
    self._maid:Add2(self.playerState:getEvent(S.Session, "_Game", "reset"):Connect(update))
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function FinalDoorC:handleDoorOpen()
    local function update(state)
        if state.total ~= Data.Map.Map.numberTokens then return end

        self.MView1:Destroy()
        for i, desc in ipairs(self.MView2:GetDescendants()) do
            if not desc:IsA("BasePart") then continue end
            desc.CanCollide = true
            desc.Transparency = 0
        end
        self._maid:Add2(self.Toucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
            function()
                local FinishGameRE = ComposedKey.getEvent(localPlayer, "FinishGame")
                if not FinishGameRE then return end
                FinishGameRE:FireServer()
                task.wait(3)
            end,
            0.5
        )), "Toucher")

        self._maid:Remove("UpdateMapTokens")
    end
    self._maid:Add2(self.playerState:getEvent(S.Session, "MapTokens", "update"):Connect(update), "UpdateMapTokens")
    local state = self.playerState:get(S.Session, "MapTokens")
    update(state)
end

function FinalDoorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.MView1 = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "MView1"})
            if not self.MView1 then return end

            self.MView2 = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "MView2"})
            if not self.MView2 then return end

            self.Toucher = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Toucher"})
            if not self.Toucher then return end

            local bindersData = {
                {"PlayerState", localPlayer}
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function FinalDoorC:Destroy()
    self._maid:Destroy()
end

return FinalDoorC