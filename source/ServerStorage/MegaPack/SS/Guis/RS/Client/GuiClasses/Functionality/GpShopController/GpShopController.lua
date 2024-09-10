local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PurchaseGpRE = ReplicatedStorage.Remotes.Events:WaitForChild("PurchaseGp")

local GpShopController = {}
GpShopController.__index = GpShopController

function GpShopController.new(template, productData, render, kwargs)
    local self = {}
    setmetatable(self, GpShopController)
	kwargs = kwargs or {}
	for productName, data in pairs(productData) do
		local productGui = template:Clone()
		local btn = productGui.Btn
		render(productGui, data, kwargs)
		btn.Activated:Connect(function()
			PurchaseGpRE:FireServer(data.id)
		end)
		productGui.Visible = true
		productGui.Parent = template.Parent
    end
    return self
end

return GpShopController