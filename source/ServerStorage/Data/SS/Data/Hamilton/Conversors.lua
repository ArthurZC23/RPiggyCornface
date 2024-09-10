local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {}

module.conversors = {
    -- [S.SellingStation] = {
    --     Source=S.Money_1,
    --     Sink=S.Points,
    --     BaseExchange = 0.5,
    -- }
}
module = Mts.makeEnum("Conversors", module)

return module