local ServerStorage = game:GetService("ServerStorage")

local Functional = require(ServerStorage.MegaPack.SS.Functional.RS.Shared.Functional)

local function weldKeepAnchor(obj)
	local prev
	local parts = Functional.filter(obj:GetDescendants(), function(p)
		return
			p:IsA("BasePart") or
			p:IsA("MeshPart") or
			p:IsA("UnionOperation")
	end)
	for _, p in ipairs(parts) do
        p.Anchored = false
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
		if prev then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = prev
			weld.Part1 = p
			weld.Parent = prev
		end
		prev = p
	end
end
local Weld = workspace.Studio.Weld

for _, char in ipairs(Weld:GetChildren()) do
    local accessories = char.Accessories
    for _, modelPart in ipairs(accessories:GetChildren()) do
        weldKeepAnchor(modelPart)
        local pp = modelPart.PrimaryPart
        local WeldConstraint = Instance.new("WeldConstraint", pp)
        WeldConstraint.Part0 = pp
        WeldConstraint.Part1 = char[modelPart.Name]
    end
end