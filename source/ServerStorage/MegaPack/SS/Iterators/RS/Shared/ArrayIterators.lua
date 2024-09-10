local module = {}

local function _standardIterator(tbl, keys)
    local i = 0
    return function ()
        i = i + 1
        if keys[i] then
            return i, keys[i], tbl[keys[i]]
        end
    end
end

function module.sort(tbl, sortFunction)
    -- sort function (tbl, a, b) return t[a] < t[b] end (ascending example) -- a and b are keys
    sortFunction = sortFunction or function (tbl, a, b) return tbl[a] < tbl[b] end
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    table.sort(keys, function (a, b) return sortFunction(tbl, a, b) end)
    return _standardIterator(tbl, keys)
end

function module.allow(tbl, filterFunc)
    local keys = {}
    for k in pairs(tbl) do
        if filterFunc(tbl, k) then
            table.insert(keys, k)
        end
    end
    return _standardIterator(tbl, keys)
end

function module.ignore(tbl, filterFunc)
    local keys = {}
    for k in pairs(tbl) do
        if not filterFunc(tbl, k) then
            table.insert(keys, k)
        end
    end
    return _standardIterator(tbl, keys)
end

function module.filterByClass(tbl, className)
    local function filter(tbl, k)
        return tbl[k].ClassName == className
    end
    return module.allow(tbl, filter)
end

function module.filterByIsA(tbl, className)
    local function filter(tbl_, k)
        return tbl_[k]:IsA(className)
    end
    return module.allow(tbl, filter)
end

function module.complement(tbl, filterIter)
    local keys = {}
    local filteredKeys = {}
    for _, k, _ in filterIter do
        filteredKeys[k] = true
    end
    for k in pairs(tbl) do
        if not filteredKeys[k] then table.insert(keys, k) end
    end
    return _standardIterator(tbl, keys)
end

function module.conditions(array, conditions)

    local i = 0
    local j = 0
    local size = #array

    return function()
        i += 1
        while i <= size do
            local allConditionsOk = true
            local conditionsResults = {} -- store variables to pass to next conditions here
            for k, cond in ipairs(conditions) do
                local ok = cond(array[i], conditionsResults)
                if not ok then
                    allConditionsOk = false
                    break
                end
            end

            if allConditionsOk then
                j += 1
                return i, j, array[i], conditionsResults
            end
            i += 1
        end
    end
end

function module.FilterByIsA(array, className)
    local function filter(v)
        return v:IsA(className)
    end
    return module.conditions(array, {filter})
end

return module