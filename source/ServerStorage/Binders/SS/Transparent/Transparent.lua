local Transparent = {}
Transparent.__index = Transparent
Transparent.className = "Transparent"
Transparent.TAG_NAME = Transparent.className

function Transparent.new(inst)
    inst.Transparency = 1
end

function Transparent:Destroy()

end

return Transparent