local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local function setAttributes()

end
setAttributes()

local PlayerRebirthS = {}
PlayerRebirthS.__index = PlayerRebirthS
PlayerRebirthS.className = "PlayerRebirth"
PlayerRebirthS.TAG_NAME = PlayerRebirthS.className

function PlayerRebirthS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerRebirthS)

    if not self:getFields() then return end
    self:setPlayerNetwork()
    self:createRemotes()
    self:handleRebirthProgression()
    self:handleRequestRebirth()

    return self
end

function PlayerRebirthS:handleRebirthProgression()
    local function updateAfterRebirth(rebirthState)
        local currentRebirth = rebirthState.current
        local currentBonus = 0.25 * currentRebirth
        do
            local multiplier = 1 + currentBonus
            local newAction = {
                name = "updateMultiplier",
                value = multiplier,
                multiplier = S.Rebirth,
            }
            self.playerState:set(S.Session, "Multipliers", newAction)
        end
        do
            local action = {
                name = "updateRebirthProgression",
                currentBonus = currentBonus,
                nextBonus = 0.25 * (currentRebirth + 1),
                rebirthCost = self:getMoneyRequiredToRebirth(currentRebirth)
            }
            self.playerState:set(S.Session, "Rebirth", action)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Rebirth", "Increment"):Connect(updateAfterRebirth))
    local rebirthState = self.playerState:get(S.Stores, "Rebirth")
    updateAfterRebirth(rebirthState)
end

function PlayerRebirthS:getMoneyRequiredToRebirth(currentRebirth)
    return 10 * 2 ^ currentRebirth
end

function PlayerRebirthS:handleRequestRebirth()
    self.network:Connect(self.RequestRebirthRE.OnServerEvent, function(player)
        local rebirthState = self.playerState:get("Stores", "Rebirth")
        local currentRebirth = rebirthState.current
        local rebirthCost = self:getMoneyRequiredToRebirth(currentRebirth)
        local moneyType = S.Money_1
        local moneyState = self.playerState:get("Stores", moneyType)
        local currentMoney = moneyState.current
        local moneyData = Data.Money.Money[S.Money_1]
        if currentMoney < rebirthCost then
            NotificationStreamRE:FireClient(player, {
                Text = ("Not enough %s for rebirth"):format(moneyData.prettyName),
            })
            return
        end
        do
            local action = {
                name = "Decrement",
                value = self.playerState:get(S.Stores, "Points").current,
            }
            self.playerState:set(S.Stores, "Points", action)
        end
        do
            local action = {
                name = "Decrement",
                value = self.playerState:get(S.Stores, moneyType).current,
            }
            self.playerState:set(S.Stores, moneyType, action)
        end
        do
            local action = {
                name = "Increment",
                value = 1,
            }
            self.playerState:set(S.Stores, "Rebirth", action)
        end
    end)
end

function PlayerRebirthS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestRebirth", "SkipRebirth"},
        functions = {},
    }))
end

function PlayerRebirthS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerRebirthS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerRebirthS:Destroy()
    self._maid:Destroy()
end

return PlayerRebirthS