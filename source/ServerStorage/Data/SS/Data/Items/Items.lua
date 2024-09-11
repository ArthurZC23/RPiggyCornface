local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local BoostsData = require(Data.Boosts.Boosts)

local module = {}

module.idData = {
    -- ["1"] = {
    --     name = "SpeedPotion",
    --     viewName = "Speed Potion",
    --     boost = {
    --         id = BoostsData.nameData[S.SpeedBoost].id,
    --         duration = 30,
    --     },
    --     tags = {"SpeedPotion"},
    --     rewards = {
    --         shop = {
    --             _type = "Money",
    --             moneyType = S.Money_1,
    --             price = 30,
    --         },
    --     },
    -- },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    -- data.vpf = data.vpf or {}
    -- data.vpf.CameraAngles = data.vpf.CameraAngles or Vector3.new(0, 0, 0)
    -- data.vpf.CameraPosition = data.vpf.CameraPosition or Vector3.new(-1, 0, -1.5)
    -- data.vpf.CameraPositionOffset = data.vpf.CameraPositionOffset or Vector3.new(0, 0, 0)

    -- data.tags = data.tags or {}
    -- data.Tool = ReplicatedStorage.Assets.Items.Tools[data.name]
    -- data.Tool.CanBeDropped = false
    -- data.Tool:SetAttribute("itemId", id)
    -- for _, desc in ipairs(data.Tool.Model:GetDescendants()) do
    --     if not desc:IsA("BasePart") then continue end
    --     desc.Massless = true
    --     desc.CanCollide = false
    --     desc.Anchored = false
    --     if not desc:GetAttribute("transpDefault") then
    --         desc:SetAttribute("transpDefault", 0)
    --     end
    -- end

    -- data.model = data.Tool
    -- data.id = id
    -- data.LayoutOrder = data.LayoutOrder or tonumber(id)
    -- module.nameData[data.name] = data
end

return module