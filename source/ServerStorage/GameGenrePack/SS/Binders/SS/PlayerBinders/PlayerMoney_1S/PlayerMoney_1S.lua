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

local PlayerMoney_1S = {}
PlayerMoney_1S.__index = PlayerMoney_1S
PlayerMoney_1S.className = "PlayerMoney_1"
PlayerMoney_1S.TAG_NAME = PlayerMoney_1S.className

function PlayerMoney_1S.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerMoney_1S)

    if not self:getFields() then return end
    self:setPlayerNetwork()
    self:createRemotes()
    self:handleGetCoin()

    return self
end

local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local Promise = Mod:find({"Promise", "Promise"})
function PlayerMoney_1S:handleGetCoin()
    self.coinIdsTmpCach = {}
    self.network:Connect(self.GetCoinRE.OnServerEvent, function(player, coinId)

        if self.coinIdsTmpCach[coinId] then return end
        self.coinIdsTmpCach[coinId] = true

        local value = Calculators.calculate(self.playerState, "Money_1", 1, S.MapCoin)
        do
            local action = {
                name = "Increment",
                value = value,
                coinId = coinId,
            }
            self.playerState:set(S.Stores, "Money_1", action)
        end

    end)
end

function PlayerMoney_1S:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"GetCoin"},
        functions = {},
    }))
end

function PlayerMoney_1S:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerMoney_1S:getFields()
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

function PlayerMoney_1S:Destroy()
    self._maid:Destroy()
end

return PlayerMoney_1S