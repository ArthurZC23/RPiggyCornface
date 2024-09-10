local module = {}

module.idData = {
    ["1"] = {
        name = "Car",
    },
    ["2"] = {
        name = "CarSimple"
    },
    ["3"] = {
        name = "Boats"
    },
    ["4"] = {
        name = "Planes"
    },
    ["5"] = {
        name = "Helicopters"
    },
    ["6"] = {
        name = "Hoverboard"
    },
    ["7"] = {
        name = "Skate"
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module