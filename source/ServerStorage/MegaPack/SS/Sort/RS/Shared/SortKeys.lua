local module = {}

function module.ascending(tbl, f)
    local sortFunciton = function (t, a, b)
        return f(t, a) < f(t, b)
    end
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    table.sort(keys, function (a, b) return sortFunciton(tbl, a, b) end)
    return keys
end

function module.descending(tbl, f)
    local sortFunciton = function (t, a, b)
        return f(t, a) > f(t, b)
    end
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    table.sort(keys, function (a, b) return sortFunciton(tbl, a, b) end)
    return keys
end

return module