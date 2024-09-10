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

function module.conditions(tbl, conditions)

    local i = 0
    local j = 0
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end

    return function()
        i += 1
        local key = keys[i]
        while key do
            local allConditionsOk = true
            local conditionsResults = {} -- store variables to pass to next conditions here
            for k, cond in ipairs(conditions) do
                local ok = cond(tbl[key], conditionsResults)
                if not ok then
                    allConditionsOk = false
                    break
                end
            end

            if allConditionsOk then
                j += 1
                return i, j, key, tbl[key], conditionsResults
            end
            i += 1
            key = keys[i]
        end
    end
end

function module.FilterByIsA(tbl, className)
    local function filter(tbl_, k)
        return tbl_[k]:IsA(className)
    end
    return module.conditions(tbl, {filter})
end

return module