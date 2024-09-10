local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local PlayerTags = Data.Players.PlayerTags
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})

local ThePlayerExitSE = SharedSherlock:find({"Bindable", "async"}, {root=ServerStorage, signal="ThePlayerExit"})
local ThePlayerReadySE = SharedSherlock:find({"Bindable", "async"}, {root=ServerStorage, signal="ThePlayerReady"})

local ThePlayerReadyRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "ThePlayerReady"})

local PlayerBindersManager = {}
PlayerBindersManager.__index = PlayerBindersManager
PlayerBindersManager.className = "PlayerBindersManager"
PlayerBindersManager.TAG_NAME = PlayerBindersManager.className

function PlayerBindersManager.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerBindersManager)

    task.defer(function()
        self:loadStartingBinders(player)
        if not player.Parent then return end
        self:firePlayerReadySignal()
    end)

    return self
end

function PlayerBindersManager:loadStartingBinders(player)
    for _, tag in ipairs(PlayerTags.tags) do
        --print("Adding tag: ", tag)
        CollectionService:AddTag(player, tag)
        if PlayerTags.asyncTags[tag] then
            --print(("async tag %s before"):format(tag))
            --local t0 = Cronos:getTime()
            local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag=tag, cooldown = 0.15})
            local playerObj = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player, cooldown = 0.15})
            if not playerObj then return end
            --local timeToBind = Cronos:getTime() - t0
            --print("Time to bind for ", tag, " ", timeToBind)
            --print(("async tag %s after"):format(tag))
        end
    end
end

function PlayerBindersManager:firePlayerReadySignal()
    ThePlayerReadySE:Fire(self.player)
    ThePlayerReadyRE:FireClient(self.player)
    self.player:SetAttribute("PlayerReady", true)
    self._maid:Add(function()
        ThePlayerExitSE:Fire(self.player)
    end)
end

function PlayerBindersManager:Destroy()
    self._maid:Destroy()
end

return PlayerBindersManager