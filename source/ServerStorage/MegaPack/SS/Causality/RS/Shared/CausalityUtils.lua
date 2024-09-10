local HttpService = game:GetService("HttpService")

local module = {}

function module.addCauses(inst, causes)
    local causesMap = module.getCauses(inst)
    for cause, data in pairs(causes) do
        causesMap[cause] = data
    end
    inst:SetAttribute("Causes", HttpService:JSONEncode(causesMap))
end

function module.removeCauses(inst, causes)
    local causesMap = module.getCauses(inst)
    for cause in pairs(causes) do
        causesMap[cause] = nil
    end
    inst:SetAttribute("Causes", HttpService:JSONEncode(causesMap))
end

function module.getCauses(inst)
    local causesAttr = inst:GetAttribute("Causes")
    local causesMap
    if causesAttr then
        causesMap = HttpService:JSONDecode(causesAttr)
    else
        causesMap = {}
    end
    return causesMap
end

return module