local module = {}

module.topics = {

}

for key, data in pairs(module.topics) do
    data.name = key
end

return module