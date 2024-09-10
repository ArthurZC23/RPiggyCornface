local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function handler(playerState)
    local maid = Maid.new()
    local TAG = "CharSpeedGp"
    local action = {
        name = "addTag",
        tag = TAG,
    }
    playerState:set("Session", "CharTags", action)

    local char = playerState.player.Character
    if char and char.Parent then
        char:AddTag(char, TAG)
    end
    return maid
end

return handler