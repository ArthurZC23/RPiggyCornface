local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local S = Data.Strings.Strings
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local Bindables = ReplicatedStorage.Bindables

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local Controller = {}
Controller.__index = Controller
Controller.className = "GuiServerRequestsController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerController)
    local self = {
        _maid = Maid.new(),
        playerController = playerController,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self:handle()
    return self
end

function Controller:handle()
    self._maid:Add2(playerState:getEvent("Session", "Gui", "request"):Connect(function(action)
        local openBtnLikeEvent = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal=action.signal})
        openBtnLikeEvent:Fire(true)
    end))
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