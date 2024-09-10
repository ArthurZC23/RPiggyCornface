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

local ObstacleEndS = {}
ObstacleEndS.__index = ObstacleEndS
ObstacleEndS.className = "ObstacleEnd"
ObstacleEndS.TAG_NAME = ObstacleEndS.className

function ObstacleEndS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, ObstacleEndS)

    if not self:getFields() then return end
    self:createRemotes()
    self:handleObstacleReward()

    return self
end

local Debounce = Mod:find({"Debounce", "Debounce"})
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
function ObstacleEndS:handleObstacleReward()
    self.GetObstacleRewardRE.OnServerEvent:Connect(Debounce.remotesCooldownPerPlayer(
        function(player, obstacleId)
            local char = player.Character
            if not (char and char.Parent) then return end
            local PrizeToucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="PrizeToucher"})
            if not PrizeToucher then return end
            if (PrizeToucher:GetPivot().Position - char:GetPivot().Position).Magnitude > 48 then return end
            local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag="PlayerState", inst = player})
            if not playerState then return end
            local charWalkSpeedManager = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharWalkSpeedManager", inst = char})
            if not charWalkSpeedManager then return end
            local obstacleData = Data.Obstacles.Obstacles.idData[obstacleId]
            local World = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace, refName=("World%s"):format(self.worldId)})
            local MapTeleportTargets = SharedSherlock:find({"EzRef", "Get"}, {inst=World, refName=("MapTeleportTargets")})
            local CharTeleportSE = SharedSherlock:find({"Bindable", "async"}, {root = char, signal = "CharTeleport"})
            CharTeleportSE:Fire({
                Targets = MapTeleportTargets.Model:GetChildren()
            })

            --
            local totalPoints = playerState:get(S.Stores, "Points").current
            do
                local action = {
                    name = "Decrement",
                    value = totalPoints,
                    gainBackPoints = true,
                }
                playerState:set(S.Stores, "Points", action)
            end
            Giver.give(playerState, S.Money_1, obstacleData.reward, S.MapReward, {
                ux = true
            })
            charWalkSpeedManager:setDefaultSpeed()
            task.wait(10) -- Avoid touch on client before teleport
        end,
        0.5
    ))
end

function ObstacleEndS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.RootModel, {
        events = {"GetObstacleReward"},
        functions = {},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function ObstacleEndS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.worldId = self.RootModel:GetAttribute("worldId")
            if not self.worldId then return end
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

function ObstacleEndS:Destroy()
    self._maid:Destroy()
end

return ObstacleEndS