local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RigLimbs = require(script.Parent.RigLimbs)

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Functional = Mod:find({"Functional"})

local module = {}

function module.isLimb(part, rigType)
    if not RigLimbs[rigType] then
        print(string.format("Rig type %s not recognized.", rigType))
        return
    end
	local parent = part.Parent
	if not parent then return end
	local humanoid = parent:FindFirstChild("Humanoid")
	if not humanoid then return end
    return RigLimbs[rigType][part.Name]
end

function module.getHumanoidFromPart(part)
	if not (part.Parent and part.Parent.Parent) then return end
	local humanoid = part.Parent:FindFirstChild("Humanoid")
	if not humanoid then
		humanoid = part.Parent.Parent:FindFirstChild("Humanoid")
	end
	return humanoid
end

function module.checkIfPlayerIsAlive(player)
    if not (player or player.Parent) then return false end
    local char = player.Character
    if not (char or char.Parent) then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not (humanoid or humanoid.Parent or humanoid.Health > 0) then return false end
    return true
end

function module.getPlayerFromPart(part)
    local humanoid = module.getHumanoidFromPart(part)
    if (not humanoid) then return end
	local character = humanoid.Parent
	local player = Players:GetPlayerFromCharacter(character)
	return player
end

function module.getCharFromPart(part)
    local humanoid = module.getHumanoidFromPart(part)
    if (not humanoid) then return end
	local character = humanoid.Parent
	return character
end

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

function module.GetPlayerFromCharacter(_, char, kwargs)
    kwargs = kwargs or {}
    local player = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local player = Players:GetPlayerFromCharacter(char)
            return player
        end,
        keepTrying=function()
            return char.Parent
        end,
        cooldown = kwargs.cooldown or 0.1,
    })
    return player
end

function module.GetOtherPlayers(plr)
    return Functional.filter(Players:GetPlayers(), function(player)
        return player ~= plr
    end)
end

return module