local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local PlayerMoney_1SpawnerC = {}
PlayerMoney_1SpawnerC.__index = PlayerMoney_1SpawnerC
PlayerMoney_1SpawnerC.className = "PlayerMoney_1Spawner"
PlayerMoney_1SpawnerC.TAG_NAME = PlayerMoney_1SpawnerC.className

function PlayerMoney_1SpawnerC.new(player)
    if player ~= localPlayer then return end
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerMoney_1SpawnerC)

    if not self:getFields() then return end
    self:handleSpawn()

    return self
end


local Promise = Mod:find({"Promise", "Promise"})
local Sampler = Mod:find({"Math", "Sampler"})
function PlayerMoney_1SpawnerC:handleSpawn()
    local Money_1Spawns = workspace.Map.Chapters["1"].InstanceSpawns.Money_1.Spawns
    local sampler = Sampler.new()
    local function update(state)
        local maid = self._maid:Add2(Maid.new(), "handleSpawn")
        local candidates = Money_1Spawns:GetChildren()
        local numCoins = 20
        if RunService:IsStudio() then
            numCoins = #candidates
        end
        local selectedIdxs = sampler:sampleNoRepetition(#candidates, numCoins)
        local ModelF = maid:Add2(GaiaShared.create("Folder", {
            Name = "Models",
            Parent = workspace.Map.Chapters["1"].InstanceSpawns.Money_1,
        }))
        -- local clickCoins = {}
        -- maid:Add2(function()
        --     for _, Model in ipairs(clickCoins) do
        --         if Model.Parent == nil then continue end
        --         Model:Destroy()
        --     end
        --     clickCoins = nil
        -- end)
        for idx in pairs(selectedIdxs) do
            local Money_1Spawn = candidates[idx]
            local Model = ReplicatedStorage.Assets.Money.Money_1.Coin1:Clone()
            Model:AddTag("Coin")
            Model:PivotTo(Money_1Spawn:GetPivot())
            -- maid:Add2(Promise.fromEvent(Model.Destroying)
            -- :andThen(function()
            --     local _idx = table.find(clickCoins, Model)
            --     table.remove(clickCoins, _idx)
            -- end))
            -- table.insert(clickCoins, Model)
            Model.Parent = ModelF
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "_Game", "reset"):Connect(update))
    local state = self.playerState:get(S.Session, "_Game")
    update(state)
end

function PlayerMoney_1SpawnerC:getFields()
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

function PlayerMoney_1SpawnerC:Destroy()
    self._maid:Destroy()
end

return PlayerMoney_1SpawnerC