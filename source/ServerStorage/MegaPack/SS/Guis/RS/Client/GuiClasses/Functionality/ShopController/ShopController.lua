local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TryDeveloperPurchaseRE = ReplicatedStorage.Remotes.Events:WaitForChild("TryDeveloperPurchase")

local ShopController = {}
ShopController.__index = ShopController

function ShopController.new(template, productsData, render, kwargs)
    local self = {}
    setmetatable(self, ShopController)
	kwargs = kwargs or {}
	for productName, data in pairs(productsData) do
		local productGui = template:Clone()
		render(productGui, data, kwargs)
		local btn = productGui.Btn
		btn.Activated:Connect(function()
            TryDeveloperPurchaseRE:FireServer(data.id)
		end)
		productGui.Visible = true
		productGui.Parent = template.Parent
    end
    return self
end

return ShopController