local module = {}

module.encoder = {}
module.decoder = {}

module.encoder = {
   ["Hat"] = "8",
   ["Hair"] = "41",
   ["Face"] = "42",
   ["Neck"] = "43",
   ["Shoulder"] = "44",
   ["Front"] = "45",
   ["Back"] = "46",
   ["Waist"] = "47",
}

for accessoryType, idx in pairs(module.encoder) do
    module.decoder[idx] = accessoryType
end

return module