local ServerStorage = game:GetService("ServerStorage")

local generalModules = {
    "Signals", -- Events and Functions. Before Gaia and Data (is in MegaPack)
    "Data",
    "DataStore",
    "Collisions", -- -- Need to come before Binders to avoid group don't exist
    "Validators",
    "Hamilton",
    "Props",
    "MegaPack", -- Binder is loaded here.
    "GameGenrePack",
    "GamePack",
    "StateManager",
    "Hades",
    "Obby",
    "Cmdr",
    "Guis",
    "Notifications",
    "DataAsync",
    "Studio",
    "GDPR",
    "Lorenz",
    "SocialRewards",
}
for _, moduleName in ipairs(generalModules) do
    -- print("Load: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Loader.Load)
end

local playerModules = {
    "PlayersBinders",
    "Tests",
}
for _, moduleName in ipairs(playerModules) do
    -- print("Load: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Loader.Load)
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
    -- print("Load: ", moduleName)
    require(ServerStorage[moduleName].DaMatrix.Loader.Load)
end

local module = {}

return module