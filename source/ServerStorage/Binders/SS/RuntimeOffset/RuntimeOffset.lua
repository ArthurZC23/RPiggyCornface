local RuntimeOffset = {}
RuntimeOffset.__index = RuntimeOffset
RuntimeOffset.TAG_NAME = "RuntimeOffset"

function RuntimeOffset.new(inst)
    inst:PivotTo(inst:GetPivot() + inst:GetAttribute("runtimeOffset"))
end

function RuntimeOffset:Destroy()
end

return RuntimeOffset