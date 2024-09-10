local module = {}

module.getters = {
    {
        name="idToInst",
        getComposedKey = function(inst, obj)
            return {inst:GetAttribute("TeleportId")}
        end,
        getValue = function(inst, obj)
            return obj.teleporter
        end,
    }
}

return module