local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SinglePurchasesData = Data.SinglePurchases.SinglePurchases

local RootF = script.Parent
local Handlers = require(RootF:WaitForChild("SinglePurchaseHandlers"):WaitForChild("Handlers"))

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerSinglePurchaseS = {}
PlayerSinglePurchaseS.__index = PlayerSinglePurchaseS
PlayerSinglePurchaseS.className = "PlayerSinglePurchase"
PlayerSinglePurchaseS.TAG_NAME = PlayerSinglePurchaseS.className

function PlayerSinglePurchaseS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerSinglePurchaseS)

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end

    playerState:getEvent(S.Stores, "SinglePurchases", "startSinglePurchase"):Connect(function(state, action)
        self:handleSinglePurchase(action.id)
    end)

    local state = playerState:get(S.Stores, "SinglePurchases")
    for id, data in pairs(state) do
        if data.status == SinglePurchasesData.Status.Started then
            self:handleSinglePurchase(id)
        end
    end

    return self
end

function PlayerSinglePurchaseS:handleSinglePurchase(id)
    local data = SinglePurchasesData.idToData[id]
    local name = data.name

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=self.player})
    if not playerState then return end

    Handlers[name](playerState)
    --print(id, typeof(id))
    do
        local action = {
            name="finishSinglePurchase",
            id=id,
        }
        playerState:set(S.Stores, "SinglePurchases", action)
    end
end

function PlayerSinglePurchaseS:Destroy()
    self._maid:Destroy()
end

return PlayerSinglePurchaseS