local ServerStorage = game:GetService("ServerStorage")

local Functional = require(ServerStorage.MegaPack.SS.Functional.RS.Shared.Functional)

local function unweld(obj)
	for _, desc in ipairs(obj:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        for _, joint in ipairs(desc:GetJoints()) do
            joint:Destroy()
        end
	end
    for _, desc in ipairs(obj:GetDescendants()) do
        if not (desc:IsA("WeldConstraint") or desc:IsA("Motor6D")) then continue end
        desc:Destroy()
	end
end
local Weld = workspace.Studio.Weld

for _, inst in ipairs(Weld:GetDescendants()) do
    unweld(inst)
end
