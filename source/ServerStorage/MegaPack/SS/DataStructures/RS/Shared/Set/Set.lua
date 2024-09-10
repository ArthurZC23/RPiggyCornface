local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local Set = {}
Set.__index = Set
Set.className = "Set"

function Set.new(tbl, kwargs)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Set)

    assert(kwargs.createSetFrom, "Set need createSetFrom parameter.")
    self.set = self[("createSetFrom%s"):format(kwargs.createSetFrom)](self, tbl)

    return self
end

function Set.createEmptySet()
    return Set.new({}, {
        createSetFrom="Keys"
    })
end

function Set:createSetFromKeys(tbl)
    if not tbl then return {} end
    local set = {}
    for k in pairs(tbl) do
        set[k] = true
    end
    return set
end

function Set:createSetFromValues(tbl)
    if not tbl then return {} end
    local set = {}
    for _, v in pairs(tbl) do
        set[v] = true
    end
    return set
end

function Set:add(value)
    self.set[value] = true
end

function Set:remove(value)
    self.set[value] = nil
end

function Set.union(setA, setB)
    local union = {}
    for k in pairs(setA.set) do
        union.set[k] = true
    end
    for k in pairs(setB.set) do
        union.set[k] = true
    end
    return Set.new(union, {
        createSetFrom="Keys"
    })
end

function Set.size(set)
    return TableUtils.len(set)
end

function Set.difference(setA, setB)
    local diff = TableUtils.deepCopy(setA.set)
    for k in pairs(setB.set) do
        diff[k] = nil
    end
    -- print("debug set")
    -- print("Set A")
    -- setA:print()
    -- print("----------------")
    -- print("Set B")
    -- setB:print()
    local setC = Set.new(diff, {
        createSetFrom="Keys"
    })
    -- print("----------------")
    -- print("Set C")
    -- setC:print()
    return setC
end

function Set.intersection(setA, setB)
    local intersection = {}
    for k in pairs(setA.set) do
        intersection[k] = setB.set[k]
    end
    return Set.new(intersection, {
        createSetFrom="Keys"
    })
end

function Set.symmetricDifference(setA, setB)
    local union = Set.union(setA, setB)
    local intersection = Set.intersection(setA, setB)
    local delta = Set.difference(union, intersection)
    return delta
end

function Set:print()
    for k in pairs(self.set) do
        print(k)
    end
end

function Set:Destroy()
    self._maid:Destroy()
end

return Set