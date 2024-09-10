local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local RegionsData = Data.Regions.Regions.regionsData
local RegionsEvents = Data.Regions.Regions.regionsEvents
local Functional = Mod:find({"Functional"})
local Math = Mod:find({"Math", "Math"})
local TweenUtils = Mod:find({"Tween", "Utils"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Header = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Header"})
local Description = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Description"})
local Line = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Line"})
local UiListLayout = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="UiListLayout"})
local Maid = Mod:find({"Maid"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local View = {}
View.__index = View
View.className = "View"
View.TAG_NAME = View.className

function View.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, View)
    if not self:getFields() then return end
    self:handleEnteringArea()
    return self
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local char = localPlayer.Character
            if not (char and char.Parent) then return end
            local bindersData = {
                {"CharState", char},
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


function View:Destroy()
    self._maid:Destroy()
end

return View