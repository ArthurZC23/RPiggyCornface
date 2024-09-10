local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})

local module = {}

function module.weld(obj)
	local prev
	local parts = Functional.filter(obj:GetDescendants(), function(p)
		return
			p:IsA("BasePart") or
			p:IsA("MeshPart") or
			p:IsA("UnionOperation")
	end)
	for _, p in ipairs(parts) do
		if prev then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = prev
			weld.Part1 = p
			weld.Parent = prev
		end
		prev = p
		if obj:FindFirstChild("NoPhy") or p:FindFirstChild("NoPhy") then
		else
			p.Anchored = false
		end
	end	
end

function module.weldKeepAnchor(obj)
	local prev
	local parts = Functional.filter(obj:GetDescendants(), function(p)
		return
			p:IsA("BasePart") or
			p:IsA("MeshPart") or
			p:IsA("UnionOperation")
	end)
	for _, p in ipairs(parts) do
		if prev then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = prev
			weld.Part1 = p
			weld.Parent = prev
		end
		prev = p
	end	
end

function module.unweld(obj)
	for _, descendant in ipairs(obj:GetDescendants()) do
		if descendant:IsA("WeldConstraint") then descendant:Destroy() end
	end
end

return module