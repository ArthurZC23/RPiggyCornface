local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaServer = Mod:find({"Gaia", "Server"})

local module = {}

GaiaServer.createRemotes(ReplicatedStorage, {
    events = {"FinishLoadingScreen"},
})
local FinishLoadingScreenRE = ReplicatedStorage.Remotes.Events.FinishLoadingScreen

FinishLoadingScreenRE.OnServerEvent:Connect(function(player)
    player:SetAttribute("FinishLoadingScreen", true)
end)

return module