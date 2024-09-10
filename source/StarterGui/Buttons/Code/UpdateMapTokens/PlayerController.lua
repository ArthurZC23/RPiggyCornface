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
local MapTokens = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="MapTokens"})

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "UpdateMapTokensController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
        player = playerGuis.player,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self:handleMapTokens()
    return self
end

function Controller:handleMapTokens()
    local playerState = self.playerGuis.playerState
    local function update(state, action)
        MapTokens.Text = ("%s/%s"):format(state.total, Data.Map.Map.numberTokens)
    end
    self._maid:Add(playerState:getEvent(S.Session, "MapTokens", "update"):Connect(update))
    local state = playerState:get(S.Session, "MapTokens")
    update(state)
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local char = localPlayer.Character
            if not (char and char.Parent) then return end
            local bindersData = {

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

