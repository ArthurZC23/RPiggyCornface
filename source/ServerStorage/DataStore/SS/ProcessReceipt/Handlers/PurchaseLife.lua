local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.handler(_, _, playerState, productData)
    do
        local action = {
            name="add",
            value=productData.value,
            purchased = true,
            ux = true,
        }
        playerState:set(S.Session, "Lives", action)
    end
end

return module