local ServerStorage = game:GetService("ServerStorage")

local Functional = require(ServerStorage.MegaPack.SS.Functional.RS.Shared.Functional)

local function weld(obj)
	local prev
	local parts = Functional.filter(obj:GetDescendants(), function(p)
		return
			p:IsA("BasePart") or
			p:IsA("MeshPart") or
			p:IsA("UnionOperation")
	end)
	for _, p in ipairs(parts) do
		if prev then
			local _weld = Instance.new("WeldConstraint")
			_weld.Part0 = prev
			_weld.Part1 = p
			_weld.Parent = prev
		end
		prev = p
	end
end
local Weld = workspace.Studio.Weld

for _, inst in ipairs(Weld:GetChildren()) do
    weld(inst)
end