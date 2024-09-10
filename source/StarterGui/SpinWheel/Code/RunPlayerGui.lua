local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Code = script:FindFirstAncestor("Code")

local module = {}

function module.run(playerGuis)
    local maid = Maid.new()
    for _, desc in ipairs(Code:GetDescendants()) do
        if desc.Name == "PlayerController" then
            local Controller = require(desc)
            local conntroller = maid:Add2(Controller.new(playerGuis))
            playerGuis:addController(conntroller.className, conntroller)
        end
    end

    return maid
end

return module