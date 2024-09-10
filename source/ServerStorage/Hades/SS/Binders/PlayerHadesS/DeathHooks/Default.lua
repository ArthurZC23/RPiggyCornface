local module = {}

function module.handler(hades, kwargs)
    -- Needs to yield, else it errors when the player tries to leave the game.
    -- task.wait(0.2)
end

return module