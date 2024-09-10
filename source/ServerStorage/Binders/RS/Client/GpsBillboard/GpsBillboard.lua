
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GpsData = Data.GamePasses.GamePasses
local GpsUiData = Data.GamePasses.Ui
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")

local binderPlayerGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGameState"})
local playerGameState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerGameState, inst=localPlayer})

local BoostsUx = require(ReplicatedStorage.Ux.Boosts)

local PurchaseGpRE = ReplicatedStorage.Remotes.Events.PurchaseGp

local GpsBillboard = {}
GpsBillboard.__index = GpsBillboard
GpsBillboard.className = "GpsBillboard"
GpsBillboard.TAG_NAME = GpsBillboard.className

function GpsBillboard.new(gui)
    local self = {
        _maid = Maid.new(),
        gui = gui,
    }
    setmetatable(self, GpsBillboard)

    if not self:getFields() then return end
    self:handleGps()

    return self
end

function GpsBillboard:updateViewAfterPurchase(gpId)
    local detailsGui = self.GpsContainer:FindFirstChild(gpId)
    if not detailsGui then return end

    detailsGui.RequestPurchase.Visible = false
    detailsGui.Purchased.Visible = true
end

function GpsBillboard:addPurchaseCapability(detailsGui)
    local btn = detailsGui.RequestPurchase.Btn
    local gpId = detailsGui.Name
    local gpsState = self.playerState:get("Stores", "GamePasses")
    if gpsState.st[gpId] then
        self:updateViewAfterPurchase(gpId)
    else
        btn.Activated:Connect(function()
            PurchaseGpRE:FireServer(detailsGui:GetAttribute("GpId"))
        end)
    end
end

function GpsBillboard:render(detailsGui, data)
    local header = detailsGui.Header
    local ShortDescription = header.ShortDescription
    local LongDescription = detailsGui.LongDescriptionFr.LongDescription
    TableUtils.setInstance(ShortDescription, {Text = data.shortDescription.Text})
    TableUtils.setInstance(LongDescription, {Text = data.longDescription.Text})

    local btn = detailsGui.RequestPurchase.Btn
    BoostsUx.addUx(btn, {
        dilatation = {
            expandFactor = {
                X=1,
                Y=1.1,
            }
        }
    })
end

function GpsBillboard:handleGps()
    local maid = self._maid:Add2(Maid.new(), "SetGui")

    self.GpsContainer = self.GamePassesDetailsProto.Parent
    self.GamePassesDetailsProto.Parent = nil

    self.gui.Name = "GpsBillboard"
    self.gui.PixelsPerStud = 75
    self.gui.LightInfluence = 0
    self.gui.Adornee = self.gui.Parent
    self.gui.AlwaysOnTop = false
    self.gui.Enabled = true
    self.gui.ResetOnSpawn = false
    self.gui.Parent = PlayerGui

    local guis = {}

    for _, data in pairs(GpsUiData.gpProducts) do

        local detailsGui = maid:Add(self.GamePassesDetailsProto:Clone())
        local gpId = GpsData.nameToData[data.name].id
        detailsGui:SetAttribute("GpId", gpId)

        self:render(detailsGui, data)
        self:addPurchaseCapability(detailsGui)

        detailsGui.Name = gpId
        detailsGui.LayoutOrder = data.LayoutOrder
        detailsGui.Visible = true
        detailsGui.Parent = self.GpsContainer
        table.insert(guis, detailsGui)
    end
    maid:Add(function()
        for _, gui in ipairs(guis) do
            gui:Destroy()
        end
    end)
    maid:Add(self.playerState:getEvent("Stores", "GamePasses", "addGamePass"):Connect(function(state, action)
        self:updateViewAfterPurchase(action.id)
    end))
    maid:Add(self:updateWithRobloxData(self.GpsContainer))
end

function GpsBillboard:updateWithRobloxData(sFrame)
    local maid = Maid.new()

    local function update(state)
        for _, productGui in ipairs(sFrame:GetChildren()) do
            if (not productGui:IsA("GuiObject")) or (not productGui.Visible) then continue end
            local id = productGui.Name
            local data = state[id]
            if not data then continue end

            local image = productGui.Header.ImageLabel
            TableUtils.setInstance(
                image,
                {
                    Image = data.thumbnail
                }
            )

            productGui.LongDescriptionFr.LongDescription.Text = data.longDescription
        end
    end
    maid:Add(playerGameState:getEvent("Session", "GamePasses", "addGamePass"):Connect(update))
    update(playerGameState:get("Session", "GamePasses"))

    return maid
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function GpsBillboard:getFields()
    return WaitFor.GetAsync({
        getter=function()

            self.GamePassesDetailsProto = ComposedKey.getFirstDescendant(self.gui, {"Root", "Gamepasses", "GamePassesDetailsProto"})
            if not self.GamePassesDetailsProto then return end

            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return localPlayer.Parent
        end,
        cooldown=nil
    })
end

function GpsBillboard:Destroy()
    self._maid:Destroy()
end

return GpsBillboard