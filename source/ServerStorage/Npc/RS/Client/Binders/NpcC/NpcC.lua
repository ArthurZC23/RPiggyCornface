local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local NpcC = {}
NpcC.__index = NpcC
NpcC.className = "Npc"
NpcC.TAG_NAME = NpcC.className

function NpcC.new(npc)
    if not npc:IsDescendantOf(workspace) then return end
    local self = {
        _maid = Maid.new(),
        npc = npc,
        npcId = npc:GetAttribute("NpcId"),
    }
    setmetatable(self, NpcC)

    if not self:getFields() then return end

    return self
end

function NpcC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()

            return true
        end,
        keepTrying=function()
            return self.npc.Parent
        end,
    })
    return ok
end

function NpcC:Destroy()
    self._maid:Destroy()
end

return NpcC