local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Maid = Mod:find({"Maid"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local CrawlButton = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="CrawlButton"})

local CrawlF = script:FindFirstAncestor("Crawl")
local View = require(ComposedKey.getAsync(CrawlF, {"CharView"}))

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "CrawlControllerTeamEngine"
Controller.TAG_NAME = Controller.className

function Controller.new(charTeamGuis)
    local self = {
        _maid = Maid.new(),
        char = charTeamGuis.char,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    local view = self._maid:AddComponent(View.new(self))
    if not view then return end
    self:handleInput()
    self:handleCrawlButton()

    return self
end

function Controller:toggleCrawl()
    local ToggleCrawlRE = ComposedKey.getEvent(self.char, "ToggleCrawl")
    if not ToggleCrawlRE then return end
    ToggleCrawlRE:FireServer()
end

local ContextActionService = game:GetService("ContextActionService")
local CasUtils = Mod:find({"UserInput", "CasUtils"})
function Controller:handleInput()
    local action = "Crawl"

    self._maid:Add(function()
        ContextActionService:UnbindAction(action)
    end)

    local callback = function()
        self:toggleCrawl()
    end

    ContextActionService:BindAction(
        action,
        CasUtils.InputBegin(callback),
        false,
        unpack({Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonB})
    )
end

function Controller:handleCrawlButton()
    self._maid:Add2(CrawlButton.Activated:Connect(function()
        self:toggleCrawl()
    end))
end


function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharState", self.char},
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