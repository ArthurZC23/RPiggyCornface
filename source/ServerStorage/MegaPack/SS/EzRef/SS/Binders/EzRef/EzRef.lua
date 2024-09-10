local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Functional = Mod:find({"Functional"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

-- EzRef should be server side

local EzRef = {}
EzRef.__index = EzRef
EzRef.className = "EzRef"
EzRef.TAG_NAME = EzRef.className

local function findReferences(inst, refData)
    local ReferencesFId = refData:GetAttribute("ReferencesFId") -- Locate a specific folder, not the first one
    local ReferencesF
    local descendant = inst
    repeat
        local candidate = SharedSherlock:find({"FindFirst", "AncestorChild"}, {inst=descendant, ancestorChildName="References"})
        if not candidate then return end
        descendant = candidate.Parent
        if ReferencesFId == nil then
            ReferencesF = candidate
        elseif ReferencesFId and candidate:GetAttribute("ReferencesFId") == ReferencesFId then
            ReferencesF = candidate
        end
    until ReferencesF
    return ReferencesF
end

function EzRef.new(inst)
    local self = {
        _maid = Maid.new(),
        refs = {}
    }
    setmetatable(self, EzRef)

    if inst:FindFirstAncestor("Archive") then return end

    self._maid:Add(inst.AncestryChanged:Connect(function(_, parent)
        if parent == nil then return end
        self._maid:Remove("DestroyRefs")
        self._maid:Add(self:addAllRefs(inst), nil, "DestroyRefs")
    end))

    self._maid:Add(inst.ChildAdded:Connect(function(child)
        if child.Name == "RefData" then
            self:addRef(inst, child)
        end
    end))
    self._maid:Add(self:addAllRefs(inst), nil, "DestroyRefs")

    return self
end

function EzRef:addAllRefs(inst)
    local refs = Functional.filter(inst:GetChildren(), function(child)
        return child.Name == "RefData"
    end)

    for _, refData in ipairs(refs) do
        self:addRef(inst, refData)
    end
    return function()
        for _, ref in ipairs(self.refs) do
            ref:Destroy()
        end
    end
end

function EzRef:addRef(inst, refData)
    local DisabledV = refData:FindFirstChild("Disabled")
    if DisabledV and DisabledV.Value then return end

    local ReferencesF = findReferences(inst, refData)
    if not ReferencesF then return end

    local refName = ("%s"):format(refData.RefName.Value)
    if not self:findRef(inst, refData, refName, ReferencesF) then
        self:createObjectValueReference(inst, refName, ReferencesF)
    end
end

function EzRef:findRef(inst, refData, refName, ReferencesF)
    local clonable = refData:FindFirstChild("Clonable")
    local ref = ReferencesF:FindFirstChild(refName)

    if ref then
        if clonable then return true end
        if inst == ref.Value then return true end -- May happen when copying stuff from starter gui to playergui. Only happens when EzRef is a server binder.
        error((
            "Obj %s is trying to add itself as"..
            " a reference using refName %s which is already taken by %s.")
            :format(inst:GetFullName(), refName, ref.Value:GetFullName())
        )
    end

    return false
end

function EzRef:createObjectValueReference(inst, refName, ReferencesF)
    local ref = GaiaShared.create("ObjectValue", {
        Name = refName,
        Value = inst,
        Parent = ReferencesF,
    })
    table.insert(self.refs, ref)
end

function EzRef:Destroy()
    self._maid:Destroy()
end

return EzRef