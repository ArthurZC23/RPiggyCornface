local RunService = game:GetService("RunService")

local module = {}

module = {
    minutesInADay = 24 * 60,
    realTimeStepInSeconds = 5,
    realTimeDayNightCycleInMinutes = 15,
}

module.robloxTimeStepInMinutes = (module.minutesInADay * (module.realTimeStepInSeconds / 60)/ module.realTimeDayNightCycleInMinutes)
module.startTimeInMin = 0.5 * module.minutesInADay

if RunService:IsStudio() then
    -- module.realTimeStepInSeconds = 1
end

return module