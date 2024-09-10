local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local localPlayer = Players.LocalPlayer

local CoinC = {}
CoinC.__index = CoinC
CoinC.className = "Coin"
CoinC.TAG_NAME = CoinC.className

function CoinC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, CoinC)

    if not self:getFields() then return end
    self:addId()
    self:handleClickDetector()

    return self
end

local IdUtils = Mod:find({"Id", "Utils"})
local idGen = IdUtils.createNumIdGenerator()
function CoinC:addId()
    self.id = idGen()
end

local Data = Mod:find({"Data", "Data"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local S = Data.Strings.Strings
local Promise = Mod:find({"Promise", "Promise"})
function CoinC:handleClickDetector()
    self.clickDetector = self._maid:Add(GaiaShared.create("ClickDetector", {
        MaxActivationDistance = 20,
        Parent = self.RootModel,
    }))

    self._maid:Add(self.clickDetector.MouseClick:Connect(function(player)
        if player ~= localPlayer then return end
        local GetCoinRE = ComposedKey.getEvent(localPlayer, "GetCoin")
        if not GetCoinRE then return end
        self._maid:Add2(Promise.fromEvent(self.playerState:getEvent(S.Stores, "Money_1", "Increment"), function(_, action)
            return action.coinId == self.id
        end)
        :andThen(function()
            self.RootModel:Destroy()
        end), "Promise")
        GetCoinRE:FireServer(self.id)
    end))
end

function CoinC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer}
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function CoinC:Destroy()
    self._maid:Destroy()
end

return CoinC