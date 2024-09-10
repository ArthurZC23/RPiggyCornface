local ServerStorage = game:GetService("ServerStorage")

local Functional = require(ServerStorage.MegaPack.SS.Functional.RS.Shared.Functional)

local function weld(inst)
	local prev
	local parts = Functional.filter(inst:GetDescendants(), function(p)
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
        p.Anchored = false
        p.CastShadow = false
		prev = p
	end
end

local function _weldDoor(door)
    local Model = door.Model
    local Skeleton = door.Skeleton
    local HingeDoor = Skeleton.HingeDoor
    weld(Model)
    local _weld = Instance.new("WeldConstraint")
    _weld.Part0 = HingeDoor
    _weld.Part1 = Model.PrimaryPart
    _weld.Parent = HingeDoor
end

local CollectionService = game:GetService("CollectionService")
local function weldDoor(door)
    if CollectionService:HasTag(door, "Door") then
        _weldDoor(door)
    elseif CollectionService:HasTag(door, "DoorGroup") then
        for _, _door in ipairs(door.Doors:GetChildren()) do
            _weldDoor(_door)
        end
    else

    end
end
local Weld = workspace.Studio.Weld

local function unweld(inst)
	for _, desc in ipairs(inst:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        for _, joint in ipairs(desc:GetJoints()) do
            joint:Destroy()
        end
	end
end

for _, inst in ipairs(Weld:GetChildren()) do
    unweld(inst)
end

for _, inst in ipairs(Weld:GetDescendants()) do
    weldDoor(inst)
end

