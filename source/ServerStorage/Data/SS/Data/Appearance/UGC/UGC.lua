local module = {
    _serverOnly = true,
}

module.ugc = {}

module.ugc["1"] = {
    uri = "16030184805",
}

module.ugc["2"] = {
    uri = "18266944770",
}

module.ugc["3"] = {
    uri = "18266796513",
}

module.ugc["4"] = {
    uri = "18119458107",
}

module.ugc["5"] = {
    uri = "18251323866",
}

module.ugc["6"] = {
    uri = "18181041946",
}

module.ugc["7"] = {
    uri = "18177258620",
}

module.ugc["8"] = {
    uri = "18176181919",
}

module.ugc["9"] = {
    uri = "17782927832",
}

module.ugc["10"] = {
    uri = "16070338263",
}

module.ugc["11"] = {
    uri = "17156434078",
}

module.ugc["12"] = {
    uri = "18256240680",
}

module.ugc["13"] = {
    uri = "18271596742",
}

module.ugc["14"] = {
    uri = "18256243240",
}

module.ugc["15"] = {
    uri = "18271593150",
}

module.ugc["16"] = {
    uri = "18200699717",
}

module.ugc["17"] = {
    uri = "18255745635",
}

module.ugc["18"] = {
    uri = "18200732255",
}

module.ugc["19"] = {
    uri = "18266980429",
}

module.ugc["20"] = {
    uri = "17718488048",
}

module.ugc["21"] = {
    uri = "17847071462",
}

module.ugc["22"] = {
    uri = "18247893204",
}

module.ugc["23"] = {
    uri = "18251319855",
}

module.ugc["24"] = {
    uri = "18385254758",
}

module.ugc["25"] = {
    uri = "18221705493",
}

module.ugc["26"] = {
    uri = "17387742659",
}

module.ugc["27"] = {
    uri = "18374780830",
}

module.ugc["28"] = {
    uri = "18423452752",
}

module.ugc["29"] = {
    uri = "18386507963",
}

module.ugc["30"] = {
    uri = "17654966497",
}

module.ugc["31"] = {
    uri = "18114034766",
}


local validationSet = {}
for id, data in pairs(module.ugc) do
    if validationSet[data.uri] ~= nil then
        warn(("Asset %s is repeated."):format(data.uri))
    end
    validationSet[data.uri] = true
end

return module