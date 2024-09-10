local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})

local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local RemoveFromToxicPlayersC = {}
RemoveFromToxicPlayersC.__index = RemoveFromToxicPlayersC
RemoveFromToxicPlayersC.TAG_NAME = "RemoveFromToxicPlayers"

function RemoveFromToxicPlayersC.new(Inst)
	local self = {
        _maid = Maid.new(),
        Inst = Inst,
    }
	setmetatable(self, RemoveFromToxicPlayersC)

    if not self:getFields() then return end
    self:removeIfToxic()

	return
end

function RemoveFromToxicPlayersC:removeIfToxic()
    if Data.Players.Roles.HiddenRoles.ToxicPlayers[tostring(localPlayer.UserId)] then
        self.Inst:Destroy()
    end
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function RemoveFromToxicPlayersC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            return true
        end,
        keepTrying=function()
            return self.Inst.Parent
        end,
        cooldown=nil
    })
end

function RemoveFromToxicPlayersC:Destroy()
    self._maid:Destroy()
end



return RemoveFromToxicPlayersC