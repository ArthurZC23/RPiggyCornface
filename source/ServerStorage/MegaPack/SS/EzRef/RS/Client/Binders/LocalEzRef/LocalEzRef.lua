local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local LocalEzRef = {}
LocalEzRef.__index = LocalEzRef
LocalEzRef.className = "LocalEzRef"
LocalEzRef.TAG_NAME = LocalEzRef.className

local function findReferences(inst, refData)
    local ReferencesFId = refData:FindFirstChild("ReferencesFId") -- Locate a specific folder, not the first one
    local ReferencesF
    repeat
        local candidate = SharedSherlock:find({"FindFirst", "AncestorChild"}, {inst=inst, ancestorChildName="References"})
        if not candidate then return end
        if ReferencesFId and candidate:FindFirstChild(ReferencesFId) then
            ReferencesF = candidate
        else
            ReferencesF = candidate
        end
    until ReferencesF
    return ReferencesF
end

-- This works with cloned guis
function LocalEzRef.new(inst)
    local refData = inst.RefData
    local DisabledV = refData:FindFirstChild("Disabled")
    if DisabledV and DisabledV.Value then return end

    local self = {
        _maid = Maid.new()
    }
    setmetatable(self, LocalEzRef)

    local ReferencesF = findReferences(inst, refData)
    if not ReferencesF then return end

    local refName = ("%s"):format(refData.RefName.Value)
    if not self:findRef(inst, refData, refName, ReferencesF) then
        self:createObjectValueReference(inst, refName, ReferencesF)
    end
    return self
end

function LocalEzRef:findRef(inst, refData, refName, ReferencesF)
    local clonable = refData:FindFirstChild("Clonable")
    local ref = ReferencesF:FindFirstChild(refName)

    if ref then
        if clonable then return true end
        if inst == ref.Value then return true end -- May happen when copying stuff from starter gui to playergui. Only happens when LocalEzRef is a server binder.
        error((
            "Obj %s is trying to add itself as"..
            " a reference using refName %s which is already taken by %s.")
            :format(inst:GetFullName(), refName, ref.Value:GetFullName())
        )
    end

    return false
end

function LocalEzRef:createObjectValueReference(inst, refName, ReferencesF)
    self.ref = self._maid:Add(Instance.new("ObjectValue"))
    self.ref.Name = refName
    self.ref.Value = inst
    self.ref.Parent = ReferencesF
end

function LocalEzRef:Destroy()
    self._maid:Destroy()
end

return LocalEzRef