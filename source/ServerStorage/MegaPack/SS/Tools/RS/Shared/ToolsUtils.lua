local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local module = {}

function module.getPlayerFromTool(tool)
	local backpack = tool:FindFirstAncestorOfClass("Backpack")
    if backpack then
        local player = backpack:FindFirstAncestorOfClass("Player")
        return player
    end
    local character = tool:FindFirstAncestorOfClass("Model")
    local player = Players:GetPlayerFromCharacter(character)
    if player then return player end
end

function module.getToolPlayerAndCharAsync(tool)
    return WaitFor.GetAsync({
        getter = function()
            local res = {}
            res.player = module.getPlayerFromTool(tool)
            if not res.player then return end

            local toolCharUid = tool:GetAttribute("charUid")
            res.char = res.player.Character
            if not (res.char and res.char.Parent) then return end

            local charUid = res.char:GetAttribute("uid")
            if charUid ~= toolCharUid then return end

            return res
        end,
        keepTrying = function()
            return tool.Parent
        end,
    })
end

function module.isToolEquipped(tool)
    local parent = tool.Parent
    if not parent then return false end
    return CollectionService:HasTag(parent, "PlayerCharacter")
end

return module