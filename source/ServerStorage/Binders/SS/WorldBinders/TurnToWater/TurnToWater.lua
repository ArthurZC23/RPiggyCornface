local TurnToWater = {}
TurnToWater.__index = TurnToWater
TurnToWater.className = "TurnToWater"
TurnToWater.TAG_NAME = TurnToWater.className

function TurnToWater.new(part)
    workspace.Terrain:FillBlock(part.CFrame, part.Size, Enum.Material.Water)
    part.Transparency = 1
    part.CanCollide = false
    return
end

function TurnToWater:Destroy()

end

return TurnToWater