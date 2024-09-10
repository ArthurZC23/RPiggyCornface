local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local TimeFormatter = Mod:find({"Formatters", "TimeFormatter"})
local SignalE = Mod:find({"Signal", "Event"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local TableUtils = Mod:find({"Table", "Utils"})

local Data = Mod:find({"Data", "Data"})
local GpData = Data.GamePasses.GamePasses
local GameData = Data.Game.Game
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local ChestC = {}
ChestC.__index = ChestC
ChestC.TAG_NAME = "Chest"

ChestC.bag = {}

function ChestC.new(chest)
	local self = {
        _maid = Maid.new(),
        chest = chest,
        ChestF = chest.Chest,
        chestId = chest:GetAttribute("ChestId"),
    }
	setmetatable(self, ChestC)

    if not self:getFields() then return end
    self:handleTimeSignal()
    self:handleProximityPrompt()
    self:addObjToBag()

	return self
end

function ChestC:addObjToBag()
    ChestC.bag[self.chestId] = self
end


function ChestC:handleProximityPrompt()
    self.proximityPrompt = self.chest.Beacon.Toucher.Attachment.ProximityPrompt
    FastSpawn(function()
        -- self:updateAmount()

    end)

    self.proximityPrompt.HoldDuration = 0.5
    self.proximityPrompt.MaxActivationDistance = 12

    self.proximityPrompt.Triggered:Connect(function()
        local canOpen = self:verifyOpenConditions()
        if not canOpen then return end
        self:requestToOpenChest()
    end)
end

local Bach = Mod:find({"Bach", "Bach"})
local Popup = Mod:find({"Gui", "Popup"})

function ChestC:verifyOpenConditions()
    local reward = self.data.reward
    if reward._type == "Group" then
        local isPlayerInGroup = localPlayer:GetAttribute("isInGroup")
        if not isPlayerInGroup then
            Bach:play("Denied", Bach.SoundTypes.SfxGui)

            local popup = Popup.new()
            popup:setHeader({
                text = "👍 Like game + Join our group to unlock rewards! 😃",
            })
            popup:setButtonCenter({
                text = "Okay!",
                cb = function()

                end
            })
            popup:activate()
            return false
        end
    end
    if reward._type == "Gamepass" then
        local gpsState = self.playerState:get(S.Stores, "GamePasses")
        if not gpsState.st[reward.gpId] then
            local PurchaseGpRE = ComposedKey.getEvent(ReplicatedStorage, "PurchaseGp")
            if not PurchaseGpRE then return end
            PurchaseGpRE:FireServer(reward.gpId)
        end
    end
    return true
end

function ChestC:requestToOpenChest()
    self.RequestToOpenChestRE = ComposedKey.getEvent(localPlayer, "RequestToOpenChest")
    if not self.RequestToOpenChestRE then return end

    self.RequestToOpenChestRE:FireServer(self.chestId)
end

function ChestC:startTimer(t1)
    self.proximityPrompt.Enabled = false
    self.readyTextLabel.Visible = false

    local timeLeft = t1 - Cronos:getTime()
    self.timerTextLabel.Text = TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0))
    self.timerTextLabel.Visible = true

    for i, child in ipairs(self.RewardContainer:GetChildren()) do
        if not child:IsA("GuiObject") then continue end
        child.Visible = false
    end

    while timeLeft > 0 do
        Cronos.wait(1)
        timeLeft = math.max(t1 - Cronos:getTime(), 0)
        self.timerTextLabel.Text = TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0))
    end
    self.timerTextLabel.Text = TimeFormatter.formatToHHMMSS(0)
end

function ChestC:finishTimer()
    self.readyTextLabel.Visible = true
    self.timerTextLabel.Visible = false
    self.proximityPrompt.Enabled = true

    for i, child in ipairs(self.RewardContainer:GetChildren()) do
        if not child:IsA("GuiObject") then continue end
        child.Visible = true
    end
end

function ChestC:getTimerSignal()
    return self.timerSignal
end

function ChestC:handleTimeSignal()
    self.timerSignal = self._maid:Add(SignalE.new())
    self._maid:Add2(self.timerSignal:Connect(function(command, ...)
        self[command](self, ...)
    end))
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function ChestC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer}
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {

            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end

            self.data = Data.Chests.Chests.idData[self.chestId]

            self.readyTextLabel = ComposedKey.getFirstDescendant(self.ChestF, {"Guis", "ChestName", "Ready"})
            if not self.readyTextLabel then return end
            self.timerTextLabel = ComposedKey.getFirstDescendant(self.ChestF, {"Guis", "ChestName", "Timer"})
            if not self.timerTextLabel then return end
            self.TreasureName = ComposedKey.getFirstDescendant(self.ChestF, {"Guis", "ChestName", "TreasureName"})
            if not self.TreasureName then return end

            self.SingleRewardProto = ComposedKey.getFirstDescendant(self.ChestF, {"Guis", "ChestInfo", "SingleRewardProto"})
            if not self.SingleRewardProto then return end
            self.RewardContainer = self.SingleRewardProto.Parent
            self.SingleRewardProto.Parent = nil

            if self.data.showRewards then
                for i, rData in pairs(self.data.rewards) do
                    local SingleReward = self._maid:Add(self.SingleRewardProto:Clone())
                    SingleReward.ImageLabel.Image = rData.thumbnail
                    SingleReward.Name = tostring(i)
                    SingleReward.LayoutOrder = i
                    SingleReward.Visible = true
                    SingleReward.Parent = self.RewardContainer
                end
            end

            return true
        end,
        keepTrying=function()
            return self.chest.Parent
        end,
        cooldown=nil
    })
end

function ChestC:Destroy()
    self._maid:Destroy()
end

return ChestC