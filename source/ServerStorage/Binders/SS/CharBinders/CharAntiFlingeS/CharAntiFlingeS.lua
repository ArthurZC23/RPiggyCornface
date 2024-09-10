local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local CharAntiFlingeS = {}
CharAntiFlingeS.__index = CharAntiFlingeS
CharAntiFlingeS.className = "CharAntiFlinge"
CharAntiFlingeS.TAG_NAME = CharAntiFlingeS.className

function CharAntiFlingeS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharAntiFlingeS)

    if not self:getFields() then return end
    -- self:createRemotes()
    -- self:setPlayerNetwork()
    self:handleFlinge()

    return self
end

local BigBen = Mod:find({"Cronos", "BigBen"})

function CharAntiFlingeS:handleFlinge()
    self._maid:Add(BigBen.every(0.5, "Heartbeat", "time_", true):Connect(function()
        local hrp = self.charParts.hrp
        local cf = self.char:GetPivot()
        local pos = hrp.Position
        if pos.Y <= 500 then
            self._maid:Remove("SolvingFlinge")
            return
        end

        local prop = self.charProps.props[hrp]
        if not prop then return end

        local maid = self._maid:Add2(Maid.new(), "SolvingFlinge")
        maid:Add(function()
            prop:removeCause("Anchored", "Flinge")
        end)
        prop:set("Anchored", "Flinge", true)
        maid:Add(BigBen.every(1, "Stepped", "frame", true):Connect(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
        end))
        self.char:PivotTo(cf.Rotation + pos * Vector3.new(1, 0, 1) + 490 * Vector3.yAxis)

        -- Finish all interactions
    end))
end

function CharAntiFlingeS:initRpValues()
    local state = self.playerState:get(S.Stores, "Rp")
    local name = state.name
    if name == "" then
        name = self.player.Name
    end
    local bio = state.bio
    local action = {
        name = "setNameBio",
        value = {name = name, bio = bio},
    }
    self.playerState:set(S.Stores, "Rp", action)
end

function CharAntiFlingeS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {},
        functions = {},
    }))
end

function CharAntiFlingeS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local Players = game:GetService("Players")
function CharAntiFlingeS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            local bindersData = {
                {"PlayerState", self.player},
                {"CharParts", self.char},
                {"CharProps", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAntiFlingeS:Destroy()
    self._maid:Destroy()
end

return CharAntiFlingeS