local ServerStorage = game:GetService("ServerStorage")

local generalModules = {
    "Data",
    "Collisions",
    "Validators",
    "Hamilton",
    "MegaPack",
    "GameGenrePack",
    "GamePack",
    "Signals",
    "Props",
    "Binders",
    "Obby",
    "DataAsync",
    "StateManager",
    "Hades",
    "Cmdr",
    "Guis",
    "Notifications",
    "Studio",
    "GDPR",
    "Lorenz",
}

for _, moduleName in ipairs(generalModules) do
    -- print("Organize: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Organizer.Organize)
end

local playerModules = {
    "PlayersBinders",
    "Tests",
}

for _, moduleName in ipairs(playerModules) do
    -- print("Organize: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Organizer.Organize)
end

local gameSpecificModules = {
    "Appearance",
    "Rodin",
    "SpatialAwareness",
    "Leaderboard",
    "MBay",
    "Newton",
    "Npc",
    -- "StartScreen",
    -- "Tutorials",
}

for _, moduleName in ipairs(gameSpecificModules) do
    -- print("Organize: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Organizer.Organize)
end


local module = {}

return module