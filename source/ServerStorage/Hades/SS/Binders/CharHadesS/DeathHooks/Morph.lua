local module = {}

function module.handler(hades, kwargs)
    -- Needs to yield, else it errors when the player tries to leave the game.
    local player = hades.player
    local char = hades.char
    player:SetAttribute("morphCf0", char:GetPivot())
    task.wait(1/60)
end

return module