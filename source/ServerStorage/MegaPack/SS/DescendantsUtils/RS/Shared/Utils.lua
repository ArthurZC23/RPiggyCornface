local utils = {}

function utils.applyByClass(parent, func, classes)
    local descendants = parent:GetDescendants()
    for _, d in pairs(descendants) do
        if classes[d.ClassName] then func(d) end
    end
end

function utils.applyByClassIncludeParent(parent, func, classes)
    if classes[parent.ClassName] then func(parent) end
    local descendants = parent:GetDescendants()
    for _, d in pairs(descendants) do
        if classes[d.ClassName] then func(d) end
    end
end

function utils.applyByIsA(parent, func, classes)
    local descendants = parent:GetDescendants()
    local validClasses = {}
    for _, d in pairs(descendants) do
        local valid = validClasses[d.ClassName] or false
        if not valid then
            for c in pairs(classes) do
                if d:IsA(c) then
                    validClasses[d.ClassName] = true
                    valid = true
                    break
                end
            end
        end
        if valid then func(d) end
    end
end

function utils.applyByIsAIncludeParent(parent, func, classes)
    for c in pairs(classes) do
        if parent:IsA(c) then
            func(parent)
            break
        end
    end
    utils.applyByClass(parent, func, classes)
end

function utils.getByClassNoName(parent, func, classes)
    local getValues = {}
    local descendants = parent:GetDescendants()
    for _, d in pairs(descendants) do
        if classes[d.ClassName] then table.insert(getValues, func(d)) end
    end
    return getValues
end

function utils.getByClassIncludeParentNoName(parent, func, classes)
    local getValues = {}
    if classes[parent.ClassName] then table.insert(getValues, func(parent)) end
    local descendants = parent:GetDescendants()
    for _, d in pairs(descendants) do
        if classes[d.ClassName] then table.insert(getValues, func(d)) end
    end
    return getValues
end

return utils