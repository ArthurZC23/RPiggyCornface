local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Maid = Mod:find({"Maid"})

local module = {}

-- For instances that require ezref before parenting, like cloned guis
function module.runEzRef(RootInstance)
    local maid = Maid.new()

    local ReferencesF = RootInstance.References
    for _, desc in ipairs(RootInstance:GetDescendants()) do
        if not (desc.Name == "RefName" and desc:IsA("StringValue")) then continue end
        local RefName = desc
        local inst = RefName.Parent.Parent
        local refName = ("%s"):format(RefName.Value)

        maid:Add2(GaiaShared.create("ObjectValue", {
            Name = refName,
            Value = inst,
            Parent = ReferencesF,
        }))
    end

    return maid
end

function module.addEzRef(inst, ref)
    local RefData = GaiaShared.create("Folder", {Name = "RefData", Parent = inst})
    GaiaShared.create("StringValue", {
        Name = "RefName",
        Value = ref,
        Parent = RefData
    })
    CollectionService:AddTag(inst, "EzRef")
    return function()
        module.removeEzRef(inst)
    end
end

function module.removeEzRef(inst)
    CollectionService:RemoveTag(inst, "EzRef")
    local refData = inst:FindFirstChild("RefData")
    if refData then
        refData:Destroy()
    end
end

local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
function module.getCompositeEzRef(root, array)
    local lastInst = nil
    for _, refName in ipairs(array) do
        local inst
        if lastInst then
            inst = lastInst
        else
            inst = root
        end
        local nextInst = SharedSherlock:find({"EzRef", "GetSync"}, {inst=inst, refName=refName})
        if not nextInst then return end
        lastInst = nextInst
    end
    return lastInst
end

return module