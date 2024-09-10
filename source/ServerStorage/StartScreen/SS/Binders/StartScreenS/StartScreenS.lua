local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local StartScreenS = {}
StartScreenS.__index = StartScreenS
StartScreenS.className = "StartScreen"
StartScreenS.TAG_NAME = StartScreenS.className

local function createRemotes()
    local eventsNames = {"StartScreenPlay",}
    local functionsNames = {}
    GaiaServer.createRemotes(ReplicatedStorage, {
        events = eventsNames,
        functions = functionsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        StartScreenS[("%sRE"):format(eventName)] = ReplicatedStorage.Remotes.Events[eventName]
    end
    for _, funcName in ipairs(functionsNames) do
        StartScreenS[("%sRF"):format(funcName)] = ReplicatedStorage.Remotes.Functions[funcName]
    end
end
createRemotes()

function StartScreenS.new(player)
    if not Data.Studio.Studio.startScreen then return end
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, StartScreenS)

    if not self:getFields() then return end
    self:handleEvents()

    return self
end

function StartScreenS:handleEvents()
    self._maid:Add(StartScreenS.StartScreenPlayRE.OnServerEvent:Connect(function(plr)
        if self.player ~= plr then return end
        CollectionService:RemoveTag(self.player, StartScreenS.TAG_NAME)
    end))
end

function StartScreenS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerCharacterSpawner", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function StartScreenS:Destroy()
    self._maid:Destroy()
end

return StartScreenS