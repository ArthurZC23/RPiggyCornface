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

local MovingKillBlockC = {}
MovingKillBlockC.__index = MovingKillBlockC
MovingKillBlockC.className = "MovingKillBlock"
MovingKillBlockC.TAG_NAME = MovingKillBlockC.className

function MovingKillBlockC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MovingKillBlockC)

    if not self:getFields() then return end
    self:startObstacle()

    return self
end

local Promise = Mod:find({"Promise", "Promise"})
function MovingKillBlockC:spawn()
    local maid = self._maid:Add2(Maid.new(), "Spawn")
    self.MovingKillBlock = maid:Add(ReplicatedStorage.Assets.Obby.MovingBlocks[self.killBlockId]:Clone())
    local blockSpeed = self.RootModel:GetAttribute("blockSpeed")
    self.MovingKillBlock:PivotTo(self.BlockP0:GetPivot())
    self.Toucher = self.MovingKillBlock.Skeleton.Toucher
    self.Toucher.CanTouch = true
    self.Toucher.AlignPosition.RigidityEnabled = false
    self.Toucher.AlignPosition.MaxVelocity = blockSpeed
    self.Toucher.AlignPosition.Attachment1 = self.BlockP1.A1
    self.Toucher.AlignOrientation.Attachment1 = self.BlockP1.A1
    CollectionService:AddTag(self.Toucher, "KillBlock")
    self.MovingKillBlock.Parent = self.BlockContainer
end

function MovingKillBlockC:waitForSpawnToReachGoal()
    local monsterMaxLifetime = 60
    local ok, err = Promise.fromEvent(self.Toucher.Touched, function(hit)
        return hit == self.BlockP1
    end)
    :timeout(monsterMaxLifetime)
    :await()
    if not ok then warn(tostring(err)) end
end

function MovingKillBlockC:despawn()
    self._maid:Remove("Spawn")
end

function MovingKillBlockC:startObstacle()
    self._maid:Add(Promise.try(function()
        while true do
            task.wait(self.RootModel:GetAttribute("CooldownBeforeSpawn"))
            self:spawn()
            self:waitForSpawnToReachGoal()
            self:despawn()
        end
    end))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MovingKillBlockC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.BlockP0 = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="BlockP0"})
            if not self.BlockP0 then return end

            self.BlockP1 = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="BlockP1"})
            if not self.BlockP1 then return end

            self.BlockContainer = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="BlockContainer"})
            if not self.BlockContainer then return end

            self.killBlockId = self.RootModel:GetAttribute("killBlockId")
            if not self.killBlockId then return end

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

function MovingKillBlockC:Destroy()
    self._maid:Destroy()
end

return MovingKillBlockC