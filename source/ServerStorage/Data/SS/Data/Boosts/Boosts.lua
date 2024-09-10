--[[
    Show the boost.
    A boost has variable duration with just one entry here.
    A boost has a fixed improvement. Meaning if there is a x1.5 speed and a x2 speed boost, they're different entries.
]]--

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {}

module.idData = {
    -- ["1"] = {
    --     name = S.SpeedBoost,
    --     thumbnail = "rbxassetid://18668121506",
    -- },
    -- ["2"] = {
    --     name = S.NoDamageBoost,
    --     thumbnail = "rbxassetid://18347932792",
    -- },
    -- ["3"] = {
    --     name = S.GhostBoost,
    --     thumbnail = "rbxassetid://18669068827",
    -- },
    -- ["4"] = {
    --     name = S.JumpBoost,
    --     thumbnail = "rbxassetid://18669090696",
    -- },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module