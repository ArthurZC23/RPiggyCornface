local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Functional = require(ServerStorage.MegaPack.SS.Functional.RS.Shared.Functional)

local ToolProto = ReplicatedStorage.Assets.Puzzles.Keys.Tools.Proto

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

for i, Key in ipairs(workspace.Map.Chapters["1"].Puzzles.Keys:GetChildren()) do
    local ToolKey = ToolProto:Clone()
    local Handle = ToolKey.Handle
    local cf0 = Handle:GetPivot()

    local Model = Key.Model:Clone()
    for _, desc in ipairs(Model:GetDescendants()) do
        if desc:IsA("WeldConstraint") or desc:IsA("Motor6D") then
            desc:Destroy()
        end
        if desc:IsA("BasePart") then
            desc.Anchored = false
            desc.Massless = true
        end
    end

    Model:PivotTo(cf0)
    Model.Parent = ToolKey

    weld(Model)
    local Pp = Model.PrimaryPart
    local WeldConstraint = Instance.new("WeldConstraint")
    WeldConstraint.Part0 = Handle
    WeldConstraint.Part1 = Pp
    WeldConstraint.Parent = Handle


    ToolKey:PivotTo(cf0 + i * 8 * cf0.RightVector)
    ToolKey.Name = Key.Name
    ToolKey.Parent = workspace.Studio.Tools
end