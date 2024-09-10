local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local LifeProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="LifeProto"})
local LivesContainer = LifeProto.Parent
LifeProto.Parent = nil
local BuyLifeFr = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BuyLifeFr"})

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "UpdateLivesController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
        player = playerGuis.player,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self:handlePurchaseLife()
    self:setLives()
    self:handleView()
    return self
end

function Controller:handlePurchaseLife()
    BuyLifeFr:SetAttribute("devProduct", "1873872904")
    BuyLifeFr:AddTag("DeveloperProductButton")
end

function Controller:setLives()
    for i = 1, Data.Map.Map.maxLives do
        local _gui = LifeProto:Clone()
        _gui.Name = tostring(i)
        _gui.LayoutOrder = i
        _gui.Parent = LivesContainer
    end
end

function Controller:handleView()
    local function update(state)
        for i = 1, state.cur do
            local _gui = LivesContainer:FindFirstChild(tostring(i))
            if not _gui then continue end
            _gui.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        for i = state.cur + 1, Data.Map.Map.maxLives do
            local _gui = LivesContainer:FindFirstChild(tostring(i))
            if not _gui then continue end
            _gui.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "Lives", "update"):Connect(update))
    local state = self.playerState:get(S.Session, "Lives")
    update(state)
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

