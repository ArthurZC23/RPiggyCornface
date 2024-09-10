local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Badges = Data.Badges.Badges
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Maid = Mod:find({"Maid"})

local module = {}

function module.hook(self)
    local maid = Maid.new()
    maid:Add(WaitFor.BObj(self.player, "PlayerState"):andThen(function(playerState)
        maid:Add(playerState.afterSaveSignal:Connect(function()
            -- Only give badge after first save. This player cannot return nil anymore when getting store data.
            local badgeId = Badges.nameToId["Welcome"]
            if badgeId then
                self:awardBadge(badgeId)
            end
        end))
    end))
    return maid
end

return module