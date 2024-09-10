local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local Functional = Mod:find({"Functional"})

local module = {}

function module.getDescendantsDepthFirst(inst, cb, path)
    path = path or {}
    for _, child in ipairs(inst:GetChildren()) do
        local _path = TableUtils.deepCopy(path)
        table.insert(_path, child.Name)
        cb(_path, child)
        module.getDescendantsDepthFirst(child, cb, _path)
    end
end

function module.getPointSamplerInstanceVolume(inst, seed)
    local rx, ry, rz
    if seed then
        rx, ry, rz = Random.new(seed), Random.new(seed), Random.new(seed)
    else
        rx, ry, rz = Random.new(), Random.new(), Random.new()
    end
    return function()
        return inst.Position + inst.Size * Vector3.new(0.5 - 1 * rx:NextNumber(), 0.5 - 1 * ry:NextNumber(), 0.5 - 1 * rz:NextNumber())
    end
end

function module.getPointSamplerInstanceSurface(inst, seed)
    local rx, ry, rz, rFace
    if seed then
        rx, ry, rz, rFace = Random.new(seed), Random.new(seed), Random.new(seed), Random.new(seed)
    else
        rx, ry, rz, rFace = Random.new(), Random.new(), Random.new(), Random.new()
    end
    local faceHandlers = {
        function()
            return inst.Position + inst.Size * Vector3.new(0.5, 0.5 - 1 * ry:NextNumber(), 0.5 - 1 * rz:NextNumber())
        end,
        function()
            return inst.Position + inst.Size * Vector3.new(-0.5, 0.5 - 1 * ry:NextNumber(), 0.5 - 1 * rz:NextNumber())
        end,
        function()
            return inst.Position + inst.Size * Vector3.new(0.5 - 1 * rx:NextNumber(), 0.5, 0.5 - 1 * rz:NextNumber())
        end,
        function()
            return inst.Position + inst.Size * Vector3.new(0.5 - 1 * rx:NextNumber(), -0.5, 0.5 - 1 * rz:NextNumber())
        end,
        function()
            return inst.Position + inst.Size * Vector3.new(0.5 - 1 * rx:NextNumber(), 0.5 - 1 * ry:NextNumber(), 0.5)
        end,
        function()
            return inst.Position + inst.Size * Vector3.new(0.5 - 1 * rx:NextNumber(), 0.5 - 1 * ry:NextNumber(), -0.5)
        end,
    }
    return function()
        return faceHandlers[rFace:NextInteger(1, 6)]()
    end
end

function module.hasTransparency(inst)
    return inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture")
end

function module.clearChildren(inst)
    for _, child in ipairs(inst:GetChildren()) do
        child:Destroy()
    end
end

function module.clearChildrenWhichAre(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    for _, child in ipairs(inst:GetChildren()) do
        for _, className in ipairs(classNames) do
            if child:IsA(className) then child:Destroy() end
        end
    end
end

function module.clearChildrenWhichAreNot(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    for _, child in ipairs(inst:GetChildren()) do
        for _, className in ipairs(classNames) do
            if child:IsA(className) then continue end
            child:Destroy()
        end
    end
end

function module.clearDescendantsWhichAre(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    for _, desc in ipairs(inst:GetDescendants()) do
        for _, className in ipairs(classNames) do
            if desc:IsA(className) then
                desc:Destroy()
            end
        end
    end
end

function module.clearDescendantsWhichAreNot(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    for _, desc in ipairs(inst:GetDescendants()) do
        for _, className in ipairs(classNames) do
            if desc:IsA(className) then continue end
            desc:Destroy()
        end
    end
end

function module.getChildrenWhichAre(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    return Functional.filter(
        inst:GetChildren(),
        function(child)
            for _, className in ipairs(classNames) do
                if child:IsA(className) then return true end
            end
            return false
        end
    )
end

function module.getChildrenWhichAreNot(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    return Functional.filter(
        inst:GetChildren(),
        function(child)
            for _, className in ipairs(classNames) do
                if child:IsA(className) then return false end
            end
            return true
        end
    )
end

function module.getDescendantsWhichAre(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    return Functional.filter(
        inst:GetDescendants(),
        function(desc)
            for _, className in ipairs(classNames) do
                if desc:IsA(className) then return true end
            end
        end
    )
end

function module.getDescendantsWhichAreNot(inst, classNames)
    if typeof(classNames) ~= "table" then classNames = {classNames} end
    return Functional.filter(
        inst:GetDescendants(),
        function(desc)
            for _, className in ipairs(classNames) do
                if desc:IsA(className) then return false end
            end
            return true
        end
    )
end

function module.getChildrenConditional(inst, condition, kwargs)
    kwargs = kwargs or {}
    return Functional.filter(
        inst:GetChildren(),
        function(child)
            return condition(child, kwargs)
        end
    )
end

function module.getDescendantsConditional(inst, condition, kwargs)
    kwargs = kwargs or {}
    return Functional.filter(
        inst:GetDescendants(),
        function(desc)
            return condition(desc, kwargs)
        end
    )
end

function module.setDescendantsProps(baseInst, props, conditions, kwargs)
    for _, desc in ipairs(baseInst:GetDescendants()) do
        local res = {}
        for _, cond in ipairs(conditions) do
            res = cond(desc, res, props, baseInst, kwargs)
            if not res then break end
        end
        if not res then continue end
        TableUtils.setInstance(desc, props)
    end
end

function module.showModel(baseInst)
    module.setDescendantsProps(
        baseInst,
        {Transparency = 0},
        {
            function(desc, res)
                if desc:IsA("BasePart") then
                    return res
                end
            end
        }
    )
end

function module.removeTagsFromModelAndDescendants(baseInst)
    for _, tag in ipairs(CollectionService:GetTags(baseInst)) do
        CollectionService:RemoveTag(baseInst, tag)
    end
    for _, desc in ipairs(baseInst:GetDescendants()) do
        for _, tag in ipairs(CollectionService:GetTags(desc)) do
            CollectionService:RemoveTag(desc, tag)
        end
    end
end

function module.hideModel(baseInst)
    for _, desc in ipairs(baseInst:GetDescendants()) do
        if
            desc:IsA("BasePart")
            or desc:IsA("Decal")
            or desc:IsA("Texture")
        then
            desc.Transparency = 1
        elseif
            desc:IsA("ParticleEmitter")
            or desc:IsA("Beam")
            or desc:IsA("Trail")
        then
            desc.Enabled = false
        end
    end
end

function module.getRootLeafPath(root, leaf, map)
    assert(root:IsA("Instance"), ("%s is not an instance."):format(root:GetFullName()))
    assert(leaf:IsA("Instance"), ("%s is not an instance."):format(leaf:GetFullName()))
    local path = {}
    local parent = leaf
    while parent and parent ~= root do
        local val = parent
        if map then val = map(val) end
        table.insert(path, val)
        parent = parent.Parent
    end
    path = TableUtils.reverse(path)
	return path
end

function module.getRootLeafPathNames(root, leaf)
    return module.getRootLeafPath(root, leaf, function(inst) return inst.Name end)
end

function module.getRootLeafPathNamesDropRoot(root, leaf)
    return module.getRootLeafPath(root, leaf, function(inst)
        if inst == root then return end
        return inst.Name end
    )
end


return module