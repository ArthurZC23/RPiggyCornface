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

local PlayerMonsterSkinsS = {}
PlayerMonsterSkinsS.__index = PlayerMonsterSkinsS
PlayerMonsterSkinsS.className = "PlayerMonsterSkins"
PlayerMonsterSkinsS.TAG_NAME = PlayerMonsterSkinsS.className

function PlayerMonsterSkinsS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerMonsterSkinsS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleChangeSkin()
    self:handlePurchaseAsset()

    return self
end

function PlayerMonsterSkinsS:handlePurchaseAsset()
    self.network:Connect(self.PurchaseSkinRE.OnServerEvent, function(player, assetId)
        local mSkinState = self.playerState:get(S.Stores, "MonsterSkins")
        if mSkinState.st[assetId] then return end

        local data = Data.MonsterSkins.MonsterSkins.idData[assetId]
        if not data then return end

        local price = data.rewards.shop.price
        local moneyType = data.rewards.shop.moneyType

        local moneyState = self.playerState:get(S.Stores, moneyType)
        if moneyState.current < price then
            return
        end
        do
            local action = {
                name = "Decrement",
                value = price,
                ux = true,
            }
            self.playerState:set(S.Stores, moneyType, action)
        end
        do
            local action = {
                name = "add",
                id = assetId,
                ux = true,
            }
            self.playerState:set(S.Stores, "MonsterSkins", action)
        end
    end)
end

function PlayerMonsterSkinsS:handleChangeSkin()
    self.network:Connect(self.ChangeSkinRE.OnServerEvent, function(player, assetId)
        if not self:hasAsset(assetId) then return end
        self:setSkin(assetId)
    end)
end

function PlayerMonsterSkinsS:setSkin(assetId)
    local action = {
        name = "eq",
        id = assetId,
    }
    self.playerState:set(S.Stores, "MonsterSkins", action)
end

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
function PlayerMonsterSkinsS:hasAsset(assetId)
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

function PlayerMonsterSkinsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {
            "ChangeSkin", "PurchaseSkin",
        },
        functions = {},
    }))
end

function PlayerMonsterSkinsS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerMonsterSkinsS:getFields()
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

function PlayerMonsterSkinsS:Destroy()
    self._maid:Destroy()
end

return PlayerMonsterSkinsS