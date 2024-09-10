local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})

local module = {}

local S = Data.Strings.Strings
local StarterGui = game:GetService("StarterGui")
function module.handler(hades, kwargs)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    local data = {}
    Promise.try(function()
        local playerGuis = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerGuis", inst = hades.player})
        if not playerGuis then error("No PlayerGuis") end

        local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = hades.player})
        if not playerState then error("No PlayerState") end

        local controller = playerGuis.controllers["RespawnController"]
        local view = controller.view
        view:open({})
        local p1 = Promise.fromEvent(controller.RespawnBtn.Activated)
        local p2 = Promise.fromEvent(playerState:getEvent(S.Session, "Lives", "add"), function(state, action)
            return action.purchased
        end)
        local p3 = Promise.delay(Data.Map.Map.buyNewLifeDuration)
        data.view = view
        return Promise.any({p1, p2, p3})
    end)
    :catchAndPrint()
    :finally(function()
        local hasFinished = true
        data.view:close()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        hades.DeathHookRE:FireServer(script.Name, hasFinished)
    end)
end

return module