local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.handler(_, _, playerState, productData)
    local value = 1

    do
        local action = {
            name="Increment",
            value=value,
        }
        playerState:set(S.Stores, "TestMoney", action)
    end
end

return module