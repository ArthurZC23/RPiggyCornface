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
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

local PlayerTeamS = {}
PlayerTeamS.__index = PlayerTeamS
PlayerTeamS.className = "PlayerTeam"
PlayerTeamS.TAG_NAME = PlayerTeamS.className

function PlayerTeamS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerTeamS)

    if not self:getFields() then return end
    self:setInitialTeam()

    self:createRemotes()
    self:setPlayerNetwork()
    self:handleTeamChange()

    return self
end

function PlayerTeamS:setInitialTeam()
    if Data.Studio.Studio.initialTeam then
        self.player:SetAttribute("team", Data.Studio.Studio.initialTeam)
    else
        self.player:SetAttribute("team", "Lobby")
    end
end

function PlayerTeamS:handleTeamChange()
    local function update()
        -- local maid = self._maid:Add2(Maid.new(), "handleTeamChangeUpdate")
        -- local team = self.player:GetAttribute("team")
        -- local char = self.player.Character
        -- if not (char and char.Parent) then return end
        -- maid:Add2(WaitFor.BObj(char, "CharHades"):andThen(function(charHades)
        --     charHades.KillSignalSE:Fire("ChangeTeam", {team = team})
        -- end))

        -- print("Test this")
        -- if team == "monster" then
        --     -- maid:Add2(self:handleIncreaseMonsterTimeWhileMonster())
        --     maid:Add2(self:handleMonsterTimer())
        -- else

        -- end
    end
    self._maid:Add2(self.player:GetAttributeChangedSignal("team"):Connect(update))
    local team = self.player:GetAttribute("team")
    -- if team == "MatchMonster" then
    --     update()
    -- end
end

function PlayerTeamS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {
            -- "BecomeMonster",
        },
        functions = {},
    }))
end

function PlayerTeamS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerTeamS:getFields()
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

function PlayerTeamS:Destroy()
    self._maid:Destroy()
end

return PlayerTeamS