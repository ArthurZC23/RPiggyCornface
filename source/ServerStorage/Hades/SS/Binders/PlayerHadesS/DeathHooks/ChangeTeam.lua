local module = {}

function module.handler(hades, kwargs)
    -- Needs to yield, else it errors when the player tries to leave the game.
    task.wait(1/60)
end

return module