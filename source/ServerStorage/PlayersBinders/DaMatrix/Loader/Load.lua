local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local S = Data.Strings.Strings
local Cronos = Mod:find({"Cronos", "Cronos"})

local binderPlayerCredentials = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerCredentials"})

Players.CharacterAutoLoads = false

local function onPlayerAdded(player)
    CollectionService:AddTag(player, "PlayerCredentials")
    local playerCredentialValidation = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerCredentials, inst=player})
    if not playerCredentialValidation then return end
    playerCredentialValidation.areCredentialsValid
    :andThen(function()
        CollectionService:AddTag(player, "PlayerBindersManager")
    end)
    :catch(function(err)
        local message = tostring(err)
        player:Kick(message)
    end)
    :andThenPromise(function()
        return WaitFor.BObj(player, "PlayerState"):timeout(10)
    end)
    :andThenPromise(function(playerState)
        local banState = playerState:get(S.Stores, "Ban")
        local banReason = banState.r
        if banReason and (banState.ts > Cronos:getTime()) then
            local message = ""
            if banReason == "default" then
                message = "You're banned from the game."
            end
            player:Kick(message)
        end
    end)
    :catchAndPrint()
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    FastSpawn(onPlayerAdded, player)
end

local module = {}

return module