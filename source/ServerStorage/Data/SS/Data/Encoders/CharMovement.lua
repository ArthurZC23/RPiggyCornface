local module = {
    encoder = {
        lockMovementInput = "1",
        lockMovementKeepDirectionInput = "2",
        unlockMovementInput = "3",
        setWalkSpeedAndJumpPower = "4",
        unsetWalkSpeedAndJumpPower = "5",
        autoWalk = "6",
        stopAutoWalk = "7",
        startRunning = "8",
        stopRunning = "9",
        sinkRunButton = "10",
        anchor = "11",
    },
    decoder = {},
}

for value, code in pairs(module.encoder) do
    module.decoder[code] = value
end

return module