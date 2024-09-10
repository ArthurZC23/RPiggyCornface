local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MegaPackRs = ReplicatedStorage:WaitForChild("MegaPack")

local megaPackModules = {
    "Signals", -- Events and Functions. Before Gaia and Data (is in MegaPack)
    "ErrorReport",
    "Binder",
    "Viewport",
    "Movies",
    "Guis",
}
for _, moduleName in ipairs(megaPackModules) do
    -- print("Load: ", moduleName)
    require(MegaPackRs
        :WaitForChild(moduleName):WaitForChild("Client")
        :WaitForChild("Loader"):WaitForChild("Load")
    )
end

local RSModules = {
    "Cmdr",
    "Notifications",
    "Tests",
}
for _, moduleName in ipairs(RSModules) do
    -- print("Load: ", moduleName)
    require(ReplicatedStorage
        :WaitForChild(moduleName):WaitForChild("Client")
        :WaitForChild("Loader"):WaitForChild("Load")
    )
end

local gameModules = {
    "Leaderboard",
}
for _, moduleName in ipairs(gameModules) do
    -- print("Load: ", moduleName)
    require(ReplicatedStorage
        :WaitForChild(moduleName):WaitForChild("Client")
        :WaitForChild("Loader"):WaitForChild("Load")
    )
end

local module = {}

return module