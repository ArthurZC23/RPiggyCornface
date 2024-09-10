local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Cronos = Mod:find({"Cronos", "Cronos"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

local PlayerBecomeMonsterS = {}
PlayerBecomeMonsterS.__index = PlayerBecomeMonsterS
PlayerBecomeMonsterS.className = "PlayerBecomeMonster"
PlayerBecomeMonsterS.TAG_NAME = PlayerBecomeMonsterS.className

function PlayerBecomeMonsterS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerBecomeMonsterS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleTeamChange()
    self:handleBecomeMonster()

    return self
end

function PlayerBecomeMonsterS:handleIncreaseMonsterTimeWhileMonster()
    local maid = Maid.new()
    local function update(_, action)
        local moneyPayment = action.value
        do
            local _action = {
                name = "Decrement",
                value = moneyPayment,
            }
            self.playerState:set(S.Stores, "MoneyMonster", _action)
        end
        do
            local monsterState = gameState:get(S.Session, "Monster")
            local t1 = monsterState.t1 + moneyPayment * Data.MonsterSkins.MonsterSkins.playerMonster.timeMoneyMonsterRatio
            local skinId = self.playerState:get(S.Stores, "MonsterSkins").eq
            local _action = {
                name = "setPlayerMonster",
                playerId = self.player.UserId,
                skinId = skinId,
                t1 = t1,
            }
            gameState:set(S.Session, "Monster", _action)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "MoneyMonster", "Increment"):Connect(update))

    return maid
end

local Promise = Mod:find({"Promise", "Promise"})
function PlayerBecomeMonsterS:handleMonsterTimer()
    local maid = Maid.new()
    -- maid:Add2(Promise.try(function()

    -- end))
    local BigBen = Mod:find({"Cronos", "BigBen"})
    maid:Add(BigBen.every(1, "Heartbeat", "time_", true):Connect(function()
        local t = Cronos:getTime()
        local monsterState = gameState:get(S.Session, "Monster")
        if monsterState.t1 < t then
            do
                local action = {
                    name = "setNpcMonster",
                }
                gameState:set(S.Session, "Monster", action)
            end
        end
    end))
    return maid
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerBecomeMonsterS:handleTeamChange()
    local function update()
        local maid = self._maid:Add2(Maid.new(), "handleTeamChangeUpdate")
        local team = self.player:GetAttribute("team")

        print("Test this")
        if team == "monster" then
            -- maid:Add2(self:handleIncreaseMonsterTimeWhileMonster())
            maid:Add2(self:handleMonsterTimer())
        else

        end
    end
    self._maid:Add2(self.player:GetAttributeChangedSignal("team"):Connect(update))
    local team = self.player:GetAttribute("team")
    if team == "monster" then
        update()
    end
end

function PlayerBecomeMonsterS:canBecomeMonster(carryRes)
    local moneyMonsterState = self.playerState:get(S.Stores, "MoneyMonster")
    if moneyMonsterState.current < carryRes.moneyPayment then return end

    local monsterState = gameState:get(S.Session, "Monster")
    if monsterState._type == "player" then
        local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
        NotificationStreamRE:FireClient(self.player, {
            Text = ("Another player is the monster right now."),
        })
        return
    end

    return true
end

function PlayerBecomeMonsterS:handleBecomeMonster()
    self.network:Connect(self.BecomeMonsterRE.OnServerEvent, function(player, moneyPayment)
        local carryRes = {
            moneyPayment = moneyPayment,
        }
        if not self:canBecomeMonster(carryRes) then return end

        do
            local action = {
                name = "Decrement",
                value = moneyPayment,
            }
            self.playerState:set(S.Stores, "MoneyMonster", action)
        end
        do
            local t1 = Cronos:getTime() + moneyPayment * Data.MonsterSkins.MonsterSkins.playerMonster.timeMoneyMonsterRatio
            local skinId = self.playerState:get(S.Stores, "MonsterSkins").eq
            local action = {
                name = "setPlayerMonster",
                playerId = self.player.UserId,
                skinId = skinId,
                t1 = t1,
            }
            gameState:set(S.Session, "Monster", action)
        end
    end)
end

function PlayerBecomeMonsterS:setSkin(assetId)
    local action = {
        name = "eq",
        id = assetId,
    }
    self.playerState:set(S.Stores, "MonsterSkins", action)
end

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
function PlayerBecomeMonsterS:hasAsset(assetId)
    local data = Data.MonsterSkins.MonsterSkins.idData[assetId]
    if not data then return end
    local shopData = data.rewards.shop
    if shopData._type == "free" then return true end

    if shopData._type == "Group" then
        local isInGroup = self.player:GetAttribute("isInGroup")
        if isInGroup then
            return true
        else
            NotificationStreamRE:FireClient(self.player, {
                Text = ("Like game & join group to get Prize! Need to rejoin."),
            })
            return
        end
    end

    if shopData._type == "Gamepass" then
        local gpState = self.playerState:get(S.Stores, "GamePasses")
        if gpState.st[shopData.gpId] then
            return true
        else
            local PurchaseGpSE = SharedSherlock:find({"Bindable", "sync"}, {root = ReplicatedStorage, signal = "PurchaseGp"})
            if not PurchaseGpSE then return end
            PurchaseGpSE:Fire(self.playerState.player, shopData.gpId)
            return false
        end
    end

    local mSkinState = self.playerState:get(S.Stores, "MonsterSkins")
    if mSkinState.st[assetId] then return true end

    return false
end

function PlayerBecomeMonsterS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {
            "BecomeMonster",
        },
        functions = {},
    }))
end

function PlayerBecomeMonsterS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerBecomeMonsterS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerBecomeMonsterS:Destroy()
    self._maid:Destroy()
end

return PlayerBecomeMonsterS