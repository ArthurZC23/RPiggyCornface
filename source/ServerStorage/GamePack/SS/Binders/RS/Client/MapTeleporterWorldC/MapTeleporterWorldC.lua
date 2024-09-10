local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local MapTeleporterWorldC = {}
MapTeleporterWorldC.__index = MapTeleporterWorldC
MapTeleporterWorldC.className = "MapTeleporterWorld"
MapTeleporterWorldC.TAG_NAME = MapTeleporterWorldC.className

function MapTeleporterWorldC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MapTeleporterWorldC)

    if not self:getFields() then return end
    self:handleView()

    return self
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function MapTeleporterWorldC:handleView()
    local worldData = Data.Worlds.Worlds.idData[self.worldId]
    self.WorldName.Text = worldData.prettyName.Text

    local function update(state)
        if state.open[self.worldId] then
            self.Portal.Color = Color3.fromRGB(0, 255, 0)
            self.PortalTextLabel.Text = "OPEN!"
        else
            self.Portal.Color = Color3.fromRGB(255, 0, 0)
            self.PortalTextLabel.Text = ("%s %s Required!"):format(
                NumberFormatter.numberToEng(worldData.price.value), Data.Money.Money[S.Money_1].prettyName)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Worlds", "setWorld"):Connect(update))
    local state = self.playerState:get(S.Stores, "Worlds")
    update(state)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MapTeleporterWorldC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.worldId = self.RootModel:GetAttribute("worldId")
            if not self.worldId then return end

            self.Portal = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Portal"})
            if not self.Portal then return end

            self.PortalTextLabel = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="PortalTextLabel"})
            if not self.PortalTextLabel then return end

            self.WorldName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="WorldName"})
            if not self.WorldName then return end

            local bindersData = {
                {"PlayerState", localPlayer},
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

function MapTeleporterWorldC:Destroy()
    self._maid:Destroy()
end

return MapTeleporterWorldC