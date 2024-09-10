local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})

local module = {}

module.getInitialSession = function()
    return {
        DevProducts = {},
        GamePasses = {},
        DevGroup = {},
        -------------------
        _Game = {
            chapter = "1",
        },
        Monster = {
            _type = "npc",
            skinId = "1",
            t1 = nil,
        },
    }
end

return module