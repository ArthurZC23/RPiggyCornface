local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GameData = Data.Game.Game

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

return function ()
    if GameData.developer.isGroup and GameData.developer.id then
        Promise.try(function ()
            local ok, groupData = pcall(function()
                return GroupService:GetGroupInfoAsync(GameData.developer.id)
            end)
            if not ok then
                local err = groupData
                error(("Failed to GetGroupInfoAsync.\n%s"):format(err))
            end
            local action = {
                name = "setDevGroupData",
                groupData = groupData,
            }
            gameState:set("Session", "DevGroup", action)
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    else

    end
end