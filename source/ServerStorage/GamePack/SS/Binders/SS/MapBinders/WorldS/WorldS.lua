local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local function setAttributes()

end
setAttributes()

local WorldS = {}
WorldS.__index = WorldS
WorldS.className = "World"
WorldS.TAG_NAME = WorldS.className

function WorldS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, WorldS)

    if not self:getFields() then return end
    self:setWorld()

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function WorldS:setBaseBillboards()
    CollectionService:AddTag(self.WorldBillboard, "GuiWorldBillboard")
    WaitFor.BObj(self.WorldBillboard, "GuiWorldBillboard")
    :andThen(function(GuiWorldBillboard)
        GuiWorldBillboard:setView(self.worldId)
    end)
end

function WorldS:setObstacleEnds()
    for _, Obstacle in ipairs(self.RootModel.Obstacles:GetChildren()) do
        local ObstacleEnd = SharedSherlock:find({"EzRef", "Get"}, {inst=Obstacle, refName="ObstacleEnd"})
        ObstacleEnd:SetAttribute("worldId", self.worldId)
        local obstacleId = Obstacle.Name
        Obstacle:SetAttribute("obstacleId", obstacleId)
        ObstacleEnd:SetAttribute("obstacleId", obstacleId)
    end
end

function WorldS:setWorld()
    self:setBaseBillboards()
    self:setObstacleEnds()
end

function WorldS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.worldId = self.RootModel:GetAttribute("worldId")
            if not self.worldId then return end

            self.WorldBillboard = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="WorldBillboard"})
            if not self.WorldBillboard then return end

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

function WorldS:Destroy()
    self._maid:Destroy()
end

return WorldS