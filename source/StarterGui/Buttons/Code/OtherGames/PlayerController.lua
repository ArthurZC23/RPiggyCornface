local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local OtherGamesFr = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="OtherGamesBtn"})
local OtherGamesBtn = OtherGamesFr:WaitForChild("Btn")

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "OtherGamesController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerController)
    local self = {
        _maid = Maid.new(),
        playerController = playerController,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end

    self:handleOtherGames()

    return self
end

local Platforms = Mod:find({"Platforms", "Platforms"})
function Controller:handleOtherGames()
    local function update(state)
        if
            (Platforms.getPlatform() == Platforms.Platforms.Mobile)
            or localPlayer.UserId == 925418276
        then
            OtherGamesBtn.Visible = true
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "PolicyService", "setPoliceService"):Connect(update))
    local state = self.playerState:get(S.Session, "PolicyService")
    update(state)
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
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