local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local BoostGuiProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BoostProto"})
local BoostContainer = BoostGuiProto.Parent
local BoostsGuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BoostsGuiFrame"})
BoostGuiProto.Parent = nil

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "ActiveBoostsController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerController)
    local self = {
        _maid = Maid.new(),
        playerController = playerController,
    }
    setmetatable(self, Controller)

    if not self:getFields() then return end
    self:handleBoost()

    return self
end


local Functional = Mod:find({"Functional"})
function Controller:handleBoost()
    local function removeMiniView(boostId)
        self._maid:Remove(("Boost_%s"):format(boostId))

        local otherBoostGuis = Functional.filter(BoostContainer:GetChildren(), function(child)
            return child:IsA("GuiObject")
        end)
        if not next(otherBoostGuis) then
            BoostsGuiFrame.Visible = false
        end
    end

    local function addMiniView(boostId)
        local boostGui = BoostContainer:FindFirstChild(boostId)
        if boostGui then return end

        local maid = self._maid:Add2(Maid.new(), ("Boost_%s"):format(boostId))

        boostGui = maid:Add2(BoostGuiProto:Clone())
        boostGui.Image = Data.Boosts.Boosts.idData[boostId].thumbnail
        boostGui.Name = boostId
        boostGui.Visible = true
        boostGui.Parent = BoostContainer
        BoostsGuiFrame.Visible = true
    end

    self._maid:Add2(self.playerState:getEvent(S.Stores, "Boosts", "removeBoost"):Connect(function(state, action)
        removeMiniView(action.boostId)
    end))

    self._maid:Add2(self.playerState:getEvent(S.Stores, "Boosts", "addBoost"):Connect(function(state, action)
        addMiniView(action.boostId)
    end))

    for boostId in pairs(self.playerState:get(S.Stores, "Boosts").st) do
        addMiniView(boostId)
    end
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local char = localPlayer.Character
            if not (char and char.Parent) then return end
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller