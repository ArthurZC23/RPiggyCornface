local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Badges = Data.Badges.Badges
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Maid = Mod:find({"Maid"})
local S = Data.Strings.Strings

local module = {}

function module.hook(self)
    local maid = Maid.new()
    -- local function update(plr)
    --     maid:Add(WaitFor.BObj(self.player, "PlayerState"):andThen(function(playerState)
    --         local role = playerState.player:GetAttribute("groupRole")
    --         if role ~= "Owner" then return end
    --         local badgeId = Badges.nameToId["Meet the Owner"]
    --         self:awardBadge(badgeId)
    --     end))
    -- end
    -- maid:Add(Players.PlayerAdded:Connect(update))
    -- for _, plr in ipairs(Players:GetPlayers()) do
    --     update(plr)
    -- end
    return maid
end

return module