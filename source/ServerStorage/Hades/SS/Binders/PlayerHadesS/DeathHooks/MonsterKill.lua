local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.handler(hades, kwargs)
    do
        local action = {
            name = "remove",
            value = 1
        }
        hades.playerState:set(S.Session, "Lives", action)
    end

    hades.DeathHookRE:FireClient(hades.player, script.Name, {})
    return Promise.fromEvent(hades.DeathHookRE.OnServerEvent, function(plr, deathCause)
        if (plr ~= hades.player) or (deathCause ~= script.Name) then return false end
        return true
    end)
    :andThen(function()
        -- return Promise.delay(0.2)
    end)
    :timeout(30)
end

return module