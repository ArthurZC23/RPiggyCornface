local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Code = script:FindFirstAncestor("Code")

local module = {}

function module.run(charGuis)
    local maid = Maid.new()
    for _, desc in ipairs(Code:GetDescendants()) do
        if desc.Name == "CharController" then
            local Controller = require(desc)
            local controller = maid:Add(Controller.new(charGuis))
            charGuis:addController(controller.className, controller)
        end
    end

    return maid
end

return module