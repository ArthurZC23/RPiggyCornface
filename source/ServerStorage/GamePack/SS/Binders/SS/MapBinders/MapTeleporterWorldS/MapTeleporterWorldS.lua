local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

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

local MapTeleporterWorldS = {}
MapTeleporterWorldS.__index = MapTeleporterWorldS
MapTeleporterWorldS.className = "MapTeleporterWorld"
MapTeleporterWorldS.TAG_NAME = MapTeleporterWorldS.className

function MapTeleporterWorldS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MapTeleporterWorldS)

    if not self:getFields() then return end
    self:handleTouch()

    return self
end

local Debounce = Mod:find({"Debounce", "Debounce"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})

function MapTeleporterWorldS:handleTouch()
    self._maid:Add2(self.Toucher.Touched:Connect(InstanceDebounce.playerHrpCooldownPerPlayer(
        function(player)
            local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
            if not playerState then return end
            local char = player.Character
            if not (char and char.Parent) then return end

            local worldData = Data.Worlds.Worlds.idData[self.worldId]
            local worldsState = playerState:get(S.Stores, "Worlds")
            if worldsState.open[self.worldId] then
                do
                    local action = {
                        name = "setCurrentWorld",
                        value = self.worldId
                    }
                    playerState:set(S.Session, "Worlds", action)
                end
            elseif worldData.price.notEnoughFundsDevProduct then
                local TryDeveloperPurchaseBE = ServerStorage.Bindables.Events.TryDeveloperPurchase
                TryDeveloperPurchaseBE:Fire(player, worldData.price.notEnoughFundsDevProduct)
            end
        end,
        1
    )))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MapTeleporterWorldS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.worldId = self.RootModel:GetAttribute("worldId")
            if not self.worldId then return end

            self.Toucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Toucher"})
            if not self.Toucher then return end

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

function MapTeleporterWorldS:Destroy()
    self._maid:Destroy()
end

return MapTeleporterWorldS