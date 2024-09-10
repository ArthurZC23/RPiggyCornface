local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.handler(_, _, playerState, productData)
    do
        local action = {
            name = "addSpin",
            id = productData.spinWId,
            value = productData.value,
            ux = true,
        }
        playerState:set(S.Stores, "SpinWheels", action)
    end
end

return module