local module = {}

function module.ascending(tbl, f)
    local sortFunciton = function (t, a, b)
        return f(t, a) < f(t, b)
    end
    table.sort(tbl, function (a, b) return sortFunciton(tbl, a, b) end)
end

function module.descending(tbl, f)
    local sortFunciton = function (t, a, b)
        return f(t, a) > f(t, b)
    end
    table.sort(tbl, function (a, b) return sortFunciton(tbl, a, b) end)
end

return module